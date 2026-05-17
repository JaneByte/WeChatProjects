package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.mapper.CartMapper;
import com.example.freshtime.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CartServiceImpl implements CartService {

    @Autowired
    private CartMapper cartMapper;

    @Override
    public ApiResponse<?> getCartList(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        List<CartInfo> list = cartMapper.selectCartListByUserId(userId);
        List<Map<String, Object>> result = new ArrayList<>();
        for (CartInfo item : list) {
            if (item.getStatus() == null || item.getStatus() != 1) {
                continue;
            }
            Map<String, Object> row = new HashMap<>();
            row.put("id", item.getId());
            row.put("goodsId", item.getGoodsId());
            row.put("skuId", item.getSkuId());
            row.put("name", item.getName());
            row.put("image", item.getImage());
            row.put("price", item.getPrice());
            row.put("stock", item.getStock());
            row.put("unit", item.getUnit());
            row.put("skuName", item.getSkuName());
            row.put("skuWeightG", item.getSkuWeightG());
            row.put("skuText", buildSkuText(item));
            row.put("desc", item.getOrigin() == null ? "" : item.getOrigin());
            row.put("quantity", item.getQuantity());
            row.put("selected", item.getSelected() != null && item.getSelected() == 1);
            row.put("sourceType", normalizeSourceType(item.getSourceType()));
            row.put("sourcePlanId", item.getSourcePlanId());
            row.put("sourceScene", safeText(item.getSourceScene()));
            result.add(row);
        }
        return ApiResponse.success(result);
    }

    private String buildSkuText(CartInfo item) {
        String skuName = item.getSkuName() == null ? "" : item.getSkuName();
        Integer weight = item.getSkuWeightG();
        if (skuName.isEmpty() && weight == null) {
            return "";
        }
        if (weight == null || weight <= 0) {
            return skuName;
        }
        if (skuName.isEmpty()) {
            return weight + "g";
        }
        return skuName + " · " + weight + "g";
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> addToCart(Long userId, Long goodsId, Long skuId, Integer quantity, String sourceType, Long sourcePlanId, String sourceScene) {
        if (userId == null || goodsId == null || skuId == null) {
            return ApiResponse.badRequest("userId、goodsId或skuId不能为空");
        }
        int addQuantity = (quantity == null || quantity <= 0) ? 1 : quantity;
        String finalSourceType = normalizeSourceType(sourceType);
        Long finalSourcePlanId = sourcePlanId;
        String finalSourceScene = safeText(sourceScene);
        Goods goods = cartMapper.selectGoodsById(goodsId);
        if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
            return ApiResponse.badRequest("商品不存在或已下架");
        }
        GoodsSku sku = cartMapper.selectSkuById(skuId);
        if (sku == null || sku.getGoodsId() == null || !goodsId.equals(sku.getGoodsId()) || sku.getStatus() == null || sku.getStatus() != 1) {
            return ApiResponse.badRequest("商品规格不存在或不可用");
        }
        int stock = sku.getSkuStock() == null ? 0 : sku.getSkuStock();
        if (stock <= 0) {
            return ApiResponse.badRequest("规格库存不足");
        }

        CartInfo cart = cartMapper.selectCartByUserIdAndGoodsIdAndSkuId(userId, goodsId, skuId);
        if (cart == null) {
            CartInfo insert = new CartInfo();
            insert.setUserId(userId);
            insert.setGoodsId(goodsId);
            insert.setSkuId(skuId);
            insert.setQuantity(Math.min(addQuantity, stock));
            insert.setSelected(1);
            insert.setSourceType(finalSourceType);
            insert.setSourcePlanId(finalSourcePlanId);
            insert.setSourceScene(finalSourceScene);
            cartMapper.insertCart(insert);
            return ApiResponse.success("加入购物车成功", null);
        }

        int current = cart.getQuantity() == null ? 0 : cart.getQuantity();
        int next = Math.min(stock, current + addQuantity);
        if (next <= current) {
            return ApiResponse.badRequest("已达库存上限");
        }
        cart.setQuantity(next);
        cart.setSelected(1);
        cart.setSourceType(mergeSourceType(cart.getSourceType(), finalSourceType));
        cart.setSourcePlanId(resolveSourcePlanId(cart.getSourcePlanId(), finalSourcePlanId));
        cart.setSourceScene(resolveSourceScene(cart.getSourceScene(), finalSourceScene));
        cartMapper.updateCart(cart);
        return ApiResponse.success("加入购物车成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> updateQuantity(Long userId, Long goodsId, Long skuId, Integer quantity) {
        if (userId == null || goodsId == null || skuId == null || quantity == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        if (quantity <= 0) {
            return deleteItem(userId, goodsId, skuId);
        }

        CartInfo cart = cartMapper.selectCartByUserIdAndGoodsIdAndSkuId(userId, goodsId, skuId);
        if (cart == null) {
            return ApiResponse.notFound("购物车项不存在");
        }
        Goods goods = cartMapper.selectGoodsById(goodsId);
        if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
            return ApiResponse.badRequest("商品不存在或已下架");
        }
        GoodsSku sku = cartMapper.selectSkuById(skuId);
        if (sku == null || sku.getGoodsId() == null || !goodsId.equals(sku.getGoodsId()) || sku.getStatus() == null || sku.getStatus() != 1) {
            return ApiResponse.badRequest("商品规格不存在或不可用");
        }
        int stock = sku.getSkuStock() == null ? 0 : sku.getSkuStock();
        if (stock <= 0) {
            return ApiResponse.badRequest("规格库存不足");
        }
        int safeQuantity = Math.min(quantity, stock);
        cart.setQuantity(safeQuantity);
        cartMapper.updateCart(cart);
        return ApiResponse.success("更新数量成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> updateSelected(Long userId, Long goodsId, Long skuId, Integer selected) {
        if (userId == null || goodsId == null || skuId == null || selected == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        int safeSelected = selected == 1 ? 1 : 0;
        int updated = cartMapper.updateSelectedByUserIdAndGoodsId(userId, goodsId, skuId, safeSelected);
        if (updated <= 0) {
            return ApiResponse.notFound("购物车项不存在");
        }
        return ApiResponse.success("更新选中状态成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> updateSelectedAll(Long userId, Integer selected) {
        if (userId == null || selected == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        int safeSelected = selected == 1 ? 1 : 0;
        cartMapper.updateSelectedByUserId(userId, safeSelected);
        return ApiResponse.success("全选状态更新成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> deleteItem(Long userId, Long goodsId, Long skuId) {
        if (userId == null || goodsId == null || skuId == null) {
            return ApiResponse.badRequest("userId、goodsId或skuId不能为空");
        }
        int deleted = cartMapper.deleteByUserIdAndGoodsId(userId, goodsId, skuId);
        if (deleted <= 0) {
            return ApiResponse.notFound("购物车项不存在");
        }
        return ApiResponse.success("删除成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> deleteSelected(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        cartMapper.deleteSelectedByUserId(userId);
        return ApiResponse.success("删除成功", null);
    }

    private String normalizeSourceType(String sourceType) {
        String value = safeText(sourceType).toUpperCase();
        if (CartInfo.SOURCE_TYPE_MEAL.equals(value)
                || CartInfo.SOURCE_TYPE_COMBO.equals(value)
                || CartInfo.SOURCE_TYPE_SEASONAL.equals(value)
                || OrderInfo.ORDER_SOURCE_MIXED.equals(value)) {
            return value;
        }
        return CartInfo.SOURCE_TYPE_NORMAL;
    }

    private String mergeSourceType(String currentSourceType, String nextSourceType) {
        String current = normalizeSourceType(currentSourceType);
        String next = normalizeSourceType(nextSourceType);
        if (CartInfo.SOURCE_TYPE_NORMAL.equals(current)) return next;
        if (CartInfo.SOURCE_TYPE_NORMAL.equals(next) || current.equals(next)) return current;
        return OrderInfo.ORDER_SOURCE_MIXED;
    }

    private Long resolveSourcePlanId(Long currentSourcePlanId, Long nextSourcePlanId) {
        if (currentSourcePlanId == null || currentSourcePlanId <= 0) return nextSourcePlanId;
        if (nextSourcePlanId == null || nextSourcePlanId <= 0) return currentSourcePlanId;
        if (currentSourcePlanId.equals(nextSourcePlanId)) return currentSourcePlanId;
        return null;
    }

    private String resolveSourceScene(String currentSourceScene, String nextSourceScene) {
        String current = safeText(currentSourceScene);
        String next = safeText(nextSourceScene);
        if (current.isEmpty()) return next;
        if (next.isEmpty() || current.equals(next)) return current;
        return OrderInfo.ORDER_SOURCE_MIXED;
    }

    private String safeText(String text) {
        return text == null ? "" : text.trim();
    }
}
