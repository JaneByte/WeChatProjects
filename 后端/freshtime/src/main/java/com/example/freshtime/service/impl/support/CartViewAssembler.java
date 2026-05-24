package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.CartInfo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Component
public class CartViewAssembler {

    @Autowired
    private CartPriceHelper cartPriceHelper;

    @Autowired
    private CartSourceHelper cartSourceHelper;

    public Map<String, Object> buildCartItemRow(CartInfo item) {
        Map<String, Object> row = new HashMap<>();
        boolean flashActive = cartPriceHelper.isFlashActive(item);
        BigDecimal originPrice = item.getPrice() == null ? BigDecimal.ZERO : item.getPrice();
        BigDecimal effectivePrice = cartPriceHelper.resolveEffectivePrice(item);
        row.put("id", item.getId());
        row.put("goodsId", item.getGoodsId());
        row.put("skuId", item.getSkuId());
        row.put("name", item.getName());
        row.put("image", item.getImage());
        row.put("price", effectivePrice);
        row.put("originPrice", originPrice);
        row.put("priceType", flashActive ? CartInfo.SOURCE_TYPE_FLASH : CartInfo.SOURCE_TYPE_NORMAL);
        row.put("flashActive", flashActive);
        row.put("stock", item.getStock());
        row.put("unit", item.getUnit());
        row.put("skuName", item.getSkuName());
        row.put("skuWeightG", item.getSkuWeightG());
        row.put("skuText", buildSkuText(item));
        row.put("desc", item.getOrigin() == null ? "" : item.getOrigin());
        row.put("quantity", item.getQuantity());
        row.put("selected", item.getSelected() != null && item.getSelected() == 1);
        row.put("sourceType", cartSourceHelper.normalizeSourceType(item.getSourceType()));
        row.put("sourcePlanId", item.getSourcePlanId());
        row.put("sourceScene", cartSourceHelper.normalizeSourceScene(item.getSourceScene()));
        return row;
    }

    private String buildSkuText(CartInfo item) {
        String skuName = item.getSkuName() == null ? "" : item.getSkuName();
        Integer weight = item.getSkuWeightG();
        if (skuName.isEmpty() && weight == null) {
            return "";
        }
        if (weight == null || weight <= 0) {
            return skuName;
        }
        if (skuName.isEmpty()) {
            return weight + "g";
        }
        return skuName + " · " + weight + "g";
    }
}
