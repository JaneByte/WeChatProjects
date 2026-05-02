package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface CartService {

    ApiResponse<?> getCartList(Long userId);

    ApiResponse<?> addToCart(Long userId, Long goodsId, Integer quantity);

    ApiResponse<?> updateQuantity(Long userId, Long goodsId, Integer quantity);

    ApiResponse<?> updateSelected(Long userId, Long goodsId, Integer selected);

    ApiResponse<?> updateSelectedAll(Long userId, Integer selected);

    ApiResponse<?> deleteItem(Long userId, Long goodsId);

    ApiResponse<?> deleteSelected(Long userId);
}

