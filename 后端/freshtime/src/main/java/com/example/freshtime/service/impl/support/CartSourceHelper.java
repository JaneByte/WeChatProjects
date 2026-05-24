package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.OrderInfo;
import org.springframework.stereotype.Component;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;

@Component
public class CartSourceHelper {

    public String normalizeSourceType(String sourceType) {
        String value = safeText(sourceType).toUpperCase();
        if (CartInfo.SOURCE_TYPE_FLASH.equals(value)
                || CartInfo.SOURCE_TYPE_MEAL.equals(value)
                || CartInfo.SOURCE_TYPE_COMBO.equals(value)
                || CartInfo.SOURCE_TYPE_SEASONAL.equals(value)
                || OrderInfo.ORDER_SOURCE_MIXED.equals(value)) {
            return value;
        }
        return CartInfo.SOURCE_TYPE_NORMAL;
    }

    public String mergeSourceType(String currentSourceType, String nextSourceType) {
        String current = normalizeSourceType(currentSourceType);
        String next = normalizeSourceType(nextSourceType);
        if (CartInfo.SOURCE_TYPE_NORMAL.equals(current)) return next;
        if (CartInfo.SOURCE_TYPE_NORMAL.equals(next) || current.equals(next)) return current;
        return OrderInfo.ORDER_SOURCE_MIXED;
    }

    public Long resolveSourcePlanId(Long currentSourcePlanId, Long nextSourcePlanId) {
        if (currentSourcePlanId == null || currentSourcePlanId <= 0) return nextSourcePlanId;
        if (nextSourcePlanId == null || nextSourcePlanId <= 0) return currentSourcePlanId;
        if (currentSourcePlanId.equals(nextSourcePlanId)) return currentSourcePlanId;
        return null;
    }

    public String resolveSourceScene(String currentSourceScene, String nextSourceScene) {
        String current = normalizeSourceScene(currentSourceScene);
        String next = normalizeSourceScene(nextSourceScene);
        if (current.isEmpty()) return next;
        if (next.isEmpty() || current.equals(next)) return current;
        return OrderInfo.ORDER_SOURCE_MIXED;
    }

    public String normalizeSourceScene(String sourceScene) {
        String text = safeText(sourceScene);
        if (text.isEmpty()) return "";
        try {
            String decoded = URLDecoder.decode(text, StandardCharsets.UTF_8.name()).trim();
            return decoded.isEmpty() ? text : decoded;
        } catch (Exception ignored) {
            return text;
        }
    }

    private String safeText(String text) {
        return text == null ? "" : text.trim();
    }
}
