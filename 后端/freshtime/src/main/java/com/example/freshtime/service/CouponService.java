package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface CouponService {
    ApiResponse<?> list(Long userId);
    ApiResponse<?> listAvailable(Long userId);
    ApiResponse<?> claim(Long userId, Long couponId);
}
