package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface CartService {

    ApiResponse<?> getCartList(Long userId);

    ApiResponse<?> addToCart(Long userId, Long goodsId, Long skuId, Integer quantity, String sourceType, Long sourcePlanId, String sourceScene);

    ApiResponse<?> updateQuantity(Long userId, Long goodsId, Long skuId, Integer quantity);

    ApiResponse<?> updateSelected(Long userId, Long goodsId, Long skuId, Integer selected);

    ApiResponse<?> updateSelectedAll(Long userId, Integer selected);

    ApiResponse<?> deleteItem(Long userId, Long goodsId, Long skuId);

    ApiResponse<?> deleteSelected(Long userId);
}
