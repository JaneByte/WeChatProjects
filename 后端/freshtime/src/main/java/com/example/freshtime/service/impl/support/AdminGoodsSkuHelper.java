package com.example.freshtime.service.impl.support;

import com.example.freshtime.dto.admin.AdminGoodsSaveRequest;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.GoodsSkuMapper;
import com.example.freshtime.mapper.OrderMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Component
public class AdminGoodsSkuHelper {

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private GoodsSkuMapper goodsSkuMapper;

    @Autowired
    private GoodsMapper goodsMapper;

    public Map<Long, Integer> buildSkuSalesMap() {
        Map<Long, Integer> result = new HashMap<>();
        List<Map<String, Object>> rows = orderMapper.selectPaidSkuSalesSummary();
        if (rows == null || rows.isEmpty()) {
            return result;
        }
        for (Map<String, Object> row : rows) {
            if (row == null) continue;
            Long skuId = toLong(row.get("skuId"));
            Integer salesVolume = toInteger(row.get("salesVolume"));
            if (skuId == null) continue;
            result.put(skuId, salesVolume == null ? 0 : salesVolume);
        }
        return result;
    }

    public String validateSkuList(List<AdminGoodsSaveRequest.SkuItem> skuList) {
        if (skuList == null || skuList.isEmpty()) {
            return "";
        }
        Set<String> duplicateKeys = new HashSet<>();
        for (int i = 0; i < skuList.size(); i++) {
            AdminGoodsSaveRequest.SkuItem item = skuList.get(i);
            int index = i + 1;
            if (item == null) {
                return "第" + index + "个规格数据无效";
            }
            String skuName = trim(item.getSkuName());
            if (skuName.isEmpty()) {
                return "规格名称不能为空";
            }
            if (item.getSkuWeightG() == null || item.getSkuWeightG() <= 0) {
                return "规格重量必须大于0";
            }
            if (item.getSkuPrice() == null || item.getSkuPrice().compareTo(BigDecimal.ZERO) < 0) {
                return "规格价格不能为空且不能小于0";
            }
            if (item.getSkuStock() == null || item.getSkuStock() < 0) {
                return "规格库存不能小于0";
            }
            String duplicateKey = skuName + "#" + item.getSkuWeightG();
            if (!duplicateKeys.add(duplicateKey)) {
                return "同一商品下存在重复规格，请检查规格名称和重量";
            }
        }
        return "";
    }

    public void syncGoodsSkuList(Goods goods, List<AdminGoodsSaveRequest.SkuItem> skuList) {
        if (goods == null || goods.getId() == null) {
            return;
        }
        if (skuList == null) {
            return;
        }
        if (skuList.isEmpty()) {
            goodsSkuMapper.deleteByGoodsId(goods.getId());
            return;
        }
        List<Long> keepIds = new ArrayList<>();
        int activeSkuStockTotal = 0;
        int sort = 1;
        for (AdminGoodsSaveRequest.SkuItem item : skuList) {
            if (item == null) continue;
            GoodsSku sku = new GoodsSku();
            sku.setId(item.getId());
            sku.setGoodsId(goods.getId());
            sku.setSkuName(trim(item.getSkuName()));
            sku.setSkuWeightG(item.getSkuWeightG());
            sku.setSkuPrice(item.getSkuPrice());
            sku.setSkuStock(defaultInt(item.getSkuStock()));
            sku.setStatus(item.getStatus() == null ? 1 : item.getStatus());
            sku.setSort(item.getSort() == null ? sort : item.getSort());
            sku.setSpecType("weight");
            sku.setSpecValue(String.valueOf(item.getSkuWeightG()));
            if (sku.getId() == null) {
                goodsSkuMapper.insert(sku);
            } else {
                goodsSkuMapper.update(sku);
            }
            if (sku.getId() != null) {
                keepIds.add(sku.getId());
            }
            if (sku.getStatus() != null && sku.getStatus() == 1) {
                activeSkuStockTotal += defaultInt(sku.getSkuStock());
            }
            sort += 1;
        }
        if (keepIds.isEmpty()) {
            goodsSkuMapper.deleteByGoodsId(goods.getId());
            return;
        }
        goodsSkuMapper.deleteByGoodsIdAndExcludeIds(goods.getId(), keepIds);
        goodsMapper.updateGoodsStock(goods.getId(), activeSkuStockTotal);
    }

    private String trim(String text) {
        return text == null ? "" : text.trim();
    }

    private Integer defaultInt(Integer value) {
        return value == null ? 0 : value;
    }

    private Long toLong(Object value) {
        if (value instanceof Long) return (Long) value;
        if (value instanceof Integer) return ((Integer) value).longValue();
        if (value instanceof java.math.BigInteger) return ((java.math.BigInteger) value).longValue();
        if (value instanceof java.math.BigDecimal) return ((java.math.BigDecimal) value).longValue();
        if (value == null) return null;
        String text = String.valueOf(value).trim();
        if (text.isEmpty()) return null;
        try {
            return Long.parseLong(text);
        } catch (NumberFormatException ignored) {
            return null;
        }
    }

    private Integer toInteger(Object value) {
        if (value instanceof Integer) return (Integer) value;
        if (value instanceof Long) return ((Long) value).intValue();
        if (value instanceof java.math.BigInteger) return ((java.math.BigInteger) value).intValue();
        if (value instanceof java.math.BigDecimal) return ((java.math.BigDecimal) value).intValue();
        if (value == null) return null;
        String text = String.valueOf(value).trim();
        if (text.isEmpty()) return null;
        try {
            return Integer.parseInt(text);
        } catch (NumberFormatException ignored) {
            return null;
        }
    }
}
