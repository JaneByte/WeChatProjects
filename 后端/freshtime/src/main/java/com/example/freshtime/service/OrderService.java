package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SubmitOrderRequest;

public interface OrderService {
    ApiResponse<?> submitOrder(SubmitOrderRequest request);

    ApiResponse<?> getOrderList(Long userId, Integer limit, Integer status);

    ApiResponse<?> getOrderDetail(Long userId, Long orderId);

    ApiResponse<?> cancelOrder(Long userId, Long orderId);

    ApiResponse<?> finishOrder(Long userId, Long orderId);

    ApiResponse<?> payOrder(Long userId, Long orderId);

    ApiResponse<?> expireOrder(Long userId, Long orderId);

    ApiResponse<?> deliverOrder(Long userId, Long orderId);
}
