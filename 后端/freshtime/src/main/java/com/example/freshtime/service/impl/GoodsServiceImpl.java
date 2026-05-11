package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    public ApiResponse<?> getGoodsListByScene(String scene) {
        String cleanScene = scene == null ? "" : scene.trim();
        if (cleanScene.isEmpty()) {
            return ApiResponse.success(goodsMapper.selectRecommendList());
        }
        String tagName;
        if ("小份量".equals(cleanScene)) {
            tagName = "小份量";
        } else if ("搭配".equals(cleanScene)) {
            tagName = "搭配";
        } else if ("时令".equals(cleanScene)) {
            tagName = "时令";
        } else {
            tagName = "";
        }
        List<Goods> list = tagName.isEmpty() ? goodsMapper.selectBySceneKeyword(cleanScene) : goodsMapper.selectByTagName(tagName);
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
    public ApiResponse<?> searchGoods(String keyword, Integer page, Integer pageSize) {
        String cleanKeyword = keyword == null ? "" : keyword.trim();
        int safePage = (page == null || page < 1) ? 1 : page;
        int safePageSize = (pageSize == null || pageSize < 1) ? 20 : Math.min(pageSize, 50);
        int offset = (safePage - 1) * safePageSize;
        List<Goods> list = goodsMapper.searchByKeyword(cleanKeyword, offset, safePageSize);
        Integer total = goodsMapper.countByKeyword(cleanKeyword);
        int totalCount = total == null ? 0 : total;

        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("page", safePage);
        data.put("pageSize", safePageSize);
        data.put("total", totalCount);
        data.put("hasMore", offset + safePageSize < totalCount);
        return ApiResponse.success(data);
    }
}
