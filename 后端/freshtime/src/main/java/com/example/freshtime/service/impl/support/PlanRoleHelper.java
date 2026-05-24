package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Category;
import com.example.freshtime.entity.Goods;

import java.util.Collections;
import java.util.Map;
import java.util.Set;

public final class PlanRoleHelper {

    private PlanRoleHelper() {}

    public static boolean roleMatched(Goods goods, String role, Map<Long, Category> categoryMap, String type, Set<String> tagCodes) {
        if (goods == null) return false;
        Category category = categoryMap == null ? null : categoryMap.get(goods.getCategoryId());
        if (category == null) {
            return fallbackRoleMatchByText(goods, role, type);
        }
        Long parentId = category.getParentId();
        String name = safe(category.getName(), "");
        String rootName = "";
        if (parentId != null && parentId > 0 && categoryMap != null) {
            Category parent = categoryMap.get(parentId);
            if (parent != null) {
                rootName = safe(parent.getName(), "");
            }
        }
        boolean isFruit = "水果".equals(rootName) || "水果".equals(name);
        boolean isVeg = "蔬菜".equals(rootName) || "蔬菜".equals(name);
        String text = safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "");
        Set<String> safeTagCodes = tagCodes == null ? Collections.emptySet() : tagCodes;

        if ("meal".equals(type)) {
            if ("fruit".equals(role)) {
                if (isFruit) return true;
                if (isVeg) return false;
                return fallbackRoleMatchByText(goods, role, type);
            }
            if ("veg".equals(role) || "main".equals(role) || "side".equals(role)) {
                if (isVeg) {
                    if ("veg".equals(role)) return isMealVegLike(text);
                    if ("main".equals(role)) return isMealMainLike(text);
                    if ("side".equals(role)) return isMealSideLike(text);
                }
                if (isFruit) return false;
                return fallbackRoleMatchByText(goods, role, type);
            }
        }

        if ("fruit".equals(role) && hasTag(safeTagCodes, "role_fruit")) return true;
        if ("main".equals(role) && hasTag(safeTagCodes, "role_main")) return true;
        if ("side".equals(role) && hasTag(safeTagCodes, "role_side")) return true;
        if ("base".equals(role) && hasTag(safeTagCodes, "role_base")) return true;
        if ("veg".equals(role) && hasTag(safeTagCodes, "role_veg")) return true;

        if ("fruit".equals(role)) return isFruit || isFruitLike(text);
        if ("main".equals(role)) return (isVeg && isMealMainLike(text)) || (!isFruit && isMealMainLike(text));
        if ("side".equals(role)) return (isVeg && isMealSideLike(text)) || (!isFruit && isMealSideLike(text));
        if ("base".equals(role)) return (isVeg && isComboBaseLike(text)) || (!isFruit && isComboBaseLike(text));
        if ("veg".equals(role)) {
            if ("combo".equals(type)) {
                return (isVeg && isComboVegLike(text)) || (!isFruit && isComboVegLike(text));
            }
            return isVeg && isMealVegLike(text);
        }
        return fallbackRoleMatchByText(goods, role, type);
    }

    public static String inferRoleByGoods(Goods goods, Map<Long, Category> categoryMap, String planType, Set<String> tagCodes) {
        if (roleMatched(goods, "fruit", categoryMap, planType, tagCodes)) return "fruit";
        if ("combo".equals(planType) && roleMatched(goods, "base", categoryMap, planType, tagCodes)) return "base";
        return roleMatched(goods, "veg", categoryMap, planType, tagCodes) ? "veg"
                : (roleMatched(goods, "main", categoryMap, planType, tagCodes) ? "main" : "side");
    }

    public static boolean isFruitLike(String text) {
        return safe(text, "").matches(".*(果|莓|苹果|橙|梨|葡萄|香蕉|桃|柠檬|樱桃|枇杷|瓜|菠萝|无花果|桑葚).*");
    }

    public static boolean isMealMainLike(String text) {
        return safe(text, "").matches(".*(菌|菇|番茄|土豆|南瓜|玉米|山药|红薯|芋头|胡萝卜|彩椒|豆腐|茄子).*");
    }

    public static boolean isMealSideLike(String text) {
        return safe(text, "").matches(".*(菜|生菜|菠菜|油麦|空心菜|西兰花|花菜|黄瓜|秋葵|豆角|荷兰豆|豌豆|毛豆|四季豆|笋|菜花|西葫芦|苦瓜).*");
    }

    public static boolean isMealVegLike(String text) {
        return isMealMainLike(text) || isMealSideLike(text);
    }

    public static boolean isComboBaseLike(String text) {
        return safe(text, "").matches(".*(番茄|黄瓜|胡萝卜|玉米|土豆|南瓜|山药|红薯|芋头|西兰花|菌|菇|苹果|橙|柠檬).*");
    }

    public static boolean isComboVegLike(String text) {
        return safe(text, "").matches(".*(菜|生菜|菠菜|油麦|空心菜|黄瓜|秋葵|荷兰豆|豌豆|毛豆|四季豆|豆角|西兰花|花菜|笋|西葫芦|苦瓜|番茄).*");
    }

    private static boolean fallbackRoleMatchByText(Goods goods, String role, String type) {
        String text = safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "");
        if ("fruit".equals(role)) return isFruitLike(text);
        if ("main".equals(role)) return isMealMainLike(text);
        if ("side".equals(role)) return isMealSideLike(text);
        if ("base".equals(role)) return isComboBaseLike(text);
        if ("veg".equals(role) && "meal".equals(type)) return isMealVegLike(text) && !isFruitLike(text);
        if ("veg".equals(role)) return isComboVegLike(text) && !isFruitLike(text);
        return true;
    }

    private static boolean hasTag(Set<String> tagCodes, String tagCode) {
        return tagCodes != null && tagCodes.contains(tagCode);
    }

    private static String safe(String text, String fallback) {
        if (text == null || text.trim().isEmpty()) return fallback;
        return text.trim();
    }
}
