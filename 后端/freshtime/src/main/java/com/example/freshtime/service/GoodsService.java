package com.example.freshtime.service;

import java.util.Map;

public interface GoodsService {

    // 根据分类ID获取商品列表
    Map<String, Object> getGoodsList(Long categoryId);

    // 获取推荐商品列表
    Map<String, Object> getRecommendList();

    // 获取商品详情
    Map<String, Object> getGoodsDetail(Long id);

    // 搜索商品
    Map<String, Object> searchGoods(String keyword);
}
