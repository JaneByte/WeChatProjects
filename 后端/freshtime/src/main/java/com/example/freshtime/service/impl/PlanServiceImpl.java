package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.AddPlanToCartRequest;
import com.example.freshtime.dto.GenerateComboPlanRequest;
import com.example.freshtime.dto.GenerateMealPlanRequest;
import com.example.freshtime.dto.ReplacePlanItemRequest;
import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Category;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.mapper.CartMapper;
import com.example.freshtime.mapper.CategoryMapper;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.GoodsSkuMapper;
import com.example.freshtime.mapper.GoodsTagMapper;
import com.example.freshtime.mapper.PackPricingRuleMapper;
import com.example.freshtime.mapper.PlanRuleConfigMapper;
import com.example.freshtime.service.PlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ThreadLocalRandom;
import java.util.stream.Collectors;

@Service
public class PlanServiceImpl implements PlanService {

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private GoodsSkuMapper goodsSkuMapper;

    @Autowired
    private CartMapper cartMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private GoodsTagMapper goodsTagMapper;

    @Autowired
    private PlanRuleConfigMapper planRuleConfigMapper;

    @Autowired
    private PackPricingRuleMapper packPricingRuleMapper;

    private Map<Long, Set<String>> goodsTagCodeMapCache = Collections.emptyMap();
    private static final Map<String, String> DEFAULT_PLAN_RULES = buildDefaultPlanRules();
    private static final Map<String, String> DEFAULT_PACK_PRICING_RULES = buildDefaultPackPricingRules();

    @Override
    public ApiResponse<?> generateMealPlan(Long userId, GenerateMealPlanRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("请求参数不能为空");
        }

        String budgetLevel = safe(request.getBudgetLevel(), "standard");
        String dietGoal = safe(request.getDietGoal(), "balanced");
        String mealType = safe(request.getMealType(), "dinner");
        Long shuffleSeed = request.getShuffleSeed();
        String cookMode = safe(request.getCookMode(), "quick_cook");

        WeightProfile profile = resolveWeightProfile("meal");
        BudgetRange budget = resolveBudgetRange(budgetLevel, "meal");
        List<Goods> allPool = filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), null);
        List<Goods> pool = filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), request.getDislikeTags());
        List<String> warnings = new ArrayList<>();
        if (pool.size() < 3) {
            pool = allPool;
            warnings.add("忌口条件较严格，已放宽过滤并返回最接近方案");
        }
        if (pool.size() < 3) {
            return ApiResponse.badRequest("可用商品不足，暂无法生成方案");
        }
        prepareTagCache(pool);

        Map<Long, Category> categoryMap = loadCategoryMap();
        Goods mainGoods = pickBestMealGoods(pool, categoryMap, "main", budget, dietGoal, cookMode, profile, userId, shuffleSeed, null);
        Goods sideGoods = pickBestMealGoods(pool, categoryMap, "side", budget, dietGoal, cookMode, profile, userId, shuffleSeed, mainGoods == null ? null : mainGoods.getId());
        Goods fruitGoods = pickBestMealGoods(pool, categoryMap, "fruit", budget, dietGoal, cookMode, profile, userId, shuffleSeed, sideGoods == null ? (mainGoods == null ? null : mainGoods.getId()) : sideGoods.getId(), mainGoods == null ? null : mainGoods.getId());

        if (mainGoods == null || sideGoods == null || fruitGoods == null) {
            return ApiResponse.badRequest("未找到满足条件的一人食组合，请调整偏好后重试");
        }

        List<PlanItem> items = new ArrayList<>();
        items.add(buildPlanItem(mainGoods, "main", "主菜：优先饱腹与口味稳定", "meal"));
        items.add(buildPlanItem(sideGoods, "side", "配菜：提升纤维与均衡度", "meal"));
        items.add(buildPlanItem(fruitGoods, "fruit", "水果：补充维生素，减轻油腻感", "meal"));

        items = enforceBudget(items, pool, categoryMap, budget, "meal", dietGoal, profile, userId);
        BigDecimal totalPrice = calcTotal(items);
        if (totalPrice.compareTo(budget.min) < 0 || totalPrice.compareTo(budget.max) > 0) {
            warnings.add("当前库存下无法严格满足预算，已返回最接近预算方案");
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("planType", "meal");
        data.put("planId", buildPlanId());
        data.put("planName", buildMealPlanName(mealType, dietGoal, budgetLevel));
        data.put("serving", 1);
        data.put("items", toItemMaps(items));

        Map<String, Object> nutrition = new LinkedHashMap<>();
        nutrition.put("caloriesRange", guessCaloriesRange(totalPrice));
        nutrition.put("fiberLevel", guessFiberLevel(items));
        nutrition.put("vitaminCLevel", "fruit".equals(items.get(2).getRole()) ? "high" : "medium");
        data.put("nutritionSummary", nutrition);

        int grams = totalGrams(items);
        Map<String, Object> waste = new LinkedHashMap<>();
        waste.put("level", grams <= 950 ? "low" : "medium");
        waste.put("reason", grams <= 950 ? "份量约 " + grams + "g，贴合单人食用" : "份量偏大，建议分餐或次餐继续食用");
        data.put("wasteEstimate", waste);

        data.put("priceSummary", buildPriceSummary(items, totalPrice, "meal"));
        data.put("warnings", warnings);
        data.put("strategySummary", buildStrategySummary("meal", profile, !warnings.isEmpty(), warnings));
        data.put("replaceOptions", new HashMap<>());
        return ApiResponse.success(data);
    }

    @Override
    public ApiResponse<?> generateComboPlan(Long userId, GenerateComboPlanRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("请求参数不能为空");
        }

        WeightProfile profile = resolveWeightProfile("combo");
        String goalScene = safe(request.getGoalScene(), "salad");
        String peopleCount = safe(request.getPeopleCount(), "1");
        String tastePref = safe(request.getTastePref(), "fresh");
        Long shuffleSeed = request.getShuffleSeed();
        BudgetRange budget = scaleBudgetRange(resolveBudgetRange(safe(request.getBudgetLevel(), "standard"), "combo"), resolveServingCount(peopleCount));

        List<Goods> pool = filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), null);
        List<String> warnings = new ArrayList<>();
        if (pool.size() < 3) {
            return ApiResponse.badRequest("可用商品不足，暂无法生成搭配");
        }
        prepareTagCache(pool);

        Map<Long, Category> categoryMap = loadCategoryMap();
        Goods baseGoods = pickBestComboGoods(pool, categoryMap, goalScene, "base", peopleCount, tastePref, profile, userId, shuffleSeed, null);
        Goods vegGoods = pickBestComboGoods(pool, categoryMap, goalScene, "veg", peopleCount, tastePref, profile, userId, shuffleSeed, baseGoods == null ? null : baseGoods.getId());
        Goods fruitGoods = pickBestComboGoods(pool, categoryMap, goalScene, "fruit", peopleCount, tastePref, profile, userId, shuffleSeed, vegGoods == null ? null : vegGoods.getId(), baseGoods == null ? null : baseGoods.getId());

        if (baseGoods == null || vegGoods == null || fruitGoods == null) {
            return ApiResponse.badRequest("未找到满足条件的搭配组合，请调整条件后重试");
        }

        List<PlanItem> items = new ArrayList<>();
        items.add(buildPlanItem(baseGoods, "base", "基础食材：决定整体口感走向", "combo"));
        items.add(buildPlanItem(vegGoods, "veg", "蔬菜：补充膳食纤维与层次", "combo"));
        items.add(buildPlanItem(fruitGoods, "fruit", "水果：提升风味和维生素", "combo"));

        items = enforceBudget(items, pool, categoryMap, budget, "combo", goalScene, profile, userId);
        BigDecimal totalPrice = calcTotal(items);
        if (totalPrice.compareTo(budget.min) < 0 || totalPrice.compareTo(budget.max) > 0) {
            warnings.add("当前库存下无法严格满足预算，已返回最接近预算搭配");
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("comboId", buildPlanId());
        data.put("comboName", buildComboName(goalScene));
        data.put("items", toItemMaps(items));
        data.put("prepHint", buildPrepHint(goalScene));
        data.put("fitScore", scoreComboFit(goalScene, items));
        data.put("priceSummary", buildPriceSummary(items, totalPrice, "combo"));
        data.put("warnings", warnings);
        data.put("strategySummary", buildStrategySummary("combo", profile, !warnings.isEmpty(), warnings));
        data.put("replaceOptions", new HashMap<>());
        return ApiResponse.success(data);
    }

    @Override
    public ApiResponse<?> replacePlanItem(Long userId, ReplacePlanItemRequest request) {
        if (request == null || request.getOriginSkuId() == null) {
            return ApiResponse.badRequest("originSkuId不能为空");
        }

        GoodsSku originSku = goodsSkuMapper.selectById(request.getOriginSkuId());
        if (originSku == null || originSku.getGoodsId() == null) {
            return ApiResponse.notFound("原规格不存在");
        }
        Goods originGoods = goodsMapper.selectById(originSku.getGoodsId());
        if (originGoods == null) {
            return ApiResponse.notFound("原商品不存在");
        }

        Map<Long, Category> categoryMap = loadCategoryMap();
        String role = inferRoleByGoods(originGoods, categoryMap, safe(request.getPlanType(), "meal"));
        List<Goods> pool = filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), null);
        prepareTagCache(pool);

        Goods replacement = null;
        BigDecimal originPrice = safePrice(originSku.getSkuPrice(), safePrice(originGoods.getPrice(), BigDecimal.ZERO));
        BigDecimal maxDelta = new BigDecimal("8.00");

        Long avoidGoodsId = request.getOriginGoodsId();
        for (Goods g : pool) {
            if (g.getId().equals(originGoods.getId())) continue;
            if (avoidGoodsId != null && avoidGoodsId.equals(g.getId())) continue;
            if (!roleMatched(g, role, categoryMap, safe(request.getPlanType(), "meal"))) continue;
            GoodsSku sku = selectPreferredSku(g.getId(), role, safe(request.getPlanType(), "meal"), resolveWeightProfile(safe(request.getPlanType(), "meal")));
            if (sku == null) continue;
            if (request.getOriginSkuId() != null && request.getOriginSkuId().equals(sku.getId())) continue;
            BigDecimal p = safePrice(sku.getSkuPrice(), safePrice(g.getPrice(), BigDecimal.ZERO));
            if (p.subtract(originPrice).abs().compareTo(maxDelta) > 0) continue;
            replacement = g;
            break;
        }

        if (replacement == null) {
            return ApiResponse.badRequest("该组合项当前暂无可替换商品");
        }

        PlanItem item = buildPlanItem(replacement, role, "已按同角色与价格约束替换");
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("item", toItemMap(item));
        List<PlanItem> singleItemList = new ArrayList<>();
        singleItemList.add(item);
        data.put("priceSummary", buildPriceSummary(singleItemList, item.getPrice(), safe(request.getPlanType(), "meal")));
        data.put("message", "替换成功");
        return ApiResponse.success(data);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> addPlanToCart(Long userId, AddPlanToCartRequest request) {
        if (userId == null) {
            return ApiResponse.badRequest("未登录用户不可加购");
        }
        if (request == null || request.getItems() == null || request.getItems().isEmpty()) {
            return ApiResponse.badRequest("方案商品不能为空");
        }

        int successCount = 0;
        List<Map<String, Object>> failedItems = new ArrayList<>();

        for (AddPlanToCartRequest.PlanCartItem row : request.getItems()) {
            Long goodsId = row.getGoodsId();
            Long skuId = row.getSkuId();
            int quantity = row.getQuantity() == null || row.getQuantity() <= 0 ? 1 : row.getQuantity();
            String sourceType = normalizePlanSourceType(row.getSourceType(), request.getPlanType());
            Long sourcePlanId = row.getSourcePlanId() != null ? row.getSourcePlanId() : request.getPlanId();
            String sourceScene = normalizePlanSourceScene(request.getPlanType(), row.getSourceScene());

            Goods goods = goodsId == null ? null : cartMapper.selectGoodsById(goodsId);
            GoodsSku sku = skuId == null ? null : cartMapper.selectSkuById(skuId);

            if (goods == null || goods.getStatus() == null || goods.getStatus() != 1) {
                failedItems.add(buildFailedItem(goodsId, skuId, quantity, "GOODS_OFFLINE", "商品已下架或不存在"));
                continue;
            }
            if (sku == null || sku.getGoodsId() == null || !goodsId.equals(sku.getGoodsId()) || sku.getStatus() == null || sku.getStatus() != 1) {
                failedItems.add(buildFailedItem(goodsId, skuId, quantity, "SKU_INVALID", "规格不可用"));
                continue;
            }
            int stock = sku.getSkuStock() == null ? 0 : sku.getSkuStock();
            if (stock <= 0) {
                failedItems.add(buildFailedItem(goodsId, skuId, quantity, "OUT_OF_STOCK", "库存不足"));
                continue;
            }

            CartInfo cart = cartMapper.selectCartByUserIdAndGoodsIdAndSkuId(userId, goodsId, skuId);
            if (cart == null) {
                CartInfo insert = new CartInfo();
                insert.setUserId(userId);
                insert.setGoodsId(goodsId);
                insert.setSkuId(skuId);
                insert.setQuantity(Math.min(quantity, stock));
                insert.setSelected(1);
                insert.setSourceType(sourceType);
                insert.setSourcePlanId(sourcePlanId);
                insert.setSourceScene(sourceScene);
                cartMapper.insertCart(insert);
                successCount += 1;
                continue;
            }
            int current = cart.getQuantity() == null ? 0 : cart.getQuantity();
            int next = Math.min(stock, current + quantity);
            if (next <= current) {
                failedItems.add(buildFailedItem(goodsId, skuId, quantity, "REACH_STOCK_LIMIT", "已达库存上限"));
                continue;
            }
            cart.setQuantity(next);
            cart.setSelected(1);
            cart.setSourceType(sourceType);
            cart.setSourcePlanId(sourcePlanId);
            cart.setSourceScene(sourceScene);
            cartMapper.updateCart(cart);
            successCount += 1;
        }

        int totalCount = request.getItems().size();
        int failedCount = failedItems.size();
        String resultType = failedCount == 0 ? "SUCCESS" : (successCount > 0 ? "PARTIAL_SUCCESS" : "FAILED");

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("resultType", resultType);
        data.put("successCount", successCount);
        data.put("failedCount", failedCount);
        data.put("totalCount", totalCount);
        data.put("failedItems", failedItems);
        data.put("message", "SUCCESS".equals(resultType) ? "方案加入购物车成功" : ("PARTIAL_SUCCESS".equals(resultType) ? "部分商品加入成功" : "方案加入失败"));
        return ApiResponse.success(data);
    }

    private Map<Long, Category> loadCategoryMap() {
        Map<Long, Category> map = new HashMap<>();
        List<Category> list = categoryMapper.selectAll();
        for (Category c : list) {
            map.put(c.getId(), c);
        }
        return map;
    }

    private List<Goods> filterAvailableGoods(List<Goods> source, List<String> dislikeTags) {
        List<Goods> result = new ArrayList<>();
        for (Goods g : source) {
            if (g == null || g.getId() == null) continue;
            if (g.getStatus() == null || g.getStatus() != 1) continue;
            if (g.getStock() == null || g.getStock() <= 0) continue;
            if (containsDislike(g, dislikeTags)) continue;
            GoodsSku sku = firstAvailableSku(g.getId());
            if (sku == null) continue;
            result.add(g);
        }
        return result;
    }

    private boolean containsDislike(Goods g, List<String> dislikeTags) {
        if (dislikeTags == null || dislikeTags.isEmpty()) return false;
        for (String tag : dislikeTags) {
            if ("spicy".equals(tag) && hasTag(g, "exclude_spicy")) return true;
            if ("sweet".equals(tag) && hasTag(g, "exclude_sweet")) return true;
            if ("cold_food".equals(tag) && hasTag(g, "exclude_cold_food")) return true;
        }
        String text = (safe(g.getName(), "") + "," + safe(g.getKeywords(), "")).toLowerCase();
        for (String tag : dislikeTags) {
            if ("spicy".equals(tag) && text.contains("辣")) return true;
            if ("sweet".equals(tag) && (text.contains("糖") || text.contains("甜"))) return true;
            if ("cold_food".equals(tag) && (text.contains("冰") || text.contains("冷食"))) return true;
        }
        return false;
    }

    private boolean containsHardConflictKeyword(Goods g, String typeOrGoal) {
        String text = (safe(g.getName(), "") + "," + safe(g.getKeywords(), "")).toLowerCase();
        if ("juice".equals(typeOrGoal)) {
            return containsAnyKeyword(text, readRuleList("plan.juice_blacklist_keywords"));
        }
        if ("salad".equals(typeOrGoal)) {
            return containsAnyKeyword(text, readRuleList("plan.salad_blacklist_keywords"));
        }
        if ("hotpot".equals(typeOrGoal)) {
            return containsAnyKeyword(text, readRuleList("plan.hotpot_blacklist_keywords"));
        }
        if ("meal".equals(typeOrGoal)) {
            return text.matches(".*(榴莲|菠萝蜜).*");
        }
        return false;
    }

    private Goods pickBestMealGoods(List<Goods> pool, Map<Long, Category> categoryMap, String role, BudgetRange budget, String dietGoal, String cookMode, WeightProfile profile, Long userId, Long shuffleSeed, Long... excludes) {
        List<Goods> candidates = pool.stream()
                .filter(g -> !isExcluded(g.getId(), excludes))
                .filter(g -> roleMatched(g, role, categoryMap, "meal"))
                .filter(g -> !containsHardConflictKeyword(g, "meal"))
                .sorted((a, b) -> Integer.compare(scoreMealGoods(b, role, budget, dietGoal, cookMode, categoryMap, profile), scoreMealGoods(a, role, budget, dietGoal, cookMode, categoryMap, profile)))
                .limit(3)
                .collect(Collectors.toList());
        return pickWithRotation(candidates, userId, shuffleSeed, "meal-" + role);
    }

    private Goods pickBestComboGoods(List<Goods> pool, Map<Long, Category> categoryMap, String goalScene, String role, String peopleCount, String tastePref, WeightProfile profile, Long userId, Long shuffleSeed, Long... excludes) {
        List<Goods> candidates = pool.stream()
                .filter(g -> !isExcluded(g.getId(), excludes))
                .filter(g -> roleMatched(g, role, categoryMap, "combo"))
                .filter(g -> !containsHardConflictKeyword(g, goalScene))
                .sorted((a, b) -> Integer.compare(scoreComboGoods(b, goalScene, role, peopleCount, tastePref, categoryMap, profile), scoreComboGoods(a, goalScene, role, peopleCount, tastePref, categoryMap, profile)))
                .limit(3)
                .collect(Collectors.toList());
        return pickWithRotation(candidates, userId, shuffleSeed, "combo-" + role);
    }

    private boolean isExcluded(Long id, Long... excludes) {
        if (id == null || excludes == null) return false;
        for (Long ex : excludes) {
            if (ex != null && ex.equals(id)) return true;
        }
        return false;
    }

    private int scoreMealGoods(Goods g, String role, BudgetRange budget, String dietGoal, String cookMode, Map<Long, Category> categoryMap, WeightProfile profile) {
        int score = 0;
        BigDecimal price = safePrice(firstAvailableSkuPrice(g), safePrice(g.getPrice(), BigDecimal.ZERO));
        if (price.compareTo(budget.min.divide(new BigDecimal("3"), 2, RoundingMode.HALF_UP)) >= 0 && price.compareTo(budget.max) <= 0) score += profile.budgetWeight;
        score += Math.min(safeInt(g.getSalesVolume()) / 80, profile.salesWeight);
        score += Math.min(safeInt(g.getStock()) / 30, profile.stockWeight);
        String text = safe(g.getName(), "") + "," + safe(g.getKeywords(), "") + "," + safe(g.getOrigin(), "");
        if ("high_fiber".equals(dietGoal) && hasTag(g, "diet_high_fiber")) score += 15;
        if ("light".equals(dietGoal) && hasTag(g, "diet_light")) score += 15;
        if ("main".equals(role) && hasTag(g, "role_main")) score += 18;
        if ("side".equals(role) && hasTag(g, "role_side")) score += 18;
        if ("fruit".equals(role) && hasTag(g, "role_fruit")) score += 18;
        if ("high_fiber".equals(dietGoal) && !hasTag(g, "diet_high_fiber") && text.matches(".*(菜|豆|麦|菌|瓜).*")) score += 8;
        if ("light".equals(dietGoal) && !hasTag(g, "diet_light") && text.matches(".*(生菜|黄瓜|番茄|西兰花|蓝莓|苹果).*")) score += 8;
        score += scoreCookModeFit(g, role, cookMode);
        score += scoreMealPortionFit(g, role);
        score += scoreCommonConstraintFit(g, role, typeSafeRole(role));
        if (roleMatched(g, role, categoryMap, "meal")) score += 25;
        return score;
    }

    private int scoreComboGoods(Goods g, String goalScene, String role, String peopleCount, String tastePref, Map<Long, Category> categoryMap, WeightProfile profile) {
        int score = 0;
        score += Math.min(safeInt(g.getSalesVolume()) / 100, profile.salesWeight);
        score += Math.min(safeInt(g.getStock()) / 40, profile.stockWeight);
        String sceneTagCode = sceneToTagCode(goalScene);
        if (!sceneTagCode.isEmpty() && hasTag(g, sceneTagCode)) score += 20;
        if ("salad".equals(goalScene) && hasTag(g, "scene_combo_mix")) score += 8;
        if ("juice".equals(goalScene) && hasTag(g, "scene_combo_mix")) score += 8;
        if ("hotpot".equals(goalScene) && hasTag(g, "scene_combo_mix")) score += 8;
        if ("bento_side".equals(goalScene) && hasTag(g, "scene_combo_mix")) score += 8;
        score += scoreComboSceneFit(g, goalScene, role);
        score += scoreTastePreference(g, goalScene, role, tastePref);
        score += scorePeopleCountFit(g, role, peopleCount);
        score += scoreCommonConstraintFit(g, role, goalScene);
        if (roleMatched(g, role, categoryMap, "combo")) score += 25;
        return score;
    }

    private List<PlanItem> enforceBudget(List<PlanItem> items, List<Goods> pool, Map<Long, Category> categoryMap, BudgetRange budget, String type, String goal, WeightProfile profile, Long userId) {
        BigDecimal total = calcTotal(items);
        if (total.compareTo(budget.min) >= 0 && total.compareTo(budget.max) <= 0) return items;

        List<PlanItem> best = new ArrayList<>(items);
        BigDecimal bestGap = budgetDistance(total, budget);

        for (int i = 0; i < items.size(); i++) {
            String role = items.get(i).getRole();
            for (Goods g : pool) {
                if (!roleMatched(g, role, categoryMap, type)) continue;
                if (containsHardConflictKeyword(g, goal)) continue;
                if (violatesCompositionRules(g, items, i, type, goal)) continue;
                GoodsSku sku = selectPreferredSku(g.getId(), role, type, profile);
                if (sku == null) continue;
                PlanItem candidateItem = buildPlanItem(g, role, items.get(i).getReason(), type);
                List<PlanItem> candidate = new ArrayList<>(items);
                candidate.set(i, candidateItem);
                BigDecimal candTotal = calcTotal(candidate);
                if (candTotal.compareTo(budget.min) >= 0 && candTotal.compareTo(budget.max) <= 0) {
                    return candidate;
                }
                BigDecimal gap = budgetDistance(candTotal, budget);
                if (gap.compareTo(bestGap) < 0) {
                    best = candidate;
                    bestGap = gap;
                }
            }
        }
        return best;
    }

    private BigDecimal budgetDistance(BigDecimal total, BudgetRange budget) {
        if (total.compareTo(budget.min) < 0) return budget.min.subtract(total);
        if (total.compareTo(budget.max) > 0) return total.subtract(budget.max);
        return BigDecimal.ZERO;
    }

    private boolean roleMatched(Goods g, String role, Map<Long, Category> categoryMap, String type) {
        Category category = categoryMap.get(g.getCategoryId());
        if (category == null) return fallbackRoleMatchByText(g, role, type);
        Long parentId = category.getParentId();
        String name = safe(category.getName(), "");
        String rootName = "";
        if (parentId != null && parentId > 0) {
            Category parent = categoryMap.get(parentId);
            if (parent != null) {
                rootName = safe(parent.getName(), "");
            }
        }
        boolean isFruit = "水果".equals(rootName) || "水果".equals(name);
        boolean isVeg = "蔬菜".equals(rootName) || "蔬菜".equals(name);
        String text = safe(g.getName(), "") + "," + safe(g.getKeywords(), "");

        if ("fruit".equals(role) && hasTag(g, "role_fruit")) return true;
        if ("main".equals(role) && hasTag(g, "role_main")) return true;
        if ("side".equals(role) && hasTag(g, "role_side")) return true;
        if ("base".equals(role) && hasTag(g, "role_base")) return true;
        if ("veg".equals(role) && hasTag(g, "role_veg")) return true;

        if ("fruit".equals(role)) return isFruit || isFruitLike(text);
        if ("main".equals(role)) return (isVeg && isMealMainLike(text)) || (!isFruit && isMealMainLike(text));
        if ("side".equals(role)) return (isVeg && isMealSideLike(text)) || (!isFruit && isMealSideLike(text));
        if ("base".equals(role)) return (isVeg && isComboBaseLike(text)) || (!isFruit && isComboBaseLike(text));
        if ("veg".equals(role)) return (isVeg && isComboVegLike(text)) || (!isFruit && isComboVegLike(text));
        return fallbackRoleMatchByText(g, role, type);
    }

    private int scoreMealPortionFit(Goods goods, String role) {
        GoodsSku sku = selectPreferredSku(goods.getId(), role, "meal", resolveWeightProfile("meal"));
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

    private int scoreComboSceneFit(Goods goods, String goalScene, String role) {
        String text = (safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "")).toLowerCase();
        if ("juice".equals(goalScene)) {
            if (text.matches(".*(榨|汁用|柠檬|橙|苹果|胡萝卜|番茄).*")) return 12;
            if (text.matches(".*(火锅|耐煮).*")) return -10;
        }
        if ("hotpot".equals(goalScene)) {
            if (text.matches(".*(耐煮|菌|菜|豆腐|番茄|土豆|玉米|蘑菇).*")) return 12;
            if ("fruit".equals(role) && text.matches(".*(榴莲|椰子).*")) return -10;
        }
        if ("salad".equals(goalScene)) {
            if (text.matches(".*(生菜|黄瓜|番茄|蓝莓|草莓|苹果|牛油果).*")) return 12;
            if (text.matches(".*(土豆|南瓜|玉米).*")) return -6;
        }
        if ("bento_side".equals(goalScene)) {
            if (text.matches(".*(西兰花|胡萝卜|玉米|秋葵|菜花|菌菇).*")) return 12;
            if (text.matches(".*(多汁|鲜切即食).*")) return -6;
        }
        return 0;
    }

    private int scoreCookModeFit(Goods goods, String role, String cookMode) {
        String text = (safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "")).toLowerCase();
        if ("no_cook".equals(cookMode)) {
            if ("fruit".equals(role) && isFruitLike(text)) return 10;
            if (text.matches(".*(生菜|黄瓜|番茄|蓝莓|草莓|苹果|橙|圣女果).*")) return 10;
            if (text.matches(".*(土豆|南瓜|芋头|山药|毛豆|四季豆).*")) return -8;
        }
        if ("quick_cook".equals(cookMode)) {
            if (text.matches(".*(西兰花|胡萝卜|菌|菇|玉米|番茄|荷兰豆|秋葵).*")) return 8;
        }
        return 0;
    }

    private int scoreCommonConstraintFit(Goods goods, String role, String sceneKey) {
        String text = (safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "")).toLowerCase();
        int score = 0;
        if ("fruit".equals(role) && text.matches(".*(榴莲|菠萝蜜).*")) score -= 12;
        if (!"fruit".equals(role) && text.matches(".*(鲜切即食|即食水果杯).*")) score -= 8;
        if ("juice".equals(sceneKey) && text.matches(".*(辣椒|洋葱|蒜).*")) score -= 16;
        if ("salad".equals(sceneKey) && text.matches(".*(蒜苗|洋葱|苦瓜).*")) score -= 10;
        if ("meal".equals(sceneKey) && text.matches(".*(榴莲|菠萝蜜|蒜苗).*")) score -= 12;
        if ("juice".equals(sceneKey) && isStarchyProduce(text)) score -= 10;
        if ("salad".equals(sceneKey) && isStrongFlavorProduce(text)) score -= 12;
        if ("hotpot".equals(sceneKey) && "fruit".equals(role) && isWateryFruitProduce(text)) score -= 10;
        return score;
    }

    private int scoreTastePreference(Goods goods, String goalScene, String role, String tastePref) {
        String text = (safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "")).toLowerCase();
        if ("sweet".equals(tastePref)) {
            if ("fruit".equals(role) && text.matches(".*(草莓|蓝莓|葡萄|橙|苹果|桃|瓜|樱桃|梨).*")) return 10;
            if ("juice".equals(goalScene) && text.matches(".*(橙|苹果|胡萝卜|番茄).*")) return 6;
        }
        if ("crisp".equals(tastePref)) {
            if (text.matches(".*(黄瓜|苹果|梨|荷兰豆|西兰花|胡萝卜|生菜).*")) return 10;
        }
        if ("fresh".equals(tastePref)) {
            if (text.matches(".*(生菜|黄瓜|番茄|蓝莓|草莓|柠檬|橙).*")) return 8;
        }
        return 0;
    }

    private int scorePeopleCountFit(Goods goods, String role, String peopleCount) {
        GoodsSku sku = selectPreferredSku(goods.getId(), role, "combo", resolveWeightProfile("combo"));
        if (sku == null || sku.getSkuWeightG() == null) return 0;
        int weight = sku.getSkuWeightG();
        int serving = resolveServingCount(peopleCount);
        if (serving <= 1) {
            if (weight <= 320) return 8;
            if (weight >= 500) return -8;
            return 0;
        }
        if (serving == 2) {
            if (weight >= 220 && weight <= 520) return 8;
            return 0;
        }
        if (weight >= 320) return 10;
        return -6;
    }

    private boolean violatesCompositionRules(Goods candidate, List<PlanItem> items, int replaceIndex, String type, String goal) {
        String candidateText = (safe(candidate.getName(), "") + "," + safe(candidate.getKeywords(), "")).toLowerCase();
        int sameRootCount = 0;
        int sameRoleCount = 0;
        int fruitCount = 0;
        int strongFlavorCount = isStrongFlavorProduce(candidateText) ? 1 : 0;
        int starchyCount = isStarchyProduce(candidateText) ? 1 : 0;
        for (int i = 0; i < items.size(); i++) {
            if (i == replaceIndex) continue;
            PlanItem item = items.get(i);
            if (item == null || item.getGoodsId() == null) continue;
            Goods existed = goodsMapper.selectById(item.getGoodsId());
            if (existed == null) continue;
            String existedText = (safe(existed.getName(), "") + "," + safe(existed.getKeywords(), "")).toLowerCase();
            if (isSimilarProduceFamily(candidateText, existedText)) sameRootCount += 1;
            if (safe(item.getRole(), "").equals(inferTextRole(candidateText, type))) sameRoleCount += 1;
            if ("fruit".equals(item.getRole())) fruitCount += 1;
            if (isStrongFlavorProduce(existedText)) strongFlavorCount += 1;
            if (isStarchyProduce(existedText)) starchyCount += 1;
            if (hasDirectConflict(candidateText, existedText, goal)) return true;
        }
        if (sameRootCount >= 2) return true;
        if ("combo".equals(type) && sameRoleCount >= 2) return true;
        if ("meal".equals(type) && "fruit".equals(inferTextRole(candidateText, type)) && fruitCount >= 1) return true;
        if (("salad".equals(goal) || "juice".equals(goal)) && strongFlavorCount >= 2) return true;
        if ("juice".equals(goal) && starchyCount >= 2) return true;
        return false;
    }

    private boolean hasDirectConflict(String a, String b, String goal) {
        if (hasConfiguredConflict(a, b, readRuleList("plan.general_conflict_pairs"))) {
            return true;
        }
        if ("juice".equals(goal) && hasConfiguredConflict(a, b, readRuleList("plan.juice_conflict_pairs"))) {
            return true;
        }
        if ("salad".equals(goal) && hasConfiguredConflict(a, b, readRuleList("plan.salad_conflict_pairs"))) {
            return true;
        }
        if ("hotpot".equals(goal) && ((a.contains("西瓜") && b.contains("火锅")) || (b.contains("西瓜") && a.contains("火锅")))) {
            return true;
        }
        return false;
    }

    private boolean isSimilarProduceFamily(String a, String b) {
        return shareKeyword(a, b, "苹果")
                || shareKeyword(a, b, "番茄")
                || shareKeyword(a, b, "黄瓜")
                || shareKeyword(a, b, "土豆")
                || shareKeyword(a, b, "胡萝卜")
                || shareKeyword(a, b, "草莓")
                || shareKeyword(a, b, "蓝莓");
    }

    private boolean shareKeyword(String a, String b, String keyword) {
        return a.contains(keyword) && b.contains(keyword);
    }

    private String inferTextRole(String text, String planType) {
        String safeText = safe(text, "").toLowerCase();
        if (isFruitLike(safeText)) return "fruit";
        if ("combo".equals(planType)) {
            return isComboBaseLike(safeText) ? "base" : "veg";
        }
        return isMealMainLike(safeText) ? "main" : "side";
    }

    private boolean isStrongFlavorProduce(String text) {
        return containsAnyKeyword(text, readRuleList("plan.strong_flavor_keywords"));
    }

    private boolean isStarchyProduce(String text) {
        return containsAnyKeyword(text, readRuleList("plan.starchy_keywords"));
    }

    private boolean isWateryFruitProduce(String text) {
        return containsAnyKeyword(text, readRuleList("plan.watery_fruit_keywords"));
    }

    private String typeSafeRole(String role) {
        return safe(role, "");
    }

    private List<String> readRuleList(String ruleKey) {
        String raw = loadPlanRuleConfig().getOrDefault(ruleKey, DEFAULT_PLAN_RULES.getOrDefault(ruleKey, ""));
        if (raw == null || raw.trim().isEmpty()) return Collections.emptyList();
        return java.util.Arrays.stream(raw.split(","))
                .map(String::trim)
                .filter(s -> !s.isEmpty())
                .collect(Collectors.toList());
    }

    private boolean containsAnyKeyword(String text, List<String> keywords) {
        if (text == null || text.isEmpty() || keywords == null || keywords.isEmpty()) return false;
        for (String keyword : keywords) {
            if (!keyword.isEmpty() && text.contains(keyword.toLowerCase())) return true;
        }
        return false;
    }

    private boolean hasConfiguredConflict(String a, String b, List<String> pairs) {
        if (pairs == null || pairs.isEmpty()) return false;
        for (String pair : pairs) {
            String[] parts = pair.split("\\|");
            if (parts.length != 2) continue;
            String left = parts[0].trim().toLowerCase();
            String right = parts[1].trim().toLowerCase();
            if (left.isEmpty() || right.isEmpty()) continue;
            if ((a.contains(left) && b.contains(right)) || (a.contains(right) && b.contains(left))) {
                return true;
            }
        }
        return false;
    }

    private Map<String, String> loadPlanRuleConfig() {
        Map<String, String> config = new HashMap<>(DEFAULT_PLAN_RULES);
        try {
            List<Map<String, Object>> rows = planRuleConfigMapper.selectAll();
            if (rows != null) {
                for (Map<String, Object> row : rows) {
                    String key = row.get("ruleKey") == null ? "" : String.valueOf(row.get("ruleKey")).trim();
                    if (key.isEmpty()) continue;
                    String value = row.get("ruleValue") == null ? "" : String.valueOf(row.get("ruleValue")).trim();
                    config.put(key, value);
                }
            }
        } catch (Exception ignored) {
            return config;
        }
        return config;
    }

    private Map<String, String> loadPackPricingRules() {
        Map<String, String> config = new HashMap<>(DEFAULT_PACK_PRICING_RULES);
        try {
            List<Map<String, Object>> rows = packPricingRuleMapper.selectAll();
            if (rows != null) {
                for (Map<String, Object> row : rows) {
                    String key = row.get("ruleKey") == null ? "" : String.valueOf(row.get("ruleKey")).trim();
                    if (key.isEmpty()) continue;
                    String value = row.get("ruleValue") == null ? "" : String.valueOf(row.get("ruleValue")).trim();
                    config.put(key, value);
                }
            }
        } catch (Exception ignored) {
            return config;
        }
        return config;
    }

    private BigDecimal readBigDecimal(Map<String, String> config, String key, String fallback) {
        try {
            String value = config.getOrDefault(key, fallback);
            return new BigDecimal(value).setScale(2, RoundingMode.HALF_UP);
        } catch (Exception ignored) {
            return new BigDecimal(fallback).setScale(2, RoundingMode.HALF_UP);
        }
    }

    private static Map<String, String> buildDefaultPlanRules() {
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

    private static Map<String, String> buildDefaultPackPricingRules() {
        Map<String, String> config = new HashMap<>();
        config.put("pack.combo.discount_rate", "0.05");
        config.put("pack.combo.min_discount", "2.00");
        config.put("pack.combo.max_discount", "12.00");
        config.put("pack.meal.discount_rate", "0.03");
        config.put("pack.meal.min_discount", "1.00");
        config.put("pack.meal.max_discount", "8.00");
        return config;
    }

    private boolean fallbackRoleMatchByText(Goods g, String role, String type) {
        String text = safe(g.getName(), "") + "," + safe(g.getKeywords(), "");
        if ("fruit".equals(role)) return isFruitLike(text);
        if ("main".equals(role)) return isMealMainLike(text);
        if ("side".equals(role)) return isMealSideLike(text);
        if ("base".equals(role)) return isComboBaseLike(text);
        if ("veg".equals(role)) return isComboVegLike(text);
        return true;
    }

    private PlanItem buildPlanItem(Goods goods, String role, String reason) {
        String planType = ("base".equals(role) || "veg".equals(role)) ? "combo" : "meal";
        return buildPlanItem(goods, role, reason, planType);
    }

    private PlanItem buildPlanItem(Goods goods, String role, String reason, String planType) {
        GoodsSku sku = selectPreferredSku(goods.getId(), role, planType, resolveWeightProfile(planType));
        if (sku == null) {
            return null;
        }
        PlanItem item = new PlanItem();
        item.setGoodsId(goods.getId());
        item.setSkuId(sku.getId());
        item.setSkuName(safe(sku.getSkuName(), "默认规格"));
        item.setName(goods.getName());
        item.setImage(goods.getMainImage());
        item.setQuantity(1);
        item.setRole(role);
        item.setReason(reason + buildSkuReasonSuffix(sku, role, planType));
        item.setReasonTags(buildReasonTags(sku, role, planType));
        item.setPrice(safePrice(sku.getSkuPrice(), safePrice(goods.getPrice(), BigDecimal.ZERO)));
        item.setOriginalPrice(resolveOriginalPrice(goods, item.getPrice(), planType));
        item.setGramsEstimate(sku.getSkuWeightG() == null || sku.getSkuWeightG() <= 0 ? 500 : sku.getSkuWeightG());
        return item;
    }

    private GoodsSku selectPreferredSku(Long goodsId, String role, String planType, WeightProfile profile) {
        if (goodsId == null) return null;
        List<GoodsSku> skus = goodsSkuMapper.selectListByGoodsId(goodsId);
        GoodsSku best = null;
        int bestScore = Integer.MIN_VALUE;
        for (GoodsSku sku : skus) {
            if (sku == null) continue;
            if (sku.getStatus() == null || sku.getStatus() != 1) continue;
            if (sku.getSkuStock() == null || sku.getSkuStock() <= 0) continue;
            int score = scoreSkuByScene(sku, role, planType, profile);
            if (best == null || score > bestScore) {
                best = sku;
                bestScore = score;
            }
        }
        return best;
    }

    private int scoreSkuByScene(GoodsSku sku, String role, String planType, WeightProfile profile) {
        int score = 0;
        int weight = sku.getSkuWeightG() == null ? 500 : sku.getSkuWeightG();
        String skuName = safe(sku.getSkuName(), "");
        String specType = safe(sku.getSpecType(), "");
        String specValue = safe(sku.getSpecValue(), "");
        String text = (skuName + "," + specType + "," + specValue).toLowerCase();

        int targetWeight = resolveTargetWeight(role, planType);
        int diff = Math.abs(weight - targetWeight);
        score += Math.max(0, profile.smallPortionWeight - (diff / 6));

        if ("meal".equals(planType)) {
            if (weight >= 250 && weight <= 420) score += 25;
            else if (weight <= 520) score += 10;
            if (text.contains("小")) score += 15;
            if (text.contains("单人") || text.contains("一人")) score += 20;
        } else {
            if (weight >= 150 && weight <= 320) score += 25;
            else if (weight <= 420) score += 10;
            if (text.contains("搭配") || text.contains("拼盘") || text.contains("组合")) score += 18;
        }
        score += Math.min(safeInt(sku.getSkuStock()) / 15, profile.stockWeight);
        return score;
    }

    private int resolveTargetWeight(String role, String planType) {
        if ("combo".equals(planType)) {
            if ("fruit".equals(role)) return 180;
            if ("veg".equals(role)) return 220;
            return 260;
        }
        if ("fruit".equals(role)) return 220;
        if ("side".equals(role)) return 280;
        return 340;
    }

    private String buildSkuReasonSuffix(GoodsSku sku, String role, String planType) {
        int weight = sku.getSkuWeightG() == null ? 500 : sku.getSkuWeightG();
        String skuName = safe(sku.getSkuName(), "默认规格");
        if ("meal".equals(planType)) {
            return "；规格策略：优先小份，当前为「" + skuName + "」约" + weight + "g";
        }
        return "；规格策略：优先搭配友好份量，当前为「" + skuName + "」约" + weight + "g";
    }

    private List<String> buildReasonTags(GoodsSku sku, String role, String planType) {
        List<String> tags = new ArrayList<>();
        int weight = sku.getSkuWeightG() == null ? 500 : sku.getSkuWeightG();
        if ("meal".equals(planType)) {
            if (weight <= 420) tags.add("小份优先");
            if ("fruit".equals(role)) tags.add("维C补充");
            if ("side".equals(role)) tags.add("均衡搭配");
            if ("main".equals(role)) tags.add("饱腹主菜");
        } else {
            if (weight <= 320) tags.add("搭配友好");
            tags.add("组合场景适配");
        }
        if (safeInt(sku.getSkuStock()) >= 60) tags.add("库存充足");
        return tags;
    }

    private GoodsSku firstAvailableSku(Long goodsId) {
        if (goodsId == null) return null;
        List<GoodsSku> skus = goodsSkuMapper.selectListByGoodsId(goodsId);
        for (GoodsSku sku : skus) {
            if (sku.getStatus() != null && sku.getStatus() == 1 && sku.getSkuStock() != null && sku.getSkuStock() > 0) {
                return sku;
            }
        }
        return null;
    }

    private BigDecimal firstAvailableSkuPrice(Goods goods) {
        GoodsSku sku = selectPreferredSku(goods == null ? null : goods.getId(), "main", "meal", resolveWeightProfile("meal"));
        return sku == null ? null : sku.getSkuPrice();
    }

    private Goods pickWithRotation(List<Goods> candidates, Long userId, Long shuffleSeed, String bucketKey) {
        if (candidates == null || candidates.isEmpty()) return null;
        if (candidates.size() == 1) return candidates.get(0);
        long uid = userId == null ? 0L : userId;
        long dynamicSeed = (shuffleSeed == null || shuffleSeed <= 0) ? (System.currentTimeMillis() / (24L * 60L * 60L * 1000L)) : shuffleSeed;
        int base = Math.abs((bucketKey + "-" + uid + "-" + dynamicSeed).hashCode());
        int index = base % candidates.size();
        return candidates.get(index);
    }

    private WeightProfile resolveWeightProfile(String planType) {
        if ("combo".equals(planType)) {
            return new WeightProfile("v1-combo", 50, 24, 14, 18);
        }
        return new WeightProfile("v1-meal", 55, 22, 16, 20);
    }

    private Map<String, Object> buildStrategySummary(String planType, WeightProfile profile, boolean fallbackUsed, List<String> warnings) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("planType", planType);
        row.put("weightProfile", profile.version);
        row.put("smallPortionWeight", profile.smallPortionWeight);
        row.put("salesWeight", profile.salesWeight);
        row.put("stockWeight", profile.stockWeight);
        row.put("budgetWeight", profile.budgetWeight);
        row.put("fallbackUsed", fallbackUsed);
        row.put("fallbackReason", (warnings == null || warnings.isEmpty()) ? "" : warnings.get(0));
        return row;
    }

    private List<Map<String, Object>> toItemMaps(List<PlanItem> items) {
        List<Map<String, Object>> list = new ArrayList<>();
        for (PlanItem item : items) {
            list.add(toItemMap(item));
        }
        return list;
    }

    private Map<String, Object> toItemMap(PlanItem item) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("goodsId", item.getGoodsId());
        row.put("skuId", item.getSkuId());
        row.put("skuName", item.getSkuName());
        row.put("name", item.getName());
        row.put("image", item.getImage());
        row.put("quantity", item.getQuantity());
        row.put("role", item.getRole());
        row.put("reason", item.getReason());
        row.put("reasonTags", item.getReasonTags());
        row.put("price", item.getPrice());
        row.put("originalPrice", item.getOriginalPrice());
        row.put("gramsEstimate", item.getGramsEstimate());
        return row;
    }

    private BigDecimal calcTotal(List<PlanItem> items) {
        BigDecimal sum = BigDecimal.ZERO;
        for (PlanItem item : items) {
            BigDecimal price = item.getPrice() == null ? BigDecimal.ZERO : item.getPrice();
            int qty = item.getQuantity() == null ? 1 : item.getQuantity();
            sum = sum.add(price.multiply(BigDecimal.valueOf(qty)));
        }
        return sum.setScale(2, RoundingMode.HALF_UP);
    }

    private int totalGrams(List<PlanItem> items) {
        int total = 0;
        for (PlanItem item : items) {
            total += item.getGramsEstimate() == null ? 0 : item.getGramsEstimate();
        }
        return total;
    }

    private Map<String, Object> buildPriceSummary(List<PlanItem> items, BigDecimal total, String planType) {
        Map<String, Object> row = new LinkedHashMap<>();
        BigDecimal safeTotal = total == null ? BigDecimal.ZERO : total.setScale(2, RoundingMode.HALF_UP);
        BigDecimal originalTotal = calcOriginalTotal(items);
        BigDecimal packDiscount = calcPackDiscount(safeTotal, planType);
        BigDecimal packagePrice = safeTotal.subtract(packDiscount).max(BigDecimal.ZERO).setScale(2, RoundingMode.HALF_UP);
        BigDecimal savedAmount = originalTotal.subtract(packagePrice).max(BigDecimal.ZERO).setScale(2, RoundingMode.HALF_UP);
        row.put("totalPrice", packagePrice);
        row.put("originalTotalPrice", originalTotal);
        row.put("savedAmount", savedAmount);
        row.put("packagePrice", packagePrice);
        row.put("baseTotalPrice", safeTotal);
        row.put("packDiscount", packDiscount);
        if ("combo".equals(planType)) {
            row.put("couponHint", buildCouponHint(packagePrice, savedAmount, new BigDecimal("50")));
        } else {
            row.put("couponHint", buildCouponHint(packagePrice, savedAmount, new BigDecimal("39")));
        }
        return row;
    }

    private BigDecimal calcPackDiscount(BigDecimal totalPrice, String planType) {
        Map<String, String> config = loadPackPricingRules();
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

    private BigDecimal calcOriginalTotal(List<PlanItem> items) {
        BigDecimal total = BigDecimal.ZERO;
        if (items == null) return total.setScale(2, RoundingMode.HALF_UP);
        for (PlanItem item : items) {
            if (item == null) continue;
            BigDecimal originalPrice = safePrice(item.getOriginalPrice(), safePrice(item.getPrice(), BigDecimal.ZERO));
            int qty = item.getQuantity() == null ? 1 : item.getQuantity();
            total = total.add(originalPrice.multiply(BigDecimal.valueOf(qty)));
        }
        return total.setScale(2, RoundingMode.HALF_UP);
    }

    private String buildCouponHint(BigDecimal totalPrice, BigDecimal savedAmount, BigDecimal threshold) {
        String savingsText = savedAmount.compareTo(BigDecimal.ZERO) > 0
                ? ("当前方案已比单买省 ¥" + savedAmount.setScale(2, RoundingMode.HALF_UP))
                : "当前方案暂无额外套餐直降";
        if (totalPrice.compareTo(threshold) >= 0) {
            return savingsText + "，且满足满" + threshold.stripTrailingZeros().toPlainString() + "门槛，可叠加用券";
        }
        return savingsText + "，建议凑单到满" + threshold.stripTrailingZeros().toPlainString() + "更划算";
    }

    private BigDecimal resolveOriginalPrice(Goods goods, BigDecimal price, String planType) {
        BigDecimal baseOriginal = safePrice(goods == null ? null : goods.getOriginalPrice(), BigDecimal.ZERO);
        BigDecimal basePrice = safePrice(price, BigDecimal.ZERO);
        if (baseOriginal.compareTo(basePrice) > 0) {
            return baseOriginal;
        }
        BigDecimal upliftRate = "combo".equals(planType) ? new BigDecimal("1.06") : new BigDecimal("1.04");
        return basePrice.multiply(upliftRate).setScale(2, RoundingMode.HALF_UP);
    }

    private Map<String, Object> buildFailedItem(Long goodsId, Long skuId, Integer quantity, String reasonCode, String reason) {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("goodsId", goodsId);
        row.put("skuId", skuId);
        row.put("quantity", quantity);
        row.put("reasonCode", reasonCode);
        row.put("reason", reason);
        return row;
    }

    private String buildMealPlanName(String mealType, String dietGoal, String budgetLevel) {
        String meal = "lunch".equals(mealType) ? "午餐" : "晚餐";
        String goal = "high_fiber".equals(dietGoal) ? "高纤" : ("light".equals(dietGoal) ? "轻负担" : "均衡");
        String budget = "economy".equals(budgetLevel) ? "经济" : ("plus".equals(budgetLevel) ? "升级" : "标准");
        return meal + "·" + goal + "·" + budget + "一人食";
    }

    private String buildComboName(String goalScene) {
        if ("juice".equals(goalScene)) return "果蔬榨汁搭配";
        if ("hotpot".equals(goalScene)) return "火锅蔬果搭配";
        if ("bento_side".equals(goalScene)) return "便当配菜搭配";
        return "清爽沙拉搭配";
    }

    private String buildPrepHint(String goalScene) {
        if ("juice".equals(goalScene)) return "建议按蔬菜:水果=2:1榨汁，口感更平衡。";
        if ("hotpot".equals(goalScene)) return "耐煮蔬菜先下锅，水果建议餐后食用。";
        if ("bento_side".equals(goalScene)) return "焯水后分装，冷藏 48 小时内食用最佳。";
        return "洗净后按喜好搭配沙拉酱或油醋汁即可。";
    }

    private int scoreComboFit(String goalScene, List<PlanItem> items) {
        int score = 75;
        int roleHit = 0;
        int sceneHit = 0;
        int total = 0;
        String sceneTagCode = sceneToTagCode(goalScene);
        for (PlanItem item : items) {
            total += 1;
            Goods g = goodsMapper.selectById(item.getGoodsId());
            if (g == null) continue;
            if (roleMatched(g, safe(item.getRole(), ""), loadCategoryMap(), "combo")) roleHit += 1;
            if (!sceneTagCode.isEmpty() && hasTag(g, sceneTagCode)) sceneHit += 1;
        }
        if (total > 0) {
            score += Math.min(12, (roleHit * 12) / total);
            score += Math.min(11, (sceneHit * 11) / total);
        }
        return Math.min(score, 98);
    }

    private String guessCaloriesRange(BigDecimal totalPrice) {
        if (totalPrice.compareTo(new BigDecimal("28")) < 0) return "320-460 kcal";
        if (totalPrice.compareTo(new BigDecimal("45")) < 0) return "420-580 kcal";
        return "520-700 kcal";
    }

    private String guessFiberLevel(List<PlanItem> items) {
        int vegLikeCount = 0;
        for (PlanItem item : items) {
            String text = safe(item.getName(), "");
            if (text.contains("菜") || text.contains("豆") || text.contains("菇") || text.contains("瓜")) {
                vegLikeCount += 1;
            }
        }
        return vegLikeCount >= 2 ? "high" : "medium";
    }

    private String inferRoleByGoods(Goods goods, Map<Long, Category> categoryMap, String planType) {
        if (roleMatched(goods, "fruit", categoryMap, planType)) return "fruit";
        if ("combo".equals(planType) && roleMatched(goods, "base", categoryMap, planType)) return "base";
        return roleMatched(goods, "main", categoryMap, planType) ? "main" : "side";
    }

    private BudgetRange resolveBudgetRange(String budgetLevel, String planType) {
        if ("combo".equals(planType)) {
            if ("economy".equals(budgetLevel)) return new BudgetRange(new BigDecimal("28"), new BigDecimal("58"));
            if ("plus".equals(budgetLevel)) return new BudgetRange(new BigDecimal("60"), new BigDecimal("110"));
            return new BudgetRange(new BigDecimal("45"), new BigDecimal("85"));
        }
        if ("economy".equals(budgetLevel)) return new BudgetRange(new BigDecimal("18"), new BigDecimal("35"));
        if ("plus".equals(budgetLevel)) return new BudgetRange(new BigDecimal("40"), new BigDecimal("75"));
        return new BudgetRange(new BigDecimal("25"), new BigDecimal("55"));
    }

    private Long buildPlanId() {
        return Long.parseLong(String.valueOf(System.currentTimeMillis()) + ThreadLocalRandom.current().nextInt(10, 99));
    }

    private int resolveServingCount(String peopleCount) {
        if ("3_4".equals(peopleCount)) return 3;
        if ("2".equals(peopleCount)) return 2;
        return 1;
    }

    private BudgetRange scaleBudgetRange(BudgetRange base, int servingCount) {
        if (base == null || servingCount <= 1) return base;
        BigDecimal factor = BigDecimal.valueOf(servingCount);
        BigDecimal min = base.min.multiply(factor).setScale(2, RoundingMode.HALF_UP);
        BigDecimal max = base.max.multiply(factor).setScale(2, RoundingMode.HALF_UP);
        return new BudgetRange(min, max);
    }

    private boolean isFruitLike(String text) {
        return safe(text, "").matches(".*(果|莓|苹果|橙|梨|葡萄|香蕉|桃|柠檬|樱桃|枇杷|瓜|菠萝|无花果|桑葚).*");
    }

    private boolean isMealMainLike(String text) {
        return safe(text, "").matches(".*(菌|菇|番茄|土豆|南瓜|玉米|山药|红薯|芋头|胡萝卜|彩椒|豆腐|茄子).*");
    }

    private boolean isMealSideLike(String text) {
        return safe(text, "").matches(".*(菜|生菜|菠菜|油麦|空心菜|西兰花|花菜|黄瓜|秋葵|豆角|荷兰豆|豌豆|毛豆|四季豆|笋|菜花|西葫芦|苦瓜).*");
    }

    private boolean isComboBaseLike(String text) {
        return safe(text, "").matches(".*(番茄|黄瓜|胡萝卜|玉米|土豆|南瓜|山药|红薯|芋头|西兰花|菌|菇|苹果|橙|柠檬).*");
    }

    private boolean isComboVegLike(String text) {
        return safe(text, "").matches(".*(菜|生菜|菠菜|油麦|空心菜|黄瓜|秋葵|荷兰豆|豌豆|毛豆|四季豆|豆角|西兰花|花菜|笋|西葫芦|苦瓜|番茄).*");
    }

    private BigDecimal safePrice(BigDecimal value, BigDecimal fallback) {
        return value == null ? fallback : value;
    }

    private int safeInt(Integer value) {
        return value == null ? 0 : value;
    }

    private String safe(String value, String fallback) {
        if (value == null || value.trim().isEmpty()) return fallback;
        return value.trim();
    }

    private String normalizePlanSourceType(String sourceType, String planType) {
        String explicit = safe(sourceType, "").toUpperCase();
        if (CartInfo.SOURCE_TYPE_MEAL.equals(explicit) || CartInfo.SOURCE_TYPE_COMBO.equals(explicit)) {
            return explicit;
        }
        return "combo".equalsIgnoreCase(safe(planType, "")) ? CartInfo.SOURCE_TYPE_COMBO : CartInfo.SOURCE_TYPE_MEAL;
    }

    private String normalizePlanSourceScene(String planType, String sourceScene) {
        String scene = safe(sourceScene, "");
        if (!scene.isEmpty()) return scene;
        return "combo".equalsIgnoreCase(safe(planType, "")) ? "蔬果搭配" : "一人食";
    }

    private void prepareTagCache(List<Goods> goodsList) {
        if (goodsList == null || goodsList.isEmpty()) {
            goodsTagCodeMapCache = Collections.emptyMap();
            return;
        }
        List<Long> ids = goodsList.stream().map(Goods::getId).collect(Collectors.toList());
        List<Map<String, Object>> rows = goodsTagMapper.selectTagCodesByGoodsIds(ids);
        Map<Long, Set<String>> map = new HashMap<>();
        for (Map<String, Object> row : rows) {
            Long goodsId = row.get("goodsId") == null ? null : Long.valueOf(String.valueOf(row.get("goodsId")));
            String tagCode = row.get("tagCode") == null ? "" : String.valueOf(row.get("tagCode")).trim();
            if (goodsId == null || tagCode.isEmpty()) continue;
            map.computeIfAbsent(goodsId, k -> new HashSet<>()).add(tagCode);
        }
        goodsTagCodeMapCache = map;
    }

    private boolean hasTag(Goods goods, String tagCode) {
        if (goods == null || goods.getId() == null || tagCode == null || tagCode.isEmpty()) return false;
        Set<String> codes = goodsTagCodeMapCache.get(goods.getId());
        return codes != null && codes.contains(tagCode);
    }

    private String sceneToTagCode(String goalScene) {
        if ("salad".equals(goalScene)) return "scene_combo_salad";
        if ("juice".equals(goalScene)) return "scene_combo_juice";
        if ("hotpot".equals(goalScene)) return "scene_combo_hotpot";
        if ("bento_side".equals(goalScene)) return "scene_combo_bento_side";
        return "";
    }

    private static class BudgetRange {
        private final BigDecimal min;
        private final BigDecimal max;

        private BudgetRange(BigDecimal min, BigDecimal max) {
            this.min = min;
            this.max = max;
        }
    }

    private static class WeightProfile {
        private final String version;
        private final int smallPortionWeight;
        private final int salesWeight;
        private final int stockWeight;
        private final int budgetWeight;

        private WeightProfile(String version, int smallPortionWeight, int salesWeight, int stockWeight, int budgetWeight) {
            this.version = version;
            this.smallPortionWeight = smallPortionWeight;
            this.salesWeight = salesWeight;
            this.stockWeight = stockWeight;
            this.budgetWeight = budgetWeight;
        }
    }

    private static class PlanItem {
        private Long goodsId;
        private Long skuId;
        private String name;
        private String skuName;
        private String image;
        private Integer quantity;
        private String role;
        private String reason;
        private List<String> reasonTags;
        private BigDecimal price;
        private BigDecimal originalPrice;
        private Integer gramsEstimate;

        public Long getGoodsId() { return goodsId; }
        public void setGoodsId(Long goodsId) { this.goodsId = goodsId; }
        public Long getSkuId() { return skuId; }
        public void setSkuId(Long skuId) { this.skuId = skuId; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getSkuName() { return skuName; }
        public void setSkuName(String skuName) { this.skuName = skuName; }
        public String getImage() { return image; }
        public void setImage(String image) { this.image = image; }
        public Integer getQuantity() { return quantity; }
        public void setQuantity(Integer quantity) { this.quantity = quantity; }
        public String getRole() { return role; }
        public void setRole(String role) { this.role = role; }
        public String getReason() { return reason; }
        public void setReason(String reason) { this.reason = reason; }
        public List<String> getReasonTags() { return reasonTags; }
        public void setReasonTags(List<String> reasonTags) { this.reasonTags = reasonTags; }
        public BigDecimal getPrice() { return price; }
        public void setPrice(BigDecimal price) { this.price = price; }
        public BigDecimal getOriginalPrice() { return originalPrice; }
        public void setOriginalPrice(BigDecimal originalPrice) { this.originalPrice = originalPrice; }
        public Integer getGramsEstimate() { return gramsEstimate; }
        public void setGramsEstimate(Integer gramsEstimate) { this.gramsEstimate = gramsEstimate; }
    }
}
