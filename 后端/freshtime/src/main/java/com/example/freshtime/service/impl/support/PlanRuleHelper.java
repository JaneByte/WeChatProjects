package com.example.freshtime.service.impl.support;

import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public final class PlanRuleHelper {

    private PlanRuleHelper() {}

    public static List<String> readRuleList(Map<String, String> runtimeConfig, Map<String, String> defaultConfig, String ruleKey) {
        String raw = runtimeConfig.getOrDefault(ruleKey, defaultConfig.getOrDefault(ruleKey, ""));
        if (raw == null || raw.trim().isEmpty()) return Collections.emptyList();
        return Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    public static boolean containsAnyKeyword(String text, List<String> keywords) {
        if (text == null || text.isEmpty() || keywords == null || keywords.isEmpty()) return false;
        for (String keyword : keywords) {
            if (!keyword.isEmpty() && text.contains(keyword.toLowerCase())) return true;
        }
        return false;
    }

    public static boolean hasConfiguredConflict(String a, String b, List<String> pairs) {
        if (pairs == null || pairs.isEmpty()) return false;
        for (String pair : pairs) {
            String[] parts = pair.split("\\|");
            if (parts.length != 2) continue;
            String left = parts[0].trim().toLowerCase();
            String right = parts[1].trim().toLowerCase();
            if (left.isEmpty() || right.isEmpty()) continue;
            boolean match = (a.contains(left) && b.contains(right)) || (a.contains(right) && b.contains(left));
            if (match) return true;
        }
        return false;
    }

    public static boolean shareKeyword(String a, String b, String keyword) {
        return a.contains(keyword) && b.contains(keyword);
    }

    public static boolean isSimilarProduceFamily(String a, String b) {
        return shareKeyword(a, b, "苹果")
                || shareKeyword(a, b, "番茄")
                || shareKeyword(a, b, "西红柿")
                || shareKeyword(a, b, "圣女果")
                || shareKeyword(a, b, "黄瓜")
                || shareKeyword(a, b, "小黄瓜")
                || shareKeyword(a, b, "土豆")
                || shareKeyword(a, b, "小土豆")
                || shareKeyword(a, b, "胡萝卜")
                || shareKeyword(a, b, "baby胡萝卜")
                || shareKeyword(a, b, "青苹果")
                || shareKeyword(a, b, "草莓")
                || shareKeyword(a, b, "蓝莓")
                || shareKeyword(a, b, "香蕉")
                || shareKeyword(a, b, "梨")
                || shareKeyword(a, b, "香梨")
                || shareKeyword(a, b, "橙")
                || shareKeyword(a, b, "柠檬");
    }

    public static Map<String, String> buildDefaultPlanRules() {
        Map<String, String> config = new HashMap<>();
        config.put("plan.global_blacklist_keywords", "");
        config.put("plan.global_exclude_tags", "exclude_plan");
        config.put("plan.juice_blacklist_keywords", "蒜,洋葱,大葱,香葱,韭菜,辣椒");
        config.put("plan.salad_blacklist_keywords", "榴莲,菠萝蜜,蒜苗,大葱,洋葱");
        config.put("plan.hotpot_blacklist_keywords", "鲜切即食,果切杯,即食水果杯");
        config.put("plan.bento_blacklist_keywords", "鲜切即食,果切杯,即食水果杯");
        config.put("plan.meal_satiety_keywords", "土豆,南瓜,玉米,红薯,芋头,山药,香蕉");
        config.put("plan.meal_high_fiber_keywords", "西兰花,芹菜,秋葵,菜花,菠菜,油麦菜,西芹,芦笋");
        config.put("plan.meal_refreshing_keywords", "黄瓜,番茄,生菜,西红柿,圣女果,苹果,橙,柠檬");
        config.put("plan.meal_strong_flavor_keywords", "洋葱,大葱,蒜,韭菜,蒜苗,苦瓜");
        config.put("plan.juice_priority_keywords", "橙,苹果,胡萝卜,番茄,柠檬");
        config.put("plan.salad_priority_keywords", "生菜,黄瓜,番茄,牛油果,苹果,蓝莓");
        config.put("plan.hotpot_priority_keywords", "菠菜,生菜,油麦菜,金针菇,香菇,土豆,玉米,豆腐");
        config.put("plan.bento_priority_keywords", "西兰花,胡萝卜,玉米,秋葵,菜花,菌菇");
        config.put("plan.watery_fruit_keywords", "西瓜,哈密瓜,香瓜,椰青,柚子");
        config.put("plan.meal_conflict_pairs", "");
        config.put("plan.juice_conflict_pairs", "黄瓜|香蕉,番茄|香蕉");
        config.put("plan.salad_conflict_pairs", "土豆|西瓜,洋葱|草莓");
        config.put("plan.hotpot_conflict_pairs", "");
        config.put("plan.bento_conflict_pairs", "");
        config.put("plan.general_conflict_pairs", "榴莲|柠檬");
        return config;
    }
}
