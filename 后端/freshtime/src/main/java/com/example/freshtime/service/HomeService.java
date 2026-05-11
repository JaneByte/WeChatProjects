package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface HomeService {

    ApiResponse<?> getHomeIndex();

    ApiResponse<?> getHomeGoods(Integer page, Integer pageSize);

    ApiResponse<?> getRecommendGoodsByKeyword(String keyword, Integer limit);
}
