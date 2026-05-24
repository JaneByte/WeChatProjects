package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Goods;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;

@Component
public class CartPriceHelper {

    public boolean isFlashActive(CartInfo item) {
        if (item == null) return false;
        if (item.getIsFlash() == null || item.getIsFlash() != 1) return false;
        if (item.getFlashPrice() == null || item.getFlashPrice().compareTo(BigDecimal.ZERO) <= 0) return false;
        if (item.getFlashStock() == null || item.getFlashStock() <= 0) return false;
        LocalDateTime start = item.getFlashStartTime();
        LocalDateTime end = item.getFlashEndTime();
        if (start == null || end == null) return false;
        LocalDateTime now = LocalDateTime.now();
        return !now.isBefore(start) && !now.isAfter(end);
    }

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

    public BigDecimal resolveEffectivePrice(CartInfo item) {
        BigDecimal skuPrice = item.getPrice() == null ? BigDecimal.ZERO : item.getPrice();
        if (!isFlashActive(item)) return skuPrice;
        BigDecimal flashPrice = item.getFlashPrice() == null ? BigDecimal.ZERO : item.getFlashPrice();
        if (flashPrice.compareTo(BigDecimal.ZERO) <= 0) return skuPrice;
        return flashPrice.setScale(2, RoundingMode.HALF_UP);
    }
}
