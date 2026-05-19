package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Goods;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Map;

public final class PlanPricingHelper {

    private PlanPricingHelper() {}

    public static BigDecimal calcPackDiscount(BigDecimal totalPrice, String planType, Map<String, String> config) {
        String prefix = "combo".equals(planType) ? "pack.combo." : "pack.meal.";
        BigDecimal rate = readBigDecimal(config, prefix + "discount_rate", "combo".equals(planType) ? "0.05" : "0.03");
        BigDecimal minDiscount = readBigDecimal(config, prefix + "min_discount", "combo".equals(planType) ? "2.00" : "1.00");
        BigDecimal maxDiscount = readBigDecimal(config, prefix + "max_discount", "combo".equals(planType) ? "12.00" : "8.00");
        BigDecimal discount = totalPrice.multiply(rate).setScale(2, RoundingMode.HALF_UP);
        if (discount.compareTo(minDiscount) < 0 && totalPrice.compareTo(minDiscount) > 0) {
            discount = minDiscount;
        }
        if (discount.compareTo(maxDiscount) > 0) {
            discount = maxDiscount;
        }
        if (discount.compareTo(totalPrice) >= 0) {
            return BigDecimal.ZERO.setScale(2, RoundingMode.HALF_UP);
        }
        return discount.setScale(2, RoundingMode.HALF_UP);
    }

    public static String buildCouponHint(BigDecimal totalPrice, BigDecimal savedAmount, BigDecimal threshold) {
        String savingsText = savedAmount.compareTo(BigDecimal.ZERO) > 0
                ? ("当前方案已比单买省 ¥" + savedAmount.setScale(2, RoundingMode.HALF_UP))
                : "当前方案暂无额外套餐直降";
        if (totalPrice.compareTo(threshold) >= 0) {
            return savingsText + "，且满足满" + threshold.stripTrailingZeros().toPlainString() + "门槛，可叠加用券";
        }
        return savingsText + "，建议凑单到满" + threshold.stripTrailingZeros().toPlainString() + "更划算";
    }

    public static BigDecimal resolveOriginalPrice(Goods goods, BigDecimal price, String planType) {
        BigDecimal baseOriginal = safePrice(goods == null ? null : goods.getOriginalPrice(), BigDecimal.ZERO);
        BigDecimal basePrice = safePrice(price, BigDecimal.ZERO);
        if (baseOriginal.compareTo(basePrice) > 0) {
            return baseOriginal;
        }
        BigDecimal upliftRate = "combo".equals(planType) ? new BigDecimal("1.06") : new BigDecimal("1.04");
        return basePrice.multiply(upliftRate).setScale(2, RoundingMode.HALF_UP);
    }

    private static BigDecimal readBigDecimal(Map<String, String> config, String key, String fallback) {
        String raw = config == null ? "" : config.getOrDefault(key, fallback);
        try {
            return new BigDecimal(raw).setScale(2, RoundingMode.HALF_UP);
        } catch (Exception ignored) {
            return new BigDecimal(fallback).setScale(2, RoundingMode.HALF_UP);
        }
    }

    private static BigDecimal safePrice(BigDecimal value, BigDecimal fallback) {
        return value == null ? fallback : value;
    }
}
