package com.example.freshtime.service.impl;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
public class GoodsServiceImpl implements GoodsService {

    @Autowired
    private GoodsMapper goodsMapper;

    @Override
    public Map<String, Object> getGoodsList(Long categoryId) {
        List<Goods> list = goodsMapper.selectByCategoryId(categoryId);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("msg", "success");
        response.put("data", list);
        return response;
    }

    @Override
    public Map<String, Object> getRecommendList() {
        List<Goods> list = goodsMapper.selectRecommendList();

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("msg", "success");
        response.put("data", list);
        return response;
    }

    @Override
    public Map<String, Object> getGoodsDetail(Long id) {
        Goods goods = goodsMapper.selectById(id);

        Map<String, Object> response = new HashMap<>();
        if (goods != null) {
            response.put("code", 200);
            response.put("msg", "success");
            response.put("data", goods);
        } else {
            response.put("code", 404);
            response.put("msg", "商品不存在");
            response.put("data", null);
        }
        return response;
    }

    @Override
    public Map<String, Object> searchGoods(String keyword) {
        List<Goods> list = goodsMapper.searchByKeyword(keyword);

        Map<String, Object> response = new HashMap<>();
        response.put("code", 200);
        response.put("msg", "success");
        response.put("data", list);
        return response;
    }
}