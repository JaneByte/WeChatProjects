package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import org.springframework.stereotype.Component;

import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Component
public class OrderSourceHelper {

    public String normalizeSourceType(String sourceType) {
        String value = safeText(sourceType).toUpperCase();
        if (OrderInfo.ORDER_SOURCE_MEAL.equals(value)
                || OrderInfo.ORDER_SOURCE_FLASH.equals(value)
                || OrderInfo.ORDER_SOURCE_COMBO.equals(value)
                || OrderInfo.ORDER_SOURCE_SEASONAL.equals(value)
                || OrderInfo.ORDER_SOURCE_MIXED.equals(value)) {
            return value;
        }
        return OrderInfo.ORDER_SOURCE_NORMAL;
    }

    public String resolveOrderSource(List<OrderItemInfo> orderItems) {
        String current = "";
        for (OrderItemInfo item : orderItems) {
            String sourceType = normalizeSourceType(item.getSourceType());
            if (current.isEmpty()) {
                current = sourceType;
                continue;
            }
            if (!current.equals(sourceType)) {
                return OrderInfo.ORDER_SOURCE_MIXED;
            }
        }
        return current.isEmpty() ? OrderInfo.ORDER_SOURCE_NORMAL : current;
    }

    public String resolveItemSourceType(String sourceType, boolean flashActive) {
        String normalized = normalizeSourceType(sourceType);
        if (flashActive && OrderInfo.ORDER_SOURCE_NORMAL.equals(normalized)) {
            return OrderInfo.ORDER_SOURCE_FLASH;
        }
        return normalized;
    }

    public String resolveItemSourceScene(String sourceScene, boolean flashActive) {
        String normalized = normalizeSourceScene(sourceScene);
        if (flashActive && normalized.isEmpty()) {
            return "限时秒杀";
        }
        return normalized;
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

    private String safeText(String value) {
        return value == null ? "" : value.trim();
    }
}
