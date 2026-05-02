package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Goods;
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
            row.put("merchantId", item.getMerchantId());
            row.put("name", item.getName());
            row.put("image", item.getImage());
            row.put("price", item.getPrice());
            row.put("stock", item.getStock());
            row.put("unit", item.getUnit());
            row.put("desc", item.getOrigin() == null ? "" : item.getOrigin());
            row.put("quantity", item.getQuantity());
            row.put("selected", item.getSelected() != null && item.getSelected() == 1);
            result.add(row);
        }
        return ApiResponse.success(result);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> addToCart(Long userId, Long goodsId, Integer quantity) {
        if (userId == null || goodsId == null) {
            return ApiResponse.badRequest("userId或goodsId不能为空");
        }
        int addQuantity = (quantity == null || quantity <= 0) ? 1 : quantity;
        Goods goods = cartMapper.selectGoodsById(goodsId);
        if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
            return ApiResponse.badRequest("商品不存在或已下架");
        }
        int stock = goods.getStock() == null ? 0 : goods.getStock();
        if (stock <= 0) {
            return ApiResponse.badRequest("商品库存不足");
        }

        CartInfo cart = cartMapper.selectCartByUserIdAndGoodsId(userId, goodsId);
        if (cart == null) {
            CartInfo insert = new CartInfo();
            insert.setUserId(userId);
            insert.setGoodsId(goodsId);
            insert.setMerchantId(goods.getMerchantId());
            insert.setQuantity(Math.min(addQuantity, stock));
            insert.setSelected(1);
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
        cartMapper.updateCart(cart);
        return ApiResponse.success("加入购物车成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> updateQuantity(Long userId, Long goodsId, Integer quantity) {
        if (userId == null || goodsId == null || quantity == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        if (quantity <= 0) {
            return deleteItem(userId, goodsId);
        }

        CartInfo cart = cartMapper.selectCartByUserIdAndGoodsId(userId, goodsId);
        if (cart == null) {
            return ApiResponse.notFound("购物车项不存在");
        }
        Goods goods = cartMapper.selectGoodsById(goodsId);
        if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
            return ApiResponse.badRequest("商品不存在或已下架");
        }
        int stock = goods.getStock() == null ? 0 : goods.getStock();
        if (stock <= 0) {
            return ApiResponse.badRequest("商品库存不足");
        }
        int safeQuantity = Math.min(quantity, stock);
        cart.setQuantity(safeQuantity);
        cartMapper.updateCart(cart);
        return ApiResponse.success("更新数量成功", null);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> updateSelected(Long userId, Long goodsId, Integer selected) {
        if (userId == null || goodsId == null || selected == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        int safeSelected = selected == 1 ? 1 : 0;
        int updated = cartMapper.updateSelectedByUserIdAndGoodsId(userId, goodsId, safeSelected);
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
    public ApiResponse<?> deleteItem(Long userId, Long goodsId) {
        if (userId == null || goodsId == null) {
            return ApiResponse.badRequest("userId或goodsId不能为空");
        }
        int deleted = cartMapper.deleteByUserIdAndGoodsId(userId, goodsId);
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
}

