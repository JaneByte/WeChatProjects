package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface GoodsService {

    ApiResponse<?> getGoodsList(Long categoryId);

    ApiResponse<?> getRecommendList();

    ApiResponse<?> getGoodsDetail(Long id);

    ApiResponse<?> searchGoods(String keyword);
}
