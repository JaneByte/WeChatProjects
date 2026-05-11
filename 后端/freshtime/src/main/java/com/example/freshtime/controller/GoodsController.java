package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/goods")
@CrossOrigin(origins = "*")
public class GoodsController {

    @Autowired
    private GoodsService goodsService;

    @GetMapping("/list")
    public ApiResponse<?> getGoodsList(
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) String scene) {
        if (scene != null && !scene.trim().isEmpty()) {
            return goodsService.getGoodsListByScene(scene);
        }
        if (categoryId != null) {
            return goodsService.getGoodsList(categoryId);
        }
        return goodsService.getRecommendList();
    }

    @GetMapping("/recommend")
    public ApiResponse<?> getRecommendList() {
        return goodsService.getRecommendList();
    }

    @GetMapping("/detail")
    public ApiResponse<?> getGoodsDetail(@RequestParam Long id) {
        return goodsService.getGoodsDetail(id);
    }

    @GetMapping("/search")
    public ApiResponse<?> searchGoods(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "20") Integer pageSize) {
        return goodsService.searchGoods(keyword, page, pageSize);
    }
}
