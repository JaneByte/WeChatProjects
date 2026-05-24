package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Goods;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class GoodsCardAssembler {

    @Autowired
    private GoodsSkuAssembler goodsSkuAssembler;

    @Autowired
    private GoodsSceneHelper goodsSceneHelper;

    public List<Map<String, Object>> buildGoodsCardList(List<Goods> list) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (list == null || list.isEmpty()) {
            return result;
        }
        for (Goods goods : list) {
            if (goods == null) continue;
            result.add(buildBaseGoodsRow(goods, true));
        }
        return result;
    }

    public List<Map<String, Object>> buildSceneGoodsList(String scene, List<Goods> list) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (list == null || list.isEmpty()) {
            return result;
        }
        for (Goods goods : list) {
            Map<String, Object> row = buildBaseGoodsRow(goods, false);
            row.put("sceneType", goodsSceneHelper.resolveSceneType(scene, goods));
            row.put("comboMode", goodsSceneHelper.resolveComboMode(scene, goods));
            row.put("packType", goodsSceneHelper.resolvePackType(scene, goods));
            row.put("couponThresholdHint", goodsSceneHelper.resolveCouponThresholdHint(scene, goods));
            row.put("skuList", goodsSkuAssembler.buildSkuViewList(goods));
            result.add(row);
        }
        return result;
    }

    public Map<String, Object> buildGoodsDetailView(Goods goods) {
        Map<String, Object> data = buildBaseGoodsRow(goods, true);
        data.put("skuList", goodsSkuAssembler.buildSkuViewList(goods));
        return data;
    }

    private Map<String, Object> buildBaseGoodsRow(Goods goods, boolean includeImagesAndDetail) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", goods.getId());
        row.put("categoryId", goods.getCategoryId());
        row.put("name", goods.getName());
        row.put("mainImage", goods.getMainImage());
        if (includeImagesAndDetail) {
            row.put("images", goods.getImages());
            row.put("detail", goods.getDetail());
        }
        row.put("price", goods.getPrice());
        row.put("originalPrice", goods.getOriginalPrice());
        row.put("stock", goods.getStock());
        row.put("unit", goods.getUnit());
        row.put("salesVolume", goods.getSalesVolume());
        row.put("isFlash", goods.getIsFlash());
        row.put("flashPrice", goods.getFlashPrice());
        row.put("flashStartTime", goods.getFlashStartTime());
        row.put("flashEndTime", goods.getFlashEndTime());
        row.put("flashStock", goods.getFlashStock());
        row.put("status", goods.getStatus());
        row.put("origin", goods.getOrigin());
        row.put("keywords", goods.getKeywords());
        if (includeImagesAndDetail) {
            row.put("skuList", goodsSkuAssembler.buildSkuViewList(goods));
        }
        return row;
    }
}
