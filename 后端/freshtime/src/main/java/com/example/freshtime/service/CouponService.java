package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface CouponService {
    ApiResponse<?> list(Long userId);
    ApiResponse<?> grantDefaultCoupons(Long userId);
}
