package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.mapper.GoodsSkuMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class GoodsSkuAssembler {

    @Autowired
    private GoodsSkuMapper goodsSkuMapper;

    public List<Map<String, Object>> buildSkuViewList(Goods goods) {
        List<GoodsSku> skuList = goodsSkuMapper.selectListByGoodsId(goods.getId());
        List<Map<String, Object>> result = new ArrayList<>();
        if (skuList == null || skuList.isEmpty()) {
            result.add(buildVirtualSku(goods));
            return result;
        }
        for (GoodsSku sku : skuList) {
            result.add(buildSkuView(goods, sku));
        }
        return result;
    }

    private Map<String, Object> buildVirtualSku(Goods goods) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", null);
        row.put("goodsId", goods.getId());
        row.put("skuName", "标准装");
        row.put("skuWeightG", 500);
        row.put("skuPrice", goods.getPrice());
        row.put("skuStock", goods.getStock());
        row.put("status", 1);
        row.put("sort", 0);
        return row;
    }

    private Map<String, Object> buildSkuView(Goods goods, GoodsSku sku) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", sku.getId());
        row.put("goodsId", goods.getId());
        row.put("skuName", sku.getSkuName());
        row.put("skuWeightG", sku.getSkuWeightG());
        row.put("skuPrice", sku.getSkuPrice());
        row.put("skuStock", sku.getSkuStock());
        row.put("status", sku.getStatus());
        row.put("sort", sku.getSort());
        row.put("specType", sku.getSpecType());
        row.put("specValue", sku.getSpecValue());
        return row;
    }
}
