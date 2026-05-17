package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.ScenePack;
import com.example.freshtime.entity.ScenePackItem;
import com.example.freshtime.mapper.ScenePackMapper;
import com.example.freshtime.service.CartService;
import com.example.freshtime.service.ScenePackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ScenePackServiceImpl implements ScenePackService {
    private static final int SCENE_PACK_LIMIT = 20;

    @Autowired
    private ScenePackMapper scenePackMapper;

    @Autowired
    private CartService cartService;

    @Override
    public ApiResponse<?> listByScene(String scene) {
        String sceneType = normalizeSceneType(scene);
        if (sceneType.isEmpty()) {
            return ApiResponse.badRequest("场景参数不正确");
        }
        List<ScenePack> packList = scenePackMapper.selectActiveBySceneType(sceneType, SCENE_PACK_LIMIT);
        List<Map<String, Object>> result = new ArrayList<>();
        for (ScenePack pack : packList) {
            List<ScenePackItem> itemList = scenePackMapper.selectItemsByPackId(pack.getId());
            Map<String, Object> row = new HashMap<>();
            row.put("id", pack.getId());
            row.put("name", pack.getName());
            row.put("sceneType", pack.getSceneType());
            row.put("packMode", pack.getPackMode());
            row.put("coverImage", pack.getCoverImage());
            row.put("summary", pack.getSummary());
            row.put("price", pack.getPrice());
            row.put("originalPrice", pack.getOriginalPrice());
            row.put("stock", pack.getStock());
            row.put("couponThresholdHint", pack.getCouponThresholdHint());
            row.put("items", itemList);
            result.add(row);
        }
        return ApiResponse.success(result);
    }

    @Override
    public ApiResponse<?> addPackToCart(Long userId, Long packId) {
        if (userId == null || packId == null) {
            return ApiResponse.badRequest("userId或packId不能为空");
        }
        List<ScenePackItem> itemList = scenePackMapper.selectItemsByPackId(packId);
        if (itemList == null || itemList.isEmpty()) {
            return ApiResponse.badRequest("组合商品不存在");
        }
        for (ScenePackItem item : itemList) {
            if (item.getGoodsId() == null || item.getSkuId() == null) {
                return ApiResponse.badRequest("组合商品规格配置不完整");
            }
            int quantity = item.getQuantity() == null || item.getQuantity() <= 0 ? 1 : item.getQuantity();
            ApiResponse<?> addResp = cartService.addToCart(
                    userId,
                    item.getGoodsId(),
                    item.getSkuId(),
                    quantity,
                    CartInfo.SOURCE_TYPE_COMBO,
                    packId,
                    "场景组合"
            );
            if (addResp.getCode() == null || addResp.getCode() != 200) {
                return addResp;
            }
        }
        return ApiResponse.success("组合已加入购物车", null);
    }

    private String normalizeSceneType(String scene) {
        String clean = scene == null ? "" : scene.trim();
        if ("小份量".equals(clean)) return "small_portion";
        if ("搭配".equals(clean)) return "combo_bundle";
        return "";
    }
}
