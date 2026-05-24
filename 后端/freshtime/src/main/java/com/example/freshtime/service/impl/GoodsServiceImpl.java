package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.service.GoodsService;
import com.example.freshtime.service.impl.support.GoodsCardAssembler;
import com.example.freshtime.service.impl.support.GoodsSceneHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GoodsServiceImpl implements GoodsService {
    private static final int SCENE_LIST_LIMIT = 30;

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private GoodsCardAssembler goodsCardAssembler;

    @Autowired
    private GoodsSceneHelper goodsSceneHelper;

    @Override
    public ApiResponse<?> getGoodsList(Long categoryId) {
        List<Goods> list = goodsMapper.selectByCategoryId(categoryId);
        return ApiResponse.success(buildGoodsCardList(list));
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
        List<Goods> list;
        if (tagName.isEmpty()) {
            list = goodsMapper.selectBySceneKeyword(cleanScene);
        } else {
            list = goodsMapper.selectByTagName(tagName);
            if (list == null || list.isEmpty()) {
                list = goodsMapper.selectBySceneKeyword(goodsSceneHelper.resolveSceneFallbackKeyword(cleanScene));
            }
        }
        if (list != null && list.size() > SCENE_LIST_LIMIT) {
            list = new ArrayList<>(list.subList(0, SCENE_LIST_LIMIT));
        }
        return ApiResponse.success(goodsCardAssembler.buildSceneGoodsList(cleanScene, list));
    }

    @Override
    public ApiResponse<?> getRecommendList() {
        List<Goods> list = goodsMapper.selectRecommendList();
        return ApiResponse.success(goodsCardAssembler.buildGoodsCardList(list));
    }

    @Override
    public ApiResponse<?> getGoodsDetail(Long id) {
        Goods goods = goodsMapper.selectById(id);
        if (goods != null) {
            return ApiResponse.success(goodsCardAssembler.buildGoodsDetailView(goods));
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
        data.put("list", goodsCardAssembler.buildGoodsCardList(list));
        data.put("page", safePage);
        data.put("pageSize", safePageSize);
        data.put("total", totalCount);
        data.put("hasMore", offset + safePageSize < totalCount);
        return ApiResponse.success(data);
    }

    public List<Map<String, Object>> buildGoodsCardList(List<Goods> list) {
        return goodsCardAssembler.buildGoodsCardList(list);
    }
}
