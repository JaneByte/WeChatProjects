package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.mapper.CartMapper;
import com.example.freshtime.service.CartService;
import com.example.freshtime.service.impl.support.CartPriceHelper;
import com.example.freshtime.service.impl.support.CartSourceHelper;
import com.example.freshtime.service.impl.support.CartViewAssembler;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class CartServiceImpl implements CartService {

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private CartPriceHelper cartPriceHelper;

    @Autowired
    private CartSourceHelper cartSourceHelper;

    @Autowired
    private CartViewAssembler cartViewAssembler;

    @Override
    public ApiResponse<?> getCartList(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        List<CartInfo> list;
        try {
            list = cartMapper.selectCartListByUserId(userId);
        } catch (Exception ignored) {
            list = cartMapper.selectCartListBasicByUserId(userId);
        }
        List<java.util.Map<String, Object>> result = new ArrayList<>();
        for (CartInfo item : list) {
            if (item.getStatus() == null || item.getStatus() != 1) {
                continue;
            }
            result.add(cartViewAssembler.buildCartItemRow(item));
        }
        return ApiResponse.success(result);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> addToCart(Long userId, Long goodsId, Long skuId, Integer quantity, String sourceType, Long sourcePlanId, String sourceScene) {
        if (userId == null || goodsId == null) {
            return ApiResponse.badRequest("userId或goodsId不能为空");
        }
        int addQuantity = (quantity == null || quantity <= 0) ? 1 : quantity;
        String finalSourceType = cartSourceHelper.normalizeSourceType(sourceType);
        Long finalSourcePlanId = sourcePlanId;
        String finalSourceScene = cartSourceHelper.normalizeSourceScene(sourceScene);
        Goods goods = cartMapper.selectGoodsById(goodsId);
        if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
            return ApiResponse.badRequest("商品不存在或已下架");
        }
        GoodsSku sku = resolveAvailableSku(goodsId, skuId);
        if (sku == null || sku.getGoodsId() == null || !goodsId.equals(sku.getGoodsId()) || sku.getStatus() == null || sku.getStatus() != 1) {
            return ApiResponse.badRequest("商品规格不存在或不可用");
        }
        Long finalSkuId = sku.getId();
        int stock = sku.getSkuStock() == null ? 0 : sku.getSkuStock();
        if (stock <= 0) {
            return ApiResponse.badRequest("规格库存不足");
        }
        if (CartInfo.SOURCE_TYPE_NORMAL.equals(finalSourceType) && cartPriceHelper.isFlashActive(goods)) {
            finalSourceType = CartInfo.SOURCE_TYPE_FLASH;
            if (finalSourceScene.isEmpty()) {
                finalSourceScene = "限时秒杀";
            }
        }

        CartInfo cart = findCartItem(userId, goodsId, finalSkuId);
        if (cart == null) {
            CartInfo insert = new CartInfo();
            insert.setUserId(userId);
            insert.setGoodsId(goodsId);
            insert.setSkuId(finalSkuId);
            insert.setQuantity(Math.min(addQuantity, stock));
            insert.setSelected(1);
            insert.setSourceType(finalSourceType);
            insert.setSourcePlanId(finalSourcePlanId);
            insert.setSourceScene(finalSourceScene);
            try {
                saveCart(insert);
            } catch (DuplicateKeyException ex) {
                return mergeExistingCartItem(userId, goodsId, finalSkuId, addQuantity, stock, finalSourceType, finalSourcePlanId, finalSourceScene);
            }
            return ApiResponse.success("加入购物车成功", null);
        }

        int current = cart.getQuantity() == null ? 0 : cart.getQuantity();
        int next = Math.min(stock, current + addQuantity);
        if (next <= current) {
            return ApiResponse.badRequest("已达库存上限");
        }
        cart.setQuantity(next);
        cart.setSelected(1);
        cart.setSourceType(cartSourceHelper.mergeSourceType(cart.getSourceType(), finalSourceType));
        cart.setSourcePlanId(cartSourceHelper.resolveSourcePlanId(cart.getSourcePlanId(), finalSourcePlanId));
        cart.setSourceScene(cartSourceHelper.resolveSourceScene(cart.getSourceScene(), finalSourceScene));
        updateCartSafely(cart);
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

        CartInfo cart = findCartItem(userId, goodsId, skuId);
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

    private GoodsSku resolveAvailableSku(Long goodsId, Long skuId) {
        if (goodsId == null) return null;
        if (skuId != null && skuId > 0) {
            GoodsSku matched = cartMapper.selectSkuById(skuId);
            if (matched != null) {
                return matched;
            }
        }
        return cartMapper.selectFirstAvailableSkuByGoodsId(goodsId);
    }

    private CartInfo findCartItem(Long userId, Long goodsId, Long skuId) {
        try {
            return cartMapper.selectCartByUserIdAndGoodsIdAndSkuId(userId, goodsId, skuId);
        } catch (Exception ignored) {
            return cartMapper.selectCartBasicByUserIdAndGoodsIdAndSkuId(userId, goodsId, skuId);
        }
    }

    private void saveCart(CartInfo cartInfo) {
        try {
            cartMapper.insertCart(cartInfo);
        } catch (DuplicateKeyException ex) {
            throw ex;
        } catch (Exception ignored) {
            cartMapper.insertCartBasic(cartInfo);
        }
    }

    private ApiResponse<?> mergeExistingCartItem(Long userId,
                                                 Long goodsId,
                                                 Long skuId,
                                                 int addQuantity,
                                                 int stock,
                                                 String sourceType,
                                                 Long sourcePlanId,
                                                 String sourceScene) {
        CartInfo existing = findCartItem(userId, goodsId, skuId);
        if (existing == null) {
            return ApiResponse.fail("加入购物车失败，请稍后重试");
        }
        int current = existing.getQuantity() == null ? 0 : existing.getQuantity();
        int next = Math.min(stock, current + addQuantity);
        if (next <= current) {
            return ApiResponse.badRequest("已达库存上限");
        }
        existing.setQuantity(next);
        existing.setSelected(1);
        existing.setSourceType(cartSourceHelper.mergeSourceType(existing.getSourceType(), sourceType));
        existing.setSourcePlanId(cartSourceHelper.resolveSourcePlanId(existing.getSourcePlanId(), sourcePlanId));
        existing.setSourceScene(cartSourceHelper.resolveSourceScene(existing.getSourceScene(), sourceScene));
        updateCartSafely(existing);
        return ApiResponse.success("加入购物车成功", null);
    }

    private void updateCartSafely(CartInfo cartInfo) {
        try {
            cartMapper.updateCart(cartInfo);
        } catch (Exception ignored) {
            cartMapper.updateCartBasic(cartInfo);
        }
    }

}
