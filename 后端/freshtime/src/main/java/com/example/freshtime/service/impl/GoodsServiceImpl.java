package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GoodsServiceImpl implements GoodsService {

    @Autowired
    private GoodsMapper goodsMapper;

    @Override
    public ApiResponse<?> getGoodsList(Long categoryId) {
        List<Goods> list = goodsMapper.selectByCategoryId(categoryId);
        return ApiResponse.success(list);
    }

    @Override
    public ApiResponse<?> getRecommendList() {
        List<Goods> list = goodsMapper.selectRecommendList();
        return ApiResponse.success(list);
    }

    @Override
    public ApiResponse<?> getGoodsDetail(Long id) {
        Goods goods = goodsMapper.selectById(id);
        if (goods != null) {
            return ApiResponse.success(goods);
        }
        return ApiResponse.fail(404, "商品不存在");
    }

    @Override
    public ApiResponse<?> searchGoods(String keyword) {
        List<Goods> list = goodsMapper.searchByKeyword(keyword);
        return ApiResponse.success(list);
    }
}
