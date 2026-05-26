package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Set;
import java.util.function.Function;

public final class PlanScoringHelper {

    private PlanScoringHelper() {}

    public static int scoreMealGoods(
            Goods goods,
            String role,
            BigDecimal budgetMin,
            BigDecimal budgetMax,
            String dietGoal,
            String cookMode,
            boolean preferSatiety,
            int salesWeight,
            int stockWeight,
            int budgetWeight,
            boolean roleMatched,
            Set<String> tagCodes,
            Function<Goods, BigDecimal> availablePriceSupplier,
            Function<String, Integer> mealPortionFitSupplier,
            Function<ScoreConstraintInput, Integer> commonConstraintSupplier
    ) {
        int score = 0;
        BigDecimal price = availablePriceSupplier.apply(goods);
        if (price != null && price.compareTo(budgetMin.divide(new BigDecimal("3"), 2, RoundingMode.HALF_UP)) >= 0 && price.compareTo(budgetMax) <= 0) {
            score += budgetWeight;
        }
        score += Math.min(safeInt(goods == null ? null : goods.getSalesVolume()) / 80, salesWeight);
        score += Math.min(safeInt(goods == null ? null : goods.getStock()) / 30, stockWeight);
        String text = safe(goods == null ? null : goods.getName(), "") + "," + safe(goods == null ? null : goods.getKeywords(), "") + "," + safe(goods == null ? null : goods.getOrigin(), "");
        if ("high_fiber".equals(dietGoal) && hasTag(tagCodes, "diet_high_fiber")) score += 18;
        if ("light".equals(dietGoal) && hasTag(tagCodes, "diet_light")) score += 18;
        if ("balanced".equals(dietGoal) && hasTag(tagCodes, "diet_high_fiber")) score += 8;
        if ("balanced".equals(dietGoal) && hasTag(tagCodes, "diet_light")) score += 8;
        if ("main".equals(role) && hasTag(tagCodes, "role_main")) score += 18;
        if ("side".equals(role) && hasTag(tagCodes, "role_side")) score += 18;
        if ("fruit".equals(role) && hasTag(tagCodes, "role_fruit")) score += 18;
        if ("high_fiber".equals(dietGoal) && !hasTag(tagCodes, "diet_high_fiber") && text.matches(".*(菜|豆|麦|菌|瓜|芹|秋葵|西兰花).*")) score += 10;
        if ("light".equals(dietGoal) && !hasTag(tagCodes, "diet_light") && text.matches(".*(生菜|黄瓜|番茄|蓝莓|苹果|橙|柠檬).*")) score += 12;
        if ("balanced".equals(dietGoal) && text.matches(".*(生菜|黄瓜|番茄|西兰花|胡萝卜|苹果|橙|玉米).*")) score += 10;
        if (preferSatiety) {
            boolean starchyLike = text.matches(".*(土豆|南瓜|玉米|山药|红薯|芋头|莲藕|芡实|板栗|紫薯|贝贝南瓜).*");
            boolean mushroomLike = text.matches(".*(菌|菇).*");
            boolean satietyLike = text.matches(".*(番茄|胡萝卜|彩椒|豆腐|茄子).*");
            int roleMainBonus = "light".equals(dietGoal) ? 10 : ("balanced".equals(dietGoal) ? 18 : 26);
            int satietyTagBonus = "light".equals(dietGoal) ? 8 : ("balanced".equals(dietGoal) ? 14 : 22);
            int starchyBonus = "light".equals(dietGoal) ? 4 : ("balanced".equals(dietGoal) ? 10 : 20);
            int satietyLikeBonus = "light".equals(dietGoal) ? 2 : ("balanced".equals(dietGoal) ? 6 : 8);
            int mushroomBonus = "light".equals(dietGoal) ? 1 : ("balanced".equals(dietGoal) ? 3 : 4);
            if (hasTag(tagCodes, "role_main")) score += roleMainBonus;
            if (hasTag(tagCodes, "nutrition_satiety")) score += satietyTagBonus;
            if (starchyLike) score += starchyBonus;
            else if (satietyLike) score += satietyLikeBonus;
            else if (mushroomLike) score += mushroomBonus;
            if ("light".equals(dietGoal) && (starchyLike || hasTag(tagCodes, "nutrition_satiety"))) score -= 10;
            if ("balanced".equals(dietGoal) && starchyLike) score -= 2;
        }
        score += scoreCookModeFit(goods, role, cookMode);
        score += safeInt(mealPortionFitSupplier.apply(role));
        score += safeInt(commonConstraintSupplier.apply(new ScoreConstraintInput(goods, role, role)));
        if (roleMatched) score += 25;
        return score;
    }

    public static int scoreComboGoods(
            Goods goods,
            String goalScene,
            String role,
            String peopleCount,
            String tastePref,
            boolean preferSatiety,
            int salesWeight,
            int stockWeight,
            boolean roleMatched,
            boolean sceneTagged,
            boolean mixTagged,
            Function<ScoreConstraintInput, Integer> commonConstraintSupplier,
            Function<String, Integer> peopleCountFitSupplier,
            Set<String> tagCodes
    ) {
        int score = 0;
        score += Math.min(safeInt(goods == null ? null : goods.getSalesVolume()) / 100, salesWeight);
        score += Math.min(safeInt(goods == null ? null : goods.getStock()) / 40, stockWeight);
        if (sceneTagged) score += 20;
        if ("salad".equals(goalScene) && mixTagged) score += 8;
        if ("juice".equals(goalScene) && mixTagged) score += 8;
        if ("hotpot".equals(goalScene) && mixTagged) score += 8;
        if ("bento_side".equals(goalScene) && mixTagged) score += 8;
        if (preferSatiety) {
            if (hasTag(tagCodes, "role_main")) score += 8;
            else if (hasTag(tagCodes, "role_base")) score += 6;
        }
        score += scoreComboSceneFit(goods, goalScene, role);
        score += scoreTastePreference(goods, goalScene, role, tastePref);
        score += safeInt(peopleCountFitSupplier.apply(peopleCount));
        score += safeInt(commonConstraintSupplier.apply(new ScoreConstraintInput(goods, role, goalScene)));
        if (roleMatched) score += 25;
        return score;
    }

    public static int scoreMealPortionFit(GoodsSku sku, String role) {
        if (sku == null || sku.getSkuWeightG() == null) return 0;
        int weight = sku.getSkuWeightG();
        if ("main".equals(role)) {
            if (weight >= 260 && weight <= 420) return 14;
            if (weight > 500) return -10;
        }
        if ("side".equals(role)) {
            if (weight >= 180 && weight <= 320) return 12;
            if (weight > 420) return -8;
        }
        if ("fruit".equals(role)) {
            if (weight >= 120 && weight <= 260) return 12;
            if (weight > 360) return -8;
        }
        return 0;
    }

    public static int scorePeopleCountFit(GoodsSku sku, int serving) {
        if (sku == null || sku.getSkuWeightG() == null) return 0;
        int weight = sku.getSkuWeightG();
        if (serving <= 1) {
            if (weight <= 320) return 8;
            if (weight > 520) return -8;
            return 0;
        }
        if (serving == 2) {
            if (weight >= 280 && weight <= 520) return 10;
            if (weight < 220) return -6;
            return 0;
        }
        if (weight >= 420) return 12;
        return -6;
    }

    public static int scoreCookModeFit(Goods goods, String role, String cookMode) {
        String text = (safe(goods == null ? null : goods.getName(), "") + "," + safe(goods == null ? null : goods.getKeywords(), "")).toLowerCase();
        if ("no_cook".equals(cookMode)) {
            if ("fruit".equals(role) && PlanRoleHelper.isFruitLike(text)) return 10;
            if (text.matches(".*(生菜|黄瓜|番茄|蓝莓|草莓|苹果|橙|圣女果).*")) return 10;
            if (text.matches(".*(土豆|南瓜|芋头|山药|毛豆|四季豆).*")) return -8;
        }
        if ("quick_cook".equals(cookMode)) {
            if (text.matches(".*(西兰花|胡萝卜|菌|菇|玉米|番茄|荷兰豆|秋葵).*")) return 8;
        }
        return 0;
    }

    public static int scoreComboSceneFit(Goods goods, String goalScene, String role) {
        String text = (safe(goods == null ? null : goods.getName(), "") + "," + safe(goods == null ? null : goods.getKeywords(), "")).toLowerCase();
        if ("juice".equals(goalScene)) {
            if (text.matches(".*(榨|汁用|柠檬|橙|苹果|胡萝卜|番茄).*")) return 12;
            if (text.matches(".*(火锅|耐煮).*")) return -10;
        }
        if ("hotpot".equals(goalScene)) {
            if (text.matches(".*(耐煮|菌|菜|豆腐|番茄|土豆|玉米|蘑菇).*")) return 12;
            if ("fruit".equals(role) && text.matches(".*(榴莲|椰子).*")) return -10;
        }
        if ("salad".equals(goalScene)) {
            if (text.matches(".*(生菜|黄瓜|番茄|蓝莓|草莓|苹果|牛油果|紫甘蓝|羽衣甘蓝).*")) return 14;
            if (text.matches(".*(脆|爽|即食|沙拉|油醋|冷拌).*")) return 8;
            if (text.matches(".*(土豆|南瓜|玉米|芋头|山药).*")) return -10;
            if (text.matches(".*(耐煮|久煮|火锅|炖煮).*")) return -10;
        }
        if ("bento_side".equals(goalScene)) {
            if (text.matches(".*(西兰花|胡萝卜|玉米|秋葵|菜花|菌菇|芦笋|荷兰豆).*")) return 14;
            if (text.matches(".*(便当|耐放|焯水|分装|快手).*")) return 8;
            if (text.matches(".*(多汁|鲜切即食|果切|沙拉|榨汁).*")) return -10;
        }
        return 0;
    }

    public static int scoreTastePreference(Goods goods, String goalScene, String role, String tastePref) {
        String text = (safe(goods == null ? null : goods.getName(), "") + "," + safe(goods == null ? null : goods.getKeywords(), "")).toLowerCase();
        if ("sweet".equals(tastePref)) {
            if ("fruit".equals(role) && text.matches(".*(草莓|蓝莓|葡萄|橙|苹果|桃|瓜|樱桃|梨).*")) return 10;
            if ("juice".equals(goalScene) && text.matches(".*(橙|苹果|胡萝卜|番茄).*")) return 6;
        }
        if ("crisp".equals(tastePref)) {
            if (text.matches(".*(脆|爽|黄瓜|苹果|梨|胡萝卜|生菜).*")) return 8;
        }
        if ("fresh".equals(tastePref)) {
            if (text.matches(".*(生菜|黄瓜|番茄|蓝莓|草莓|柠檬|橙).*")) return 8;
        }
        return 0;
    }

    private static boolean hasTag(Set<String> tagCodes, String tagCode) {
        return tagCodes != null && tagCodes.contains(tagCode);
    }

    private static int safeInt(Integer value) {
        return value == null ? 0 : value;
    }

    private static String safe(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) return fallback;
        return value.trim();
    }

    public static final class ScoreConstraintInput {
        private final Goods goods;
        private final String role;
        private final String sceneKey;

        public ScoreConstraintInput(Goods goods, String role, String sceneKey) {
            this.goods = goods;
            this.role = role;
            this.sceneKey = sceneKey;
        }

        public Goods getGoods() {
            return goods;
        }

        public String getRole() {
            return role;
        }

        public String getSceneKey() {
            return sceneKey;
        }
    }
}
