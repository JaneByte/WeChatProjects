package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface ScenePackService {
    ApiResponse<?> listByScene(String scene);
    ApiResponse<?> addPackToCart(Long userId, Long packId);
}

