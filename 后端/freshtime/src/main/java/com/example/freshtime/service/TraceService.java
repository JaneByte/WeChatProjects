package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface TraceService {
    ApiResponse<?> detail(Long goodsId);
}
