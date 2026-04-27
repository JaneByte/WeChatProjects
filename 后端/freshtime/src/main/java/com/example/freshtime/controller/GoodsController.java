package com.example.freshtime.controller;

import com.example.freshtime.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/goods")
@CrossOrigin(origins = "*")
public class GoodsController {

    @Autowired
    private GoodsService goodsService;

    /**
     * 获取商品列表（按分类）
     * GET /api/goods/list?categoryId=3
     */
    @GetMapping("/list")
    public Map<String, Object> getGoodsList(@RequestParam(required = false) Long categoryId) {
        if (categoryId != null) {
            return goodsService.getGoodsList(categoryId);
        } else {
            return goodsService.getRecommendList();
        }
    }

    /**
     * 获取推荐商品（首页用）
     * GET /api/goods/recommend
     */
    @GetMapping("/recommend")
    public Map<String, Object> getRecommendList() {
        return goodsService.getRecommendList();
    }

    /**
     * 获取商品详情
     * GET /api/goods/detail?id=1
     */
    @GetMapping("/detail")
    public Map<String, Object> getGoodsDetail(@RequestParam Long id) {
        return goodsService.getGoodsDetail(id);
    }

    /**
     * 搜索商品
     * GET /api/goods/search?keyword=苹果
     */
    @GetMapping("/search")
    public Map<String, Object> searchGoods(@RequestParam String keyword) {
        return goodsService.searchGoods(keyword);
    }
}