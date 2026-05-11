package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface GoodsService {

    ApiResponse<?> getGoodsList(Long categoryId);

    ApiResponse<?> getGoodsListByScene(String scene);

    ApiResponse<?> getRecommendList();

    ApiResponse<?> getGoodsDetail(Long id);

    ApiResponse<?> searchGoods(String keyword, Integer page, Integer pageSize);
}
