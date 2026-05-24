package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

@Component
public class OrderPriceHelper {

    public boolean isFlashActive(Goods goods) {
        if (goods == null) return false;
        if (goods.getIsFlash() == null || goods.getIsFlash() != 1) return false;
        if (goods.getFlashPrice() == null || goods.getFlashPrice().compareTo(BigDecimal.ZERO) <= 0) return false;
        if (goods.getFlashStock() == null || goods.getFlashStock() <= 0) return false;
        LocalDateTime start = goods.getFlashStartTime();
        LocalDateTime end = goods.getFlashEndTime();
        if (start == null || end == null) return false;
        LocalDateTime now = LocalDateTime.now();
        return !now.isBefore(start) && !now.isAfter(end);
    }

    public BigDecimal resolveEffectivePrice(Goods goods, GoodsSku sku) {
        BigDecimal skuPrice = sku.getSkuPrice() == null ? BigDecimal.ZERO : sku.getSkuPrice();
        if (!isFlashActive(goods)) return skuPrice;
        BigDecimal flashPrice = goods.getFlashPrice() == null ? BigDecimal.ZERO : goods.getFlashPrice();
        if (flashPrice.compareTo(BigDecimal.ZERO) <= 0) return skuPrice;
        return flashPrice.setScale(2, RoundingMode.HALF_UP);
    }
}
