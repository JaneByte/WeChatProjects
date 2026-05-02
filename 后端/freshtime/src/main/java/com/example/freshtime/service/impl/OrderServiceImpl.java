package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.MockPayConfirmRequest;
import com.example.freshtime.dto.SubmitOrderRequest;
import com.example.freshtime.entity.AddressInfo;
import com.example.freshtime.entity.CouponInfo;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import com.example.freshtime.mapper.AddressMapper;
import com.example.freshtime.mapper.CartMapper;
import com.example.freshtime.mapper.CouponMapper;
import com.example.freshtime.mapper.OrderMapper;
import com.example.freshtime.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class OrderServiceImpl implements OrderService {
    private static final int MAX_ORDER_ITEM_COUNT = 50;
    private static final String MOCK_PAY_CHANNEL = "mock_wechat";
    private static final ConcurrentHashMap<Long, Object> USER_SUBMIT_LOCK = new ConcurrentHashMap<>();

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private AddressMapper addressMapper;

    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private CartMapper cartMapper;

    @Value("${spring.datasource.url:}")
    private String datasourceUrl;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> submitOrder(SubmitOrderRequest request) {
        if (request == null || request.getUserId() == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        if (request.getItems() == null || request.getItems().isEmpty()) {
            return ApiResponse.badRequest("订单商品不能为空");
        }
        if (request.getItems().size() > MAX_ORDER_ITEM_COUNT) {
            return ApiResponse.badRequest("单次下单商品数量过多");
        }
        if (request.getRemark() != null && request.getRemark().length() > 200) {
            return ApiResponse.badRequest("订单备注过长");
        }

        final Long userId = request.getUserId();
        Object lockToken = new Object();
        Object existing = USER_SUBMIT_LOCK.putIfAbsent(userId, lockToken);
        if (existing != null) {
            return ApiResponse.badRequest("请勿重复提交订单");
        }

        try {
            return doSubmitOrder(request);
        } finally {
            USER_SUBMIT_LOCK.remove(userId, lockToken);
        }
    }

    private ApiResponse<?> doSubmitOrder(SubmitOrderRequest request) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        List<OrderItemInfo> orderItems = new ArrayList<>();
        Map<Long, Integer> mergedItems = new HashMap<>();

        for (SubmitOrderRequest.Item item : request.getItems()) {
            if (item.getGoodsId() == null || item.getQuantity() == null || item.getQuantity() <= 0) {
                return ApiResponse.badRequest("商品参数不合法");
            }
            mergedItems.put(item.getGoodsId(), mergedItems.getOrDefault(item.getGoodsId(), 0) + item.getQuantity());
        }

        for (Map.Entry<Long, Integer> entry : mergedItems.entrySet()) {
            Long goodsId = entry.getKey();
            Integer quantity = entry.getValue();

            Goods goods = orderMapper.selectGoodsForUpdate(goodsId);
            if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
                return ApiResponse.badRequest("商品不存在或已下架");
            }
            if (goods.getStock() == null || goods.getStock() < quantity) {
                return ApiResponse.badRequest("商品库存不足: " + goods.getName());
            }

            int updated = orderMapper.deductGoodsStock(goods.getId(), quantity);
            if (updated <= 0) {
                return ApiResponse.badRequest("库存更新失败，请重试");
            }

            BigDecimal itemPrice = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
            BigDecimal itemTotal = itemPrice.multiply(BigDecimal.valueOf(quantity));
            totalAmount = totalAmount.add(itemTotal);

            OrderItemInfo orderItem = new OrderItemInfo();
            orderItem.setGoodsId(goods.getId());
            orderItem.setGoodsName(goods.getName());
            orderItem.setGoodsImage(goods.getMainImage());
            orderItem.setPrice(itemPrice);
            orderItem.setQuantity(quantity);
            orderItem.setTotalPrice(itemTotal);
            orderItems.add(orderItem);
        }

        String receiverName = emptyToDefault(request.getReceiverName(), "默认收货人");
        String receiverPhone = emptyToDefault(request.getReceiverPhone(), "13800000000");
        String receiverAddress = emptyToDefault(request.getReceiverAddress(), "默认收货地址");

        if (request.getAddressId() != null) {
            AddressInfo address = addressMapper.selectByIdAndUserId(request.getAddressId(), request.getUserId());
            if (address == null) {
                return ApiResponse.badRequest("收货地址不存在");
            }
            receiverName = address.getReceiverName();
            receiverPhone = address.getReceiverPhone();
            receiverAddress = String.format("%s%s%s%s",
                    emptyToDefault(address.getProvince(), ""),
                    emptyToDefault(address.getCity(), ""),
                    emptyToDefault(address.getDistrict(), ""),
                    emptyToDefault(address.getDetail(), ""));
        }

        BigDecimal discountAmount = BigDecimal.ZERO;
        Long couponId = request.getCouponId();
        if (couponId != null) {
            CouponInfo coupon = couponMapper.selectByIdAndUserId(couponId, request.getUserId());
            if (coupon == null || coupon.getStatus() == null || coupon.getStatus() != 1) {
                return ApiResponse.badRequest("优惠券不可用");
            }
            if (coupon.getExpireDate() != null && coupon.getExpireDate().isBefore(java.time.LocalDate.now())) {
                return ApiResponse.badRequest("优惠券已过期");
            }
            BigDecimal threshold = coupon.getThresholdAmount() == null ? BigDecimal.ZERO : coupon.getThresholdAmount();
            BigDecimal discount = coupon.getDiscountAmount() == null ? BigDecimal.ZERO : coupon.getDiscountAmount();
            if (totalAmount.compareTo(threshold) < 0) {
                return ApiResponse.badRequest("未满足优惠券使用门槛");
            }
            discountAmount = discount.min(totalAmount);
        }

        BigDecimal actualAmount = totalAmount.subtract(discountAmount);
        if (actualAmount.compareTo(BigDecimal.ZERO) < 0) {
            actualAmount = BigDecimal.ZERO;
        }

        OrderInfo orderInfo = new OrderInfo();
        orderInfo.setOrderNo(generateOrderNo());
        orderInfo.setUserId(request.getUserId());
        orderInfo.setMerchantId(request.getMerchantId() == null ? 1L : request.getMerchantId());
        orderInfo.setTotalAmount(totalAmount);
        orderInfo.setDiscountAmount(discountAmount);
        orderInfo.setActualAmount(actualAmount);
        orderInfo.setReceiverName(receiverName);
        orderInfo.setReceiverPhone(receiverPhone);
        orderInfo.setReceiverAddress(receiverAddress);
        orderInfo.setRemark(request.getRemark());
        orderInfo.setStatus(0);
        orderInfo.setPayStatus(0);

        orderMapper.insertOrder(orderInfo);

        if (couponId != null) {
            int marked = couponMapper.markUsed(couponId, request.getUserId());
            if (marked <= 0) {
                return ApiResponse.badRequest("优惠券使用失败，请重试");
            }
        }

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
            expireOverduePendingOrder(order);
            result.add(buildOrderView(order));
        }
        return ApiResponse.success(result);
    }

    @Override
    public ApiResponse<?> getOrderDetail(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }
        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        expireOverduePendingOrder(order);
        order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        return ApiResponse.success(buildOrderView(order));
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
        if (order.getStatus() == null || (order.getStatus() != 0 && order.getStatus() != 1)) {
            return ApiResponse.badRequest("仅待付款或待发货订单可取消");
        }

        int restoreCount = orderMapper.restoreGoodsStockByOrderId(orderId);
        if (restoreCount <= 0) {
            return ApiResponse.badRequest("库存回补失败，请重试");
        }

        int updated = orderMapper.updateOrderStatus(orderId, userId, order.getStatus(), 4);
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
        if (order.getStatus() == null || order.getStatus() != 2) {
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
        ApiResponse<?> createResp = mockPayCreate(userId, orderId);
        if (createResp.getCode() != 200) {
            return createResp;
        }
        Object data = createResp.getData();
        if (!(data instanceof Map)) {
            return ApiResponse.badRequest("发起支付失败");
        }
        Map<?, ?> row = (Map<?, ?>) data;
        Object tradeNoObj = row.get("payTradeNo");
        if (tradeNoObj == null) {
            return ApiResponse.badRequest("发起支付失败");
        }
        MockPayConfirmRequest request = new MockPayConfirmRequest();
        request.setUserId(userId);
        request.setOrderId(orderId);
        request.setPayTradeNo(String.valueOf(tradeNoObj));
        return mockPayConfirm(request);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> mockPayCreate(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            return ApiResponse.badRequest("当前状态不可支付");
        }
        if (order.getPayStatus() != null && order.getPayStatus() == 2) {
            return ApiResponse.badRequest("订单已支付");
        }

        String payTradeNo = generateMockPayTradeNo();
        int updated = orderMapper.createMockPay(orderId, userId, MOCK_PAY_CHANNEL, payTradeNo);
        if (updated <= 0) {
            return ApiResponse.badRequest("发起支付失败，请重试");
        }

        Map<String, Object> data = new HashMap<>();
        data.put("orderId", orderId);
        data.put("payChannel", MOCK_PAY_CHANNEL);
        data.put("payTradeNo", payTradeNo);
        data.put("payStatus", 1);
        return ApiResponse.success("模拟支付单已创建", data);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> mockPayConfirm(MockPayConfirmRequest request) {
        if (request == null || request.getUserId() == null || request.getOrderId() == null) {
            return ApiResponse.badRequest("支付确认参数不能为空");
        }
        String payTradeNo = request.getPayTradeNo() == null ? "" : request.getPayTradeNo().trim();
        if (payTradeNo.isEmpty()) {
            return ApiResponse.badRequest("payTradeNo不能为空");
        }

        OrderInfo order = orderMapper.selectOrderByIdAndUserId(request.getOrderId(), request.getUserId());
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            return ApiResponse.badRequest("当前状态不可支付确认");
        }

        int updated = orderMapper.confirmMockPay(request.getOrderId(), request.getUserId(), payTradeNo);
        if (updated <= 0) {
            return ApiResponse.badRequest("支付确认失败，请重试");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("orderId", request.getOrderId());
        data.put("payTradeNo", payTradeNo);
        data.put("payChannel", MOCK_PAY_CHANNEL);
        data.put("payStatus", 2);
        return ApiResponse.success("支付成功", data);
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
        if (!isOrderOverdue(order)) {
            return ApiResponse.badRequest("订单未超时，不可过期取消");
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
        if (order.getStatus() == null || order.getStatus() != 1) {
            return ApiResponse.badRequest("当前状态不可发货");
        }

        int updated = orderMapper.deliverOrder(orderId, userId);
        if (updated <= 0) {
            return ApiResponse.badRequest("发货失败，请重试");
        }
        return ApiResponse.success("发货成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> applyRefund(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }
        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null || (order.getStatus() != 1 && order.getStatus() != 2)) {
            return ApiResponse.badRequest("当前状态不可申请退款");
        }
        int updated = orderMapper.applyRefund(orderId, userId);
        if (updated <= 0) {
            return ApiResponse.badRequest("退款申请失败，请重试");
        }
        return ApiResponse.success("退款申请已提交", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> finishRefund(Long userId, Long orderId) {
        if (userId == null || orderId == null) {
            return ApiResponse.badRequest("userId或orderId不能为空");
        }
        OrderInfo order = orderMapper.selectOrderByIdAndUserId(orderId, userId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != 6) {
            return ApiResponse.badRequest("当前状态不可完成退款");
        }

        orderMapper.restoreGoodsStockByOrderId(orderId);
        int updated = orderMapper.finishRefund(orderId, userId);
        if (updated <= 0) {
            return ApiResponse.badRequest("退款完成失败，请重试");
        }
        return ApiResponse.success("退款已完成", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> clearMyTestData(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        if (datasourceUrl == null || !datasourceUrl.contains("localhost")) {
            return ApiResponse.forbidden("仅开发环境可执行清理");
        }
        cartMapper.deleteAllByUserId(userId);
        addressMapper.deleteByUserId(userId);
        orderMapper.deleteOrderItemsByUserId(userId);
        orderMapper.deleteOrdersByUserId(userId);
        return ApiResponse.success("测试数据已清理", null);
    }

    private Map<String, Object> buildOrderView(OrderInfo order) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", order.getId());
        row.put("orderNo", order.getOrderNo());
        row.put("status", order.getStatus());
        row.put("actualAmount", order.getActualAmount());
        row.put("createTime", order.getCreateTime());
        row.put("receiverName", order.getReceiverName());
        row.put("receiverPhone", order.getReceiverPhone());
        row.put("receiverAddress", order.getReceiverAddress());
        row.put("remark", order.getRemark());
        row.put("payChannel", order.getPayChannel());
        row.put("payTradeNo", order.getPayTradeNo());
        row.put("payStatus", order.getPayStatus());
        row.put("payTime", order.getPayTime());
        row.put("statusText", mapStatusText(order.getStatus()));
        row.put("items", orderMapper.selectOrderItemsByOrderId(order.getId()));
        return row;
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
            case 6:
                return "退款中";
            default:
                return "未知状态";
        }
    }

    private String generateOrderNo() {
        String random = UUID.randomUUID().toString().replace("-", "").substring(0, 6).toUpperCase();
        return "FT" + System.currentTimeMillis() + random;
    }

    private String generateMockPayTradeNo() {
        String random = UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
        return "MOCK" + System.currentTimeMillis() + random;
    }

    private boolean isOrderOverdue(OrderInfo order) {
        if (order == null || order.getCreateTime() == null) {
            return false;
        }
        LocalDateTime expireAt = order.getCreateTime().plusMinutes(30);
        return !LocalDateTime.now().isBefore(expireAt);
    }

    private void expireOverduePendingOrder(OrderInfo order) {
        if (order == null || order.getId() == null || order.getUserId() == null) {
            return;
        }
        if (order.getStatus() == null || order.getStatus() != 0) {
            return;
        }
        if (!isOrderOverdue(order)) {
            return;
        }
        orderMapper.restoreGoodsStockByOrderId(order.getId());
        orderMapper.updateOrderStatus(order.getId(), order.getUserId(), 0, 4);
    }

    private String emptyToDefault(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) {
            return fallback;
        }
        return value.trim();
    }
}
