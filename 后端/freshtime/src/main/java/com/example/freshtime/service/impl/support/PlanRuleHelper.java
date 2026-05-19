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
                || shareKeyword(a, b, "黄瓜")
                || shareKeyword(a, b, "土豆")
                || shareKeyword(a, b, "胡萝卜")
                || shareKeyword(a, b, "草莓")
                || shareKeyword(a, b, "蓝莓");
    }

    public static Map<String, String> buildDefaultPlanRules() {
        Map<String, String> config = new HashMap<>();
        config.put("plan.strong_flavor_keywords", "洋葱,大葱,蒜,韭菜,蒜苗,苦瓜");
        config.put("plan.juice_blacklist_keywords", "蒜,洋葱,大葱,香葱,韭菜,辣椒");
        config.put("plan.salad_blacklist_keywords", "榴莲,菠萝蜜,蒜苗,大葱,洋葱");
        config.put("plan.hotpot_blacklist_keywords", "鲜切即食,果切杯,即食水果杯");
        config.put("plan.starchy_keywords", "土豆,南瓜,玉米,红薯,芋头,山药,香蕉");
        config.put("plan.watery_fruit_keywords", "西瓜,哈密瓜,香瓜,椰青,柚子");
        config.put("plan.juice_conflict_pairs", "黄瓜|香蕉,番茄|香蕉");
        config.put("plan.salad_conflict_pairs", "土豆|西瓜,洋葱|草莓");
        config.put("plan.general_conflict_pairs", "榴莲|柠檬");
        return config;
    }
}
