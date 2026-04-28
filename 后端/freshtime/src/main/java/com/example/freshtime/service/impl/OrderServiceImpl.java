package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SubmitOrderRequest;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import com.example.freshtime.mapper.OrderMapper;
import com.example.freshtime.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class OrderServiceImpl implements OrderService {

    @Autowired
    private OrderMapper orderMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> submitOrder(SubmitOrderRequest request) {
        if (request == null || request.getUserId() == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        if (request.getItems() == null || request.getItems().isEmpty()) {
            return ApiResponse.badRequest("订单商品不能为空");
        }

        BigDecimal totalAmount = BigDecimal.ZERO;
        List<OrderItemInfo> orderItems = new ArrayList<>();

        for (SubmitOrderRequest.Item item : request.getItems()) {
            if (item.getGoodsId() == null || item.getQuantity() == null || item.getQuantity() <= 0) {
                return ApiResponse.badRequest("商品参数不合法");
            }

            Goods goods = orderMapper.selectGoodsForUpdate(item.getGoodsId());
            if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
                return ApiResponse.badRequest("商品不存在或已下架");
            }
            if (goods.getStock() == null || goods.getStock() < item.getQuantity()) {
                return ApiResponse.badRequest("商品库存不足: " + goods.getName());
            }

            int updated = orderMapper.deductGoodsStock(goods.getId(), item.getQuantity());
            if (updated <= 0) {
                return ApiResponse.badRequest("库存更新失败，请重试");
            }

            BigDecimal itemPrice = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
            BigDecimal itemTotal = itemPrice.multiply(BigDecimal.valueOf(item.getQuantity()));
            totalAmount = totalAmount.add(itemTotal);

            OrderItemInfo orderItem = new OrderItemInfo();
            orderItem.setGoodsId(goods.getId());
            orderItem.setGoodsName(goods.getName());
            orderItem.setGoodsImage(goods.getMainImage());
            orderItem.setPrice(itemPrice);
            orderItem.setQuantity(item.getQuantity());
            orderItem.setTotalPrice(itemTotal);
            orderItems.add(orderItem);
        }

        OrderInfo orderInfo = new OrderInfo();
        orderInfo.setOrderNo(generateOrderNo());
        orderInfo.setUserId(request.getUserId());
        orderInfo.setMerchantId(request.getMerchantId() == null ? 1L : request.getMerchantId());
        orderInfo.setTotalAmount(totalAmount);
        orderInfo.setDiscountAmount(BigDecimal.ZERO);
        orderInfo.setActualAmount(totalAmount);
        orderInfo.setReceiverName(emptyToDefault(request.getReceiverName(), "默认收货人"));
        orderInfo.setReceiverPhone(emptyToDefault(request.getReceiverPhone(), "13800000000"));
        orderInfo.setReceiverAddress(emptyToDefault(request.getReceiverAddress(), "默认收货地址"));
        orderInfo.setRemark(request.getRemark());
        orderInfo.setStatus(0);

        orderMapper.insertOrder(orderInfo);

        for (OrderItemInfo orderItem : orderItems) {
            orderItem.setOrderId(orderInfo.getId());
            orderMapper.insertOrderItem(orderItem);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("orderId", orderInfo.getId());
        data.put("orderNo", orderInfo.getOrderNo());
        data.put("actualAmount", orderInfo.getActualAmount());
        return ApiResponse.success("下单成功", data);
    }

    @Override
    public ApiResponse<?> getOrderList(Long userId, Integer limit, Integer status) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        int safeLimit = (limit == null || limit <= 0) ? 20 : Math.min(limit, 100);

        List<OrderInfo> orders = (status == null)
                ? orderMapper.selectOrderListByUserId(userId, safeLimit)
                : orderMapper.selectOrderListByUserIdAndStatus(userId, status, safeLimit);

        List<Map<String, Object>> result = new ArrayList<>();
        for (OrderInfo order : orders) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", order.getId());
            row.put("orderNo", order.getOrderNo());
            row.put("status", order.getStatus());
            row.put("actualAmount", order.getActualAmount());
            row.put("createTime", order.getCreateTime());
            row.put("statusText", mapStatusText(order.getStatus()));
            row.put("items", orderMapper.selectOrderItemsByOrderId(order.getId()));
            result.add(row);
        }
        return ApiResponse.success(result);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> cancelOrder(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null) {
            return ApiResponse.badRequest("订单状态异常");
        }
        if (order.getStatus() == 4) {
            return ApiResponse.badRequest("订单已取消，无需重复操作");
        }
        if (order.getStatus() == 0) {
            return ApiResponse.badRequest("待付款订单请使用“过期取消”");
        }
        if (order.getStatus() == 2) {
            return ApiResponse.badRequest("订单已发货，暂不可取消");
        }
        if (order.getStatus() == 3) {
            return ApiResponse.badRequest("订单已完成，无法取消");
        }
        if (order.getStatus() == 5) {
            return ApiResponse.badRequest("订单已退款，无法取消");
        }
        if (order.getStatus() != 1) {
            return ApiResponse.badRequest("当前状态不可取消");
        }

        int restoreCount = orderMapper.restoreGoodsStockByOrderId(orderId);
        if (restoreCount <= 0) {
            return ApiResponse.badRequest("库存回补失败，请重试");
        }

        int updated = orderMapper.updateOrderStatus(orderId, userId, 1, 4);
        if (updated <= 0) {
            return ApiResponse.badRequest("取消失败，请重试");
        }

        return ApiResponse.success("取消成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> finishOrder(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null) {
            return ApiResponse.badRequest("订单状态异常");
        }
        if (order.getStatus() == 3) {
            return ApiResponse.badRequest("订单已完成，无需重复收货");
        }
        if (order.getStatus() != 2) {
            return ApiResponse.badRequest("当前状态不可确认收货");
        }

        int updated = orderMapper.updateOrderStatus(orderId, userId, 2, 3);
        if (updated <= 0) {
            return ApiResponse.badRequest("确认收货失败，请重试");
        }

        return ApiResponse.success("确认收货成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> payOrder(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null) {
            return ApiResponse.badRequest("订单状态异常");
        }
        if (order.getStatus() == 1) {
            return ApiResponse.badRequest("订单已支付，无需重复支付");
        }
        if (order.getStatus() == 4) {
            return ApiResponse.badRequest("订单已取消，无法支付");
        }
        if (order.getStatus() == 3) {
            return ApiResponse.badRequest("订单已完成，无法支付");
        }
        if (order.getStatus() != 0) {
            return ApiResponse.badRequest("当前状态不可支付");
        }

        int updated = orderMapper.payOrder(orderId, userId);
        if (updated <= 0) {
            return ApiResponse.badRequest("支付失败，请重试");
        }
        return ApiResponse.success("支付成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> expireOrder(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            return ApiResponse.badRequest("当前状态不可过期取消");
        }

        int restoreCount = orderMapper.restoreGoodsStockByOrderId(orderId);
        if (restoreCount <= 0) {
            return ApiResponse.badRequest("库存回补失败，请重试");
        }
        int updated = orderMapper.updateOrderStatus(orderId, userId, 0, 4);
        if (updated <= 0) {
            return ApiResponse.badRequest("过期取消失败，请重试");
        }
        return ApiResponse.success("订单已过期取消", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> deliverOrder(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null) {
            return ApiResponse.badRequest("订单状态异常");
        }
        if (order.getStatus() == 2) {
            return ApiResponse.badRequest("订单已发货，无需重复操作");
        }
        if (order.getStatus() != 1) {
            return ApiResponse.badRequest("当前状态不可发货");
        }

        int updated = orderMapper.deliverOrder(orderId, userId);
        if (updated <= 0) {
            return ApiResponse.badRequest("发货失败，请重试");
        }
        return ApiResponse.success("发货成功", null);
    }

    private String mapStatusText(Integer status) {
        if (status == null) return "未知状态";
        switch (status) {
            case 0:
                return "待付款";
            case 1:
                return "待发货";
            case 2:
                return "待收货";
            case 3:
                return "已完成";
            case 4:
                return "已取消";
            case 5:
                return "已退款";
            default:
                return "未知状态";
        }
    }

    private String generateOrderNo() {
        String random = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        return "FT" + System.currentTimeMillis() + random;
    }

    private String emptyToDefault(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }
}
