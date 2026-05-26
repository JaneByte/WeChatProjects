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
import com.example.freshtime.mapper.PlanRuleConfigMapper;
import com.example.freshtime.mapper.SeasonalConfigMapper;
import com.example.freshtime.service.PlanService;
import com.example.freshtime.service.impl.support.PlanPricingHelper;
import com.example.freshtime.service.impl.support.PlanRoleHelper;
import com.example.freshtime.service.impl.support.PlanRuleHelper;
import com.example.freshtime.service.impl.support.PlanScoringHelper;
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
    private SeasonalConfigMapper seasonalConfigMapper;

    private Map<Long, Set<String>> goodsTagCodeMapCache = Collections.emptyMap();
    private final ThreadLocal<Map<String, String>> planRuleConfigThreadCache = new ThreadLocal<>();
    private static final Map<String, String> DEFAULT_PLAN_RULES = PlanRuleHelper.buildDefaultPlanRules();
    private static final Map<String, String> DEFAULT_PACK_PRICING_RULES = buildDefaultPackPricingRules();

    @Override
    public ApiResponse<?> generateMealPlan(Long userId, GenerateMealPlanRequest request) {
        beginPlanRuleContext();
        try {
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
        List<Goods> allPool = excludeDislikedGoods(
                filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), null),
                request.getDislikeGoodsIds()
        );
        List<Goods> pool = excludeDislikedGoods(
                filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), request.getDislikeTags()),
                request.getDislikeGoodsIds()
        );
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
        List<Goods> previousPlanGoods = loadPreviousPlanGoods(request.getPreviousPlanGoodsIds());
        Goods mainGoods = pickBestMealGoods(pool, categoryMap, "veg", budget, dietGoal, cookMode, profile, userId, shuffleSeed, previousPlanGoods.size() > 0 ? previousPlanGoods.get(0) : null, null);
        Goods sideGoods = pickBestMealGoods(pool, categoryMap, "veg", budget, dietGoal, cookMode, profile, userId, shuffleSeed, previousPlanGoods.size() > 1 ? previousPlanGoods.get(1) : null, mainGoods == null ? null : mainGoods.getId());
        Goods fruitGoods = pickBestMealGoods(pool, categoryMap, "fruit", budget, dietGoal, cookMode, profile, userId, shuffleSeed, previousPlanGoods.size() > 2 ? previousPlanGoods.get(2) : null, sideGoods == null ? (mainGoods == null ? null : mainGoods.getId()) : sideGoods.getId(), mainGoods == null ? null : mainGoods.getId());

        if (mainGoods == null || sideGoods == null || fruitGoods == null) {
            List<Goods> fallbackItems = pickMealFallbackGoods(pool, categoryMap);
            if (fallbackItems.size() < 3) {
                return ApiResponse.badRequest("当前在售商品较少，暂时还配不出合适的小份优选");
            }
            warnings.add("已根据当前在售商品为你放宽条件，优先挑选一份更稳妥的小份组合");
            mainGoods = fallbackItems.get(0);
            sideGoods = fallbackItems.get(1);
            fruitGoods = fallbackItems.get(2);
        }

        List<PlanItem> baseItems = new ArrayList<>();
        baseItems.add(buildPlanItem(mainGoods, "veg", "这份适合作为蔬菜主食材", "meal"));
        baseItems.add(buildPlanItem(sideGoods, "veg", "这一项补充蔬菜搭配", "meal"));
        baseItems.add(buildPlanItem(fruitGoods, "fruit", "这一项补充清爽口感", "meal"));

        List<PlanItem> items = enforceBudget(baseItems, pool, categoryMap, budget, "meal", dietGoal, null, profile, userId);
        if (!isStrictMealComposition(items)) {
            items = new ArrayList<>(baseItems);
        }
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
        } finally {
            endPlanRuleContext();
        }
    }

    @Override
    public ApiResponse<?> generateComboPlan(Long userId, GenerateComboPlanRequest request) {
        beginPlanRuleContext();
        try {
        if (request == null) {
            return ApiResponse.badRequest("请求参数不能为空");
        }

        WeightProfile profile = resolveWeightProfile("combo");
        String goalScene = safe(request.getGoalScene(), "salad");
        String peopleCount = safe(request.getPeopleCount(), "1");
        String tastePref = safe(request.getTastePref(), "fresh");
        Long shuffleSeed = request.getShuffleSeed();
        boolean preferVegOnly = shouldPreferVegOnlyCombo(goalScene);
        BudgetRange budget = scaleBudgetRange(resolveBudgetRange(safe(request.getBudgetLevel(), "standard"), "combo"), resolveServingCount(peopleCount));

        List<Goods> pool = excludeDislikedGoods(
                filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), null),
                request.getDislikeGoodsIds()
        );
        List<String> warnings = new ArrayList<>();
        if (pool.size() < 3) {
            return ApiResponse.badRequest("可用商品不足，暂无法生成搭配");
        }
        prepareTagCache(pool);

        Map<Long, Category> categoryMap = loadCategoryMap();
        List<Goods> previousPlanGoods = loadPreviousPlanGoods(request.getPreviousPlanGoodsIds());
        Goods firstVegGoods = pickBestComboGoods(pool, categoryMap, goalScene, "veg", peopleCount, tastePref, profile, true, userId, shuffleSeed, previousPlanGoods.size() > 0 ? previousPlanGoods.get(0) : null, null);
        if (firstVegGoods == null) {
            firstVegGoods = pickFallbackComboGoods(pool, categoryMap, "veg", null);
        }
        Goods secondVegGoods = pickBestComboGoods(pool, categoryMap, goalScene, "veg", peopleCount, tastePref, profile, false, userId, shuffleSeed, previousPlanGoods.size() > 1 ? previousPlanGoods.get(1) : null, firstVegGoods == null ? null : firstVegGoods.getId());
        if (secondVegGoods == null) {
            secondVegGoods = pickFallbackComboGoods(pool, categoryMap, "veg", firstVegGoods == null ? null : firstVegGoods.getId());
        }
        String thirdRole = preferVegOnly ? "veg" : "fruit";
        Goods thirdGoods = pickBestComboGoods(pool, categoryMap, goalScene, thirdRole, peopleCount, tastePref, profile, false, userId, shuffleSeed, previousPlanGoods.size() > 2 ? previousPlanGoods.get(2) : null, secondVegGoods == null ? null : secondVegGoods.getId(), firstVegGoods == null ? null : firstVegGoods.getId());
        if (thirdGoods == null) {
            thirdGoods = pickFallbackComboGoods(pool, categoryMap, thirdRole, secondVegGoods == null ? null : secondVegGoods.getId(), firstVegGoods == null ? null : firstVegGoods.getId());
        }

        if (firstVegGoods == null || secondVegGoods == null || thirdGoods == null) {
            List<Goods> fallbackPool = new ArrayList<>(pool);
            fallbackPool.removeIf(g -> containsHardConflictKeyword(g, goalScene));
            if (fallbackPool.size() < 3) {
                fallbackPool = new ArrayList<>(pool);
            }
            List<Goods> fallbackItems = pickComboFallbackGoods(fallbackPool, categoryMap, goalScene);
            if (fallbackItems.size() < 3) {
                fallbackItems = pickComboFallbackGoods(new ArrayList<>(pool), categoryMap, "");
            }
            if (fallbackItems.size() < 3) {
                return ApiResponse.badRequest("当前在售商品较少，暂时还配不出合适搭配");
            }
            warnings.add("已根据当前在售商品为你优先挑选一组顺手好搭的组合");
            firstVegGoods = fallbackItems.get(0);
            secondVegGoods = fallbackItems.get(1);
            thirdGoods = fallbackItems.get(2);
        }

        List<PlanItem> items = new ArrayList<>();
        items.add(buildPlanItem(firstVegGoods, "veg", "这份食材更适合作为当前场景的优先搭配", "combo", peopleCount));
        items.add(buildPlanItem(secondVegGoods, "veg", "这一项补足蔬菜搭配层次", "combo", peopleCount));
        items.add(buildPlanItem(thirdGoods, thirdRole, preferVegOnly ? "这一项补足耐煮和配锅层次" : "这一项能提升风味和新鲜感", "combo", peopleCount));

        items = enforceBudget(items, pool, categoryMap, budget, "combo", goalScene, peopleCount, profile, userId);
        BigDecimal totalPrice = calcTotal(items);
        if (totalPrice.compareTo(budget.min) < 0 || totalPrice.compareTo(budget.max) > 0) {
            warnings.add("当前库存下无法严格满足预算，已返回最接近预算搭配");
        }

        Map<String, Object> data = new LinkedHashMap<>();
        data.put("comboId", buildPlanId());
        data.put("comboName", buildComboName(goalScene));
        data.put("items", toItemMaps(items));
        data.put("prepHint", buildPrepHint(goalScene));
        data.put("priceSummary", buildPriceSummary(items, totalPrice, "combo"));
        data.put("warnings", warnings);
        data.put("strategySummary", buildStrategySummary("combo", profile, !warnings.isEmpty(), warnings));
        data.put("replaceOptions", new HashMap<>());
        return ApiResponse.success(data);
        } finally {
            endPlanRuleContext();
        }
    }

    @Override
    public ApiResponse<?> replacePlanItem(Long userId, ReplacePlanItemRequest request) {
        beginPlanRuleContext();
        try {
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
        String resolvedPlanType = safe(request.getPlanType(), "meal");
        String resolvedGoalScene = safe(request.getGoalScene(), "");
        String resolvedPeopleCount = safe(request.getPeopleCount(), "1");
        int itemIndex = request.getItemIndex() == null ? -1 : request.getItemIndex();
        String role = resolveReplacementRole(originGoods, request, categoryMap, resolvedPlanType, resolvedGoalScene);
        Set<Long> currentGoodsIds = request.getCurrentGoodsIds() == null ? Collections.emptySet()
                : request.getCurrentGoodsIds().stream()
                .filter(id -> id != null && !id.equals(originGoods.getId()))
                .collect(Collectors.toSet());
        List<Goods> pool = filterAvailableGoods(goodsMapper.selectAdminGoodsList(null, 1, null), null);
        prepareTagCache(pool);

        BigDecimal originPrice = safePrice(originSku.getSkuPrice(), safePrice(originGoods.getPrice(), BigDecimal.ZERO));
        WeightProfile replacementProfile = resolveWeightProfile("combo".equals(resolvedPlanType) ? "combo" : resolvedPlanType);
        List<Goods> replacementCandidates = collectReplacementCandidates(pool, request, categoryMap, resolvedPlanType, resolvedGoalScene, resolvedPeopleCount, role, currentGoodsIds, originGoods, originPrice, replacementProfile, itemIndex);
        Goods replacement = replacementCandidates.isEmpty() ? null : pickWithRotation(
                replacementCandidates,
                userId,
                System.currentTimeMillis(),
                "replace-" + resolvedPlanType + "-" + role + "-" + safe(request.getOriginSkuId() == null ? null : String.valueOf(request.getOriginSkuId()), "0")
        );

        if (replacement == null) {
            return ApiResponse.badRequest("该组合项当前暂无可替换商品");
        }

        PlanItem item = buildPlanItem(replacement, role, buildReplacementReason(role, resolvedPlanType), resolvedPlanType, "combo".equals(resolvedPlanType) ? resolvedPeopleCount : null);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("item", toItemMap(item));
        List<PlanItem> singleItemList = new ArrayList<>();
        singleItemList.add(item);
        data.put("priceSummary", buildPriceSummary(singleItemList, item.getPrice(), safe(request.getPlanType(), "meal")));
        data.put("message", "替换成功");
        return ApiResponse.success(data);
        } finally {
            endPlanRuleContext();
        }
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
            Long goodsId = row == null ? null : row.getGoodsId();
            Long skuId = row == null ? null : row.getSkuId();
            int quantity = row == null || row.getQuantity() == null || row.getQuantity() <= 0 ? 1 : row.getQuantity();
            try {
                String sourceType = normalizePlanSourceType(row == null ? null : row.getSourceType(), request.getPlanType());
                Long sourcePlanId = row != null && row.getSourcePlanId() != null ? row.getSourcePlanId() : request.getPlanId();
                String sourceScene = normalizePlanSourceScene(request.getPlanType(), row == null ? null : row.getSourceScene());

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
                    saveCart(insert);
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
                updateCart(cart);
                successCount += 1;
            } catch (Exception ex) {
                failedItems.add(buildFailedItem(goodsId, skuId, quantity, "ADD_CART_ERROR", "加入购物车失败，请稍后重试"));
            }
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
            if (isExcludedFromPlan(g)) continue;
            GoodsSku sku = firstAvailableSku(g.getId());
            if (sku == null) continue;
            result.add(g);
        }
        return result;
    }

    private List<Goods> excludeDislikedGoods(List<Goods> source, List<Long> dislikeGoodsIds) {
        if (source == null || source.isEmpty() || dislikeGoodsIds == null || dislikeGoodsIds.isEmpty()) {
            return source;
        }
        Set<Long> excludeSet = dislikeGoodsIds.stream()
                .filter(id -> id != null && id > 0)
                .collect(Collectors.toSet());
        if (excludeSet.isEmpty()) {
            return source;
        }
        return source.stream()
                .filter(g -> g != null && g.getId() != null && !excludeSet.contains(g.getId()))
                .collect(Collectors.toList());
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
        if (PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.global_blacklist_keywords"))) {
            return true;
        }
        if ("juice".equals(typeOrGoal)) {
            return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.juice_blacklist_keywords"));
        }
        if ("salad".equals(typeOrGoal)) {
            return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.salad_blacklist_keywords"));
        }
        if ("hotpot".equals(typeOrGoal)) {
            return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.hotpot_blacklist_keywords"));
        }
        if ("bento_side".equals(typeOrGoal)) {
            return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.bento_blacklist_keywords"));
        }
        if ("meal".equals(typeOrGoal)) {
            return false;
        }
        return false;
    }

    private Goods pickBestMealGoods(List<Goods> pool, Map<Long, Category> categoryMap, String role, BudgetRange budget, String dietGoal, String cookMode, WeightProfile profile, Long userId, Long shuffleSeed, Goods previousSlotGoods, Long... excludes) {
        boolean preferSatiety = "veg".equals(role) && (excludes == null || excludes.length == 0 || excludes[0] == null);
        List<Goods> candidates = pool.stream()
                .filter(g -> !isExcluded(g.getId(), excludes))
                .filter(g -> roleMatched(g, role, categoryMap, "meal"))
                .filter(g -> !containsHardConflictKeyword(g, "meal"))
                .filter(g -> !hasConflictWithGoods(g, "meal", "meal", excludes))
                .sorted((a, b) -> Integer.compare(
                        scoreMealGoods(b, role, budget, dietGoal, cookMode, categoryMap, profile, preferSatiety) - scoreRegenerateSimilarityPenalty(b, previousSlotGoods, categoryMap),
                        scoreMealGoods(a, role, budget, dietGoal, cookMode, categoryMap, profile, preferSatiety) - scoreRegenerateSimilarityPenalty(a, previousSlotGoods, categoryMap)
                ))
                .limit(3)
                .collect(Collectors.toList());
        return pickWithRotation(candidates, userId, shuffleSeed, "meal-" + role);
    }

    private Goods pickBestComboGoods(List<Goods> pool, Map<Long, Category> categoryMap, String goalScene, String role, String peopleCount, String tastePref, WeightProfile profile, boolean preferSatiety, Long userId, Long shuffleSeed, Goods previousSlotGoods, Long... excludes) {
        List<Goods> ranked = pool.stream()
                .filter(g -> !isExcluded(g.getId(), excludes))
                .filter(g -> !isSeasoningLike(g))
                .filter(g -> roleMatched(g, role, categoryMap, "combo"))
                .filter(g -> !containsHardConflictKeyword(g, goalScene))
                .filter(g -> !hasConflictWithGoods(g, "combo", goalScene, excludes))
                .sorted((a, b) -> Integer.compare(
                        scoreComboGoods(b, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety) - scoreRegenerateSimilarityPenalty(b, previousSlotGoods, categoryMap),
                        scoreComboGoods(a, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety) - scoreRegenerateSimilarityPenalty(a, previousSlotGoods, categoryMap)
                ))
                .collect(Collectors.toList());
        List<Goods> candidates = retainStrongComboCandidates(ranked, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety);
        if (candidates.isEmpty()) {
            candidates = pool.stream()
                    .filter(g -> !isExcluded(g.getId(), excludes))
                    .filter(g -> !isSeasoningLike(g))
                    .filter(g -> roleMatched(g, role, categoryMap, "combo"))
                    .filter(g -> !hasConflictWithGoods(g, "combo", goalScene, excludes))
                    .sorted((a, b) -> Integer.compare(
                            scoreComboGoods(b, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety) - scoreRegenerateSimilarityPenalty(b, previousSlotGoods, categoryMap),
                            scoreComboGoods(a, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety) - scoreRegenerateSimilarityPenalty(a, previousSlotGoods, categoryMap)
                    ))
                    .collect(Collectors.toList());
            candidates = retainStrongComboCandidates(candidates, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety);
        }
        if (candidates.size() > 6) {
            candidates = new ArrayList<>(candidates.subList(0, 6));
        }
        return pickWithRotation(candidates, userId, shuffleSeed, "combo-" + role);
    }

    private Goods pickFallbackComboGoods(List<Goods> pool, Map<Long, Category> categoryMap, String role, Long... excludes) {
        for (Goods goods : pool) {
            if (goods == null || isExcluded(goods.getId(), excludes)) continue;
            String text = safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "");
            if (isSeasoningLike(text)) continue;
            if ("fruit".equals(role) && roleMatched(goods, "fruit", categoryMap, "combo")) return goods;
            if ("base".equals(role) && (roleMatched(goods, "base", categoryMap, "combo") || PlanRoleHelper.isComboBaseLike(text))) return goods;
            if ("veg".equals(role) && (roleMatched(goods, "veg", categoryMap, "combo") || PlanRoleHelper.isComboVegLike(text))) return goods;
        }
        return null;
    }

    private List<Goods> pickComboFallbackGoods(List<Goods> pool, Map<Long, Category> categoryMap, String goalScene) {
        List<Goods> ranked = new ArrayList<>(pool);
        ranked.sort((a, b) -> Integer.compare(scoreComboGoods(b, goalScene, inferRoleByGoods(b, categoryMap, "combo"), "1", "fresh", categoryMap, resolveWeightProfile("combo"), false),
                scoreComboGoods(a, goalScene, inferRoleByGoods(a, categoryMap, "combo"), "1", "fresh", categoryMap, resolveWeightProfile("combo"), false)));
        List<Goods> result = new ArrayList<>();
        Goods fruit = null;
        Goods firstVeg = null;
        Goods secondVeg = null;
        boolean preferVegOnly = shouldPreferVegOnlyCombo(goalScene);
        for (Goods goods : ranked) {
            if (goods == null) continue;
            if (isSeasoningLike(goods)) continue;
            if (!preferVegOnly && fruit == null && roleMatched(goods, "fruit", categoryMap, "combo")) {
                fruit = goods;
                continue;
            }
            if (firstVeg == null && roleMatched(goods, "veg", categoryMap, "combo")) {
                firstVeg = goods;
                continue;
            }
            if (secondVeg == null && roleMatched(goods, "veg", categoryMap, "combo") && (firstVeg == null || !firstVeg.getId().equals(goods.getId()))) {
                secondVeg = goods;
            }
            if ((preferVegOnly || fruit != null) && firstVeg != null && secondVeg != null) break;
        }
        if (firstVeg != null) result.add(firstVeg);
        if (secondVeg != null && !result.contains(secondVeg)) result.add(secondVeg);
        if (preferVegOnly) {
            for (Goods goods : ranked) {
                if (result.size() >= 3) break;
                if (goods != null && !result.contains(goods) && roleMatched(goods, "veg", categoryMap, "combo") && !isSeasoningLike(goods)) {
                    result.add(goods);
                }
            }
        } else if (fruit != null && !result.contains(fruit)) {
            result.add(fruit);
        }
        for (Goods goods : ranked) {
            if (result.size() >= 3) break;
            if (goods != null && !result.contains(goods)) {
                result.add(goods);
            }
        }
        return result;
    }

    private List<Goods> pickMealFallbackGoods(List<Goods> pool, Map<Long, Category> categoryMap) {
        List<Goods> ranked = new ArrayList<>(pool);
        ranked.sort((a, b) -> Integer.compare(
                scoreMealGoods(b, "veg", resolveBudgetRange("standard", "meal"), "balanced", "quick_cook", categoryMap, resolveWeightProfile("meal"), true),
                scoreMealGoods(a, "veg", resolveBudgetRange("standard", "meal"), "balanced", "quick_cook", categoryMap, resolveWeightProfile("meal"), true)
        ));

        Goods firstVeg = null;
        Goods secondVeg = null;
        Goods fruit = null;
        for (Goods goods : ranked) {
            if (goods == null) continue;
            if (firstVeg == null && roleMatched(goods, "veg", categoryMap, "meal") && !isSeasoningLike(goods)) {
                firstVeg = goods;
                continue;
            }
            if (secondVeg == null && roleMatched(goods, "veg", categoryMap, "meal") && !isSeasoningLike(goods)
                    && (firstVeg == null || !firstVeg.getId().equals(goods.getId()))) {
                secondVeg = goods;
                continue;
            }
            if (fruit == null && roleMatched(goods, "fruit", categoryMap, "meal")) {
                fruit = goods;
            }
        }

        List<Goods> result = new ArrayList<>();
        if (firstVeg != null) result.add(firstVeg);
        if (secondVeg != null) result.add(secondVeg);
        if (fruit != null) result.add(fruit);

        if (result.size() < 3) {
            for (Goods goods : ranked) {
                if (goods == null) continue;
                boolean exists = result.stream().anyMatch(item -> item.getId().equals(goods.getId()));
                if (!exists) {
                    result.add(goods);
                }
                if (result.size() >= 3) break;
            }
        }
        return result;
    }

    private List<Goods> loadPreviousPlanGoods(List<Long> previousPlanGoodsIds) {
        List<Goods> result = new ArrayList<>();
        if (previousPlanGoodsIds == null || previousPlanGoodsIds.isEmpty()) {
            return result;
        }
        for (Long goodsId : previousPlanGoodsIds) {
            if (goodsId == null || goodsId <= 0) {
                result.add(null);
                continue;
            }
            result.add(goodsMapper.selectById(goodsId));
        }
        return result;
    }

    private int scoreRegenerateSimilarityPenalty(Goods candidate, Goods previousSlotGoods, Map<Long, Category> categoryMap) {
        if (candidate == null || candidate.getId() == null || previousSlotGoods == null || previousSlotGoods.getId() == null) {
            return 0;
        }
        int penalty = 0;
        if (candidate.getId().equals(previousSlotGoods.getId())) {
            penalty += 80;
        }
        if (candidate.getCategoryId() != null && candidate.getCategoryId().equals(previousSlotGoods.getCategoryId())) {
            penalty += 18;
        }
        String candidateText = (safe(candidate.getName(), "") + "," + safe(candidate.getKeywords(), "")).toLowerCase();
        String previousText = (safe(previousSlotGoods.getName(), "") + "," + safe(previousSlotGoods.getKeywords(), "")).toLowerCase();
        if (PlanRuleHelper.isSimilarProduceFamily(candidateText, previousText)) {
            penalty += 20;
        }
        Set<String> candidateTags = getTagCodes(candidate);
        Set<String> previousTags = getTagCodes(previousSlotGoods);
        if (!candidateTags.isEmpty() && !previousTags.isEmpty()) {
            Set<String> overlap = new HashSet<>(candidateTags);
            overlap.retainAll(previousTags);
            penalty += Math.min(12, overlap.size() * 4);
        }
        Category candidateCategory = categoryMap == null ? null : categoryMap.get(candidate.getCategoryId());
        Category previousCategory = categoryMap == null ? null : categoryMap.get(previousSlotGoods.getCategoryId());
        if (candidateCategory != null && previousCategory != null) {
            String candidateName = safe(candidateCategory.getName(), "");
            String previousName = safe(previousCategory.getName(), "");
            if (!candidateName.isEmpty() && candidateName.equals(previousName)) {
                penalty += 8;
            }
        }
        return penalty;
    }

    private boolean isExcluded(Long id, Long... excludes) {
        if (id == null || excludes == null) return false;
        for (Long ex : excludes) {
            if (ex != null && ex.equals(id)) return true;
        }
        return false;
    }

    private int scoreMealGoods(Goods g, String role, BudgetRange budget, String dietGoal, String cookMode, Map<Long, Category> categoryMap, WeightProfile profile, boolean preferSatiety) {
        int baseScore = PlanScoringHelper.scoreMealGoods(
                g,
                role,
                budget.min,
                budget.max,
                dietGoal,
                cookMode,
                preferSatiety,
                profile.salesWeight,
                profile.stockWeight,
                profile.budgetWeight,
                roleMatched(g, role, categoryMap, "meal"),
                getTagCodes(g),
                goods -> safePrice(firstAvailableSkuPrice(goods), safePrice(goods.getPrice(), BigDecimal.ZERO)),
                mealRole -> scoreMealPortionFit(g, mealRole),
                input -> scoreCommonConstraintFit(input.getGoods(), input.getRole(), input.getSceneKey())
        );
        return baseScore + scoreMealTagFit(g, role, dietGoal, cookMode, preferSatiety);
    }

    private int scoreComboGoods(Goods g, String goalScene, String role, String peopleCount, String tastePref, Map<Long, Category> categoryMap, WeightProfile profile, boolean preferSatiety) {
        String sceneTagCode = sceneToTagCode(goalScene);
        int baseScore = PlanScoringHelper.scoreComboGoods(
                g,
                goalScene,
                role,
                peopleCount,
                tastePref,
                preferSatiety,
                profile.salesWeight,
                profile.stockWeight,
                roleMatched(g, role, categoryMap, "combo"),
                !sceneTagCode.isEmpty() && hasTag(g, sceneTagCode),
                hasTag(g, "scene_combo_mix"),
                input -> scoreCommonConstraintFit(input.getGoods(), input.getRole(), input.getSceneKey()),
                count -> scorePeopleCountFit(g, role, count),
                getTagCodes(g)
        );
        return baseScore + scoreComboTagFit(g, goalScene, role, peopleCount, preferSatiety);
    }

    private List<PlanItem> enforceBudget(List<PlanItem> items, List<Goods> pool, Map<Long, Category> categoryMap, BudgetRange budget, String type, String goal, String peopleCount, WeightProfile profile, Long userId) {
        BigDecimal total = calcTotal(items);
        if (total.compareTo(budget.min) >= 0 && total.compareTo(budget.max) <= 0) return items;

        List<PlanItem> best = new ArrayList<>(items);
        BigDecimal bestGap = budgetDistance(total, budget);

        for (int i = 0; i < items.size(); i++) {
            String role = items.get(i).getRole();
            List<Goods> candidates = collectBudgetCandidates(pool, items, i, categoryMap, type, goal, peopleCount, profile, role);
            for (Goods g : candidates) {
                if (isDuplicateGoodsCandidate(g, items, i)) continue;
                GoodsSku sku = "combo".equals(type)
                        ? selectPreferredComboSku(g.getId(), role, peopleCount, profile)
                        : selectPreferredSku(g.getId(), role, type, profile);
                if (sku == null) continue;
                PlanItem candidateItem = buildPlanItem(g, role, items.get(i).getReason(), type, peopleCount);
                if (candidateItem == null) continue;
                List<PlanItem> candidate = new ArrayList<>(items);
                candidate.set(i, candidateItem);
                if ("meal".equals(type) && !isStrictMealComposition(candidate)) continue;
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
        if ("meal".equals(type) && !isStrictMealComposition(best)) {
            return items;
        }
        return best;
    }

    private List<Goods> collectBudgetCandidates(List<Goods> pool, List<PlanItem> items, int replaceIndex, Map<Long, Category> categoryMap, String type, String goal, String peopleCount, WeightProfile profile, String role) {
        List<Goods> candidates = new ArrayList<>();
        for (Goods g : pool) {
            if (isDuplicateGoodsCandidate(g, items, replaceIndex)) continue;
            if (!roleMatched(g, role, categoryMap, type)) continue;
            if (containsHardConflictKeyword(g, goal)) continue;
            if (violatesCompositionRules(g, items, replaceIndex, type, goal)) continue;
            if ("combo".equals(type) && !isStrongBudgetComboCandidate(g, goal, role, peopleCount, categoryMap, profile)) continue;
            candidates.add(g);
        }
        if ("combo".equals(type)) {
            candidates.sort((a, b) -> Integer.compare(
                    scoreComboGoods(b, goal, role, peopleCount, "fresh", categoryMap, profile, false),
                    scoreComboGoods(a, goal, role, peopleCount, "fresh", categoryMap, profile, false)
            ));
        }
        return candidates;
    }

    private boolean isStrongBudgetComboCandidate(Goods goods, String goalScene, String role, String peopleCount, Map<Long, Category> categoryMap, WeightProfile profile) {
        int comboScore = scoreComboGoods(goods, goalScene, role, peopleCount, "fresh", categoryMap, profile, false);
        int sceneScore = scoreComboSceneFit(goods, goalScene, role);
        int constraintScore = scoreCommonConstraintFit(goods, role, goalScene);
        if (sceneScore < 0 || constraintScore < -8) {
            return false;
        }
        return comboScore >= resolveComboBudgetScoreFloor(goalScene, role);
    }

    private int resolveComboBudgetScoreFloor(String goalScene, String role) {
        if ("hotpot".equals(goalScene)) {
            return "veg".equals(role) ? 42 : 36;
        }
        if ("juice".equals(goalScene)) {
            return "fruit".equals(role) ? 34 : 30;
        }
        if ("salad".equals(goalScene)) {
            return 32;
        }
        if ("bento_side".equals(goalScene)) {
            return 34;
        }
        return 28;
    }

    private List<Goods> retainStrongComboCandidates(List<Goods> ranked, String goalScene, String role, String peopleCount, String tastePref, Map<Long, Category> categoryMap, WeightProfile profile, boolean preferSatiety) {
        if (ranked == null || ranked.isEmpty()) {
            return new ArrayList<>();
        }
        int topScore = scoreComboGoods(ranked.get(0), goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety);
        int floor = Math.max(resolveComboCandidateScoreFloor(goalScene, role), topScore - 10);
        List<Goods> strong = ranked.stream()
                .filter(g -> scoreComboGoods(g, goalScene, role, peopleCount, tastePref, categoryMap, profile, preferSatiety) >= floor)
                .limit(6)
                .collect(Collectors.toList());
        if (!strong.isEmpty()) {
            return strong;
        }
        return new ArrayList<>(ranked.subList(0, Math.min(4, ranked.size())));
    }

    private int resolveComboCandidateScoreFloor(String goalScene, String role) {
        if ("hotpot".equals(goalScene)) {
            return "veg".equals(role) ? 46 : 38;
        }
        if ("juice".equals(goalScene)) {
            return "fruit".equals(role) ? 34 : 30;
        }
        if ("salad".equals(goalScene)) {
            return 32;
        }
        if ("bento_side".equals(goalScene)) {
            return 34;
        }
        return 30;
    }

    private boolean isDuplicateGoodsCandidate(Goods candidate, List<PlanItem> items, int replaceIndex) {
        if (candidate == null || candidate.getId() == null || items == null) return false;
        for (int i = 0; i < items.size(); i++) {
            if (i == replaceIndex) continue;
            PlanItem item = items.get(i);
            if (item == null || item.getGoodsId() == null) continue;
            if (candidate.getId().equals(item.getGoodsId())) {
                return true;
            }
        }
        return false;
    }

    private BigDecimal budgetDistance(BigDecimal total, BudgetRange budget) {
        if (total.compareTo(budget.min) < 0) return budget.min.subtract(total);
        if (total.compareTo(budget.max) > 0) return total.subtract(budget.max);
        return BigDecimal.ZERO;
    }

    private boolean roleMatched(Goods g, String role, Map<Long, Category> categoryMap, String type) {
        return PlanRoleHelper.roleMatched(g, role, categoryMap, type, getTagCodes(g));
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
            if ("fruit".equals(role) && text.matches(".*(榴莲|椰子|樱桃|青柠|柠檬|草莓|蓝莓|杨桃|葡萄|柚子|梨|橙).*")) return -18;
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
            if ("fruit".equals(role) && PlanRoleHelper.isFruitLike(text)) return 10;
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
        if ("hotpot".equals(sceneKey) && isSeasoningLike(text)) score -= 22;
        if ("hotpot".equals(sceneKey) && hasTag(goods, "avoid_hotpot")) score -= 40;
        if ("salad".equals(sceneKey) && hasTag(goods, "avoid_salad")) score -= 36;
        if ("juice".equals(sceneKey) && hasTag(goods, "avoid_juice")) score -= 36;
        if ("combo".equals(sceneKey) && hasTag(goods, "avoid_combo")) score -= 30;
        return score;
    }

    private int scoreMealTagFit(Goods goods, String role, String dietGoal, String cookMode, boolean preferSatiety) {
        int score = 0;
        String text = (safe(goods == null ? null : goods.getName(), "") + "," + safe(goods == null ? null : goods.getKeywords(), "")).toLowerCase();
        if (hasTag(goods, "single_preferred")) score += 12;
        if (hasTag(goods, "family_preferred")) score -= 4;
        if (hasTag(goods, "quick_cook") && !"no_cook".equals(cookMode)) score += 8;
        if ("fruit".equals(role) && hasTag(goods, "nutrition_refreshing")) score += 10;
        if (("veg".equals(role) || "main".equals(role)) && hasTag(goods, "nutrition_satiety")) {
            score += preferSatiety ? ("light".equals(dietGoal) ? 8 : 24) : 10;
        }
        if (preferSatiety && ("veg".equals(role) || "main".equals(role)) && isMealSatietyProduce(text)) {
            score += "light".equals(dietGoal) ? 4 : 18;
        }
        if ("high_fiber".equals(dietGoal) && isMealHighFiberProduce(text)) score += 22;
        if ("light".equals(dietGoal) && isMealRefreshingProduce(text)) score += 22;
        if ("balanced".equals(dietGoal) && isMealHighFiberProduce(text)) score += 12;
        if ("balanced".equals(dietGoal) && isMealRefreshingProduce(text)) score += 12;
        if (isMealStrongFlavorProduce(text)) score -= 8;
        if ("light".equals(dietGoal) && isMealSatietyProduce(text)) score -= 12;
        if ("light".equals(dietGoal) && text.matches(".*(土豆|南瓜|玉米|红薯|芋头|山药).*")) score -= 12;
        if ("balanced".equals(dietGoal) && text.matches(".*(蒜苗|大葱|洋葱|苦瓜).*")) score -= 6;
        if (preferSatiety && text.matches(".*(菌|菇).*")) score -= 6;
        if ("high_fiber".equals(dietGoal) && hasTag(goods, "nutrition_satiety")) score += 6;
        if ("light".equals(dietGoal) && hasTag(goods, "nutrition_refreshing")) score += 12;
        if ("balanced".equals(dietGoal) && hasTag(goods, "nutrition_refreshing")) score += 6;
        return score;
    }

    private int scoreComboTagFit(Goods goods, String goalScene, String role, String peopleCount, boolean preferSatiety) {
        int score = 0;
        String text = (safe(goods == null ? null : goods.getName(), "") + "," + safe(goods == null ? null : goods.getKeywords(), "")).toLowerCase();
        int serving = resolveServingCount(peopleCount);

        if ("hotpot".equals(goalScene)) {
            if (hasTag(goods, "hotpot_core")) score += 28;
            if (hasTag(goods, "hotpot_leafy")) score += 14;
            if (hasTag(goods, "hotpot_mushroom")) score += 16;
            if (hasTag(goods, "hotpot_root")) score += 12;
            if (PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.hotpot_priority_keywords"))) score += 12;
            if (hasTag(goods, "avoid_hotpot")) score -= 45;
        }
        if ("salad".equals(goalScene)) {
            if (hasTag(goods, "salad_core")) score += 26;
            if (hasTag(goods, "salad_crisp")) score += 14;
            if (hasTag(goods, "no_cook")) score += 12;
            if (PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.salad_priority_keywords"))) score += 12;
            if (hasTag(goods, "avoid_salad")) score -= 40;
            if (text.matches(".*(即食|冷拌|脆|爽|沙拉).*")) score += 8;
            if (text.matches(".*(耐煮|久煮|火锅|炖煮).*")) score -= 12;
        }
        if ("juice".equals(goalScene)) {
            if (hasTag(goods, "juice_core")) score += 26;
            if (hasTag(goods, "juice_high_water")) score += 16;
            if (hasTag(goods, "nutrition_refreshing")) score += 10;
            if (PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.juice_priority_keywords"))) score += 12;
            if (hasTag(goods, "avoid_juice")) score -= 40;
        }
        if ("bento_side".equals(goalScene)) {
            if (hasTag(goods, "bento_core")) score += 24;
            if (hasTag(goods, "bento_stable")) score += 14;
            if (hasTag(goods, "quick_cook")) score += 10;
            if (PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.bento_priority_keywords"))) score += 12;
            if (hasTag(goods, "avoid_combo")) score -= 30;
            if (text.matches(".*(便当|耐放|分装|焯水|快手).*")) score += 8;
            if (text.matches(".*(鲜切即食|果切|榨汁|沙拉|多汁).*")) score -= 12;
        }

        if (serving <= 1) {
            if (hasTag(goods, "single_preferred")) score += 10;
            if (hasTag(goods, "family_preferred")) score -= 8;
        } else {
            if (hasTag(goods, "family_preferred")) score += 14;
            if (hasTag(goods, "single_preferred")) score -= 12;
        }

        if (preferSatiety && hasTag(goods, "nutrition_satiety")) score += 10;
        return score;
    }

    private String resolveReplacementRole(Goods originGoods, ReplacePlanItemRequest request, Map<Long, Category> categoryMap, String planType, String goalScene) {
        String explicitRole = safe(request == null ? null : request.getOriginRole(), "");
        String originRole = explicitRole.isEmpty() ? inferRoleByGoods(originGoods, categoryMap, planType) : explicitRole;
        if (!"combo".equals(planType)) {
            if ("veg".equals(originRole) || "fruit".equals(originRole) || "main".equals(originRole) || "side".equals(originRole)) {
                return originRole;
            }
            return inferRoleByGoods(originGoods, categoryMap, planType);
        }
        if ("base".equals(originRole)) {
            originRole = "veg";
        }
        if (shouldPreferVegOnlyCombo(goalScene)) {
            return "veg";
        }

        int vegCount = 0;
        int fruitCount = 0;
        List<ReplacePlanItemRequest.CurrentPlanItem> currentItems = request.getCurrentItems();
        if (currentItems != null) {
            for (ReplacePlanItemRequest.CurrentPlanItem item : currentItems) {
                if (item == null) continue;
                Long goodsId = item.getGoodsId();
                if (goodsId != null && request.getOriginGoodsId() != null && request.getOriginGoodsId().equals(goodsId)) {
                    continue;
                }
                String itemRole = normalizeComboRole(item.getRole());
                if ("fruit".equals(itemRole)) {
                    fruitCount += 1;
                } else {
                    vegCount += 1;
                }
            }
        }
        if (fruitCount <= 0) {
            return "fruit";
        }
        if (vegCount < 2) {
            return "veg";
        }
        return normalizeComboRole(originRole);
    }

    private String normalizeComboRole(String role) {
        String safeRole = safe(role, "");
        if ("fruit".equals(safeRole)) return "fruit";
        if ("base".equals(safeRole)) return "veg";
        return "veg";
    }

    private List<Goods> collectReplacementCandidates(List<Goods> pool, ReplacePlanItemRequest request, Map<Long, Category> categoryMap, String planType, String goalScene, String peopleCount, String role, Set<Long> currentGoodsIds, Goods originGoods, BigDecimal originPrice, WeightProfile profile, int itemIndex) {
        List<Goods> candidates = new ArrayList<>();
        Long avoidGoodsId = request.getOriginGoodsId();
        boolean firstSlot = itemIndex == 0;
        BigDecimal maxDelta = "combo".equals(planType)
                ? (firstSlot ? new BigDecimal("22.00") : new BigDecimal("15.00"))
                : (firstSlot ? new BigDecimal("15.00") : new BigDecimal("10.00"));

        for (Goods g : pool) {
            if (g == null || g.getId() == null) continue;
            if (g.getId().equals(originGoods.getId())) continue;
            if (avoidGoodsId != null && avoidGoodsId.equals(g.getId())) continue;
            if (currentGoodsIds.contains(g.getId())) continue;
            if ("combo".equals(planType) && isSeasoningLike(g)) continue;
            if (!replacementRoleMatched(g, role, categoryMap, planType, firstSlot)) continue;
            if ("combo".equals(planType) && containsHardConflictKeyword(g, goalScene)) continue;
            if (hasConflictWithSelectedIds(g, planType, goalScene, currentGoodsIds)) continue;

            GoodsSku sku = "combo".equals(planType)
                    ? selectPreferredComboSku(g.getId(), role, peopleCount, profile)
                    : selectPreferredSku(g.getId(), role, planType, profile);
            if (sku == null) continue;
            if (request.getOriginSkuId() != null && request.getOriginSkuId().equals(sku.getId())) continue;

            BigDecimal candidatePrice = safePrice(sku.getSkuPrice(), safePrice(g.getPrice(), BigDecimal.ZERO));
            if (candidatePrice.subtract(originPrice).abs().compareTo(maxDelta) > 0) continue;

            if ("combo".equals(planType) && !isStrongBudgetComboCandidate(g, goalScene, role, peopleCount, categoryMap, profile)) continue;
            candidates.add(g);
        }

        if ("combo".equals(planType)) {
            candidates.sort((a, b) -> Integer.compare(
                    scoreComboGoods(b, goalScene, role, peopleCount, "fresh", categoryMap, profile, firstSlot),
                    scoreComboGoods(a, goalScene, role, peopleCount, "fresh", categoryMap, profile, firstSlot)
            ));
        } else {
            BudgetRange budget = resolveBudgetRange("standard", "meal");
            candidates.sort((a, b) -> Integer.compare(
                    scoreMealGoods(b, role, budget, "balanced", "quick_cook", categoryMap, profile, firstSlot),
                    scoreMealGoods(a, role, budget, "balanced", "quick_cook", categoryMap, profile, firstSlot)
            ));
        }

        if (candidates.size() > 10) {
            return new ArrayList<>(candidates.subList(0, 10));
        }
        return candidates;
    }

    private boolean replacementRoleMatched(Goods goods, String role, Map<Long, Category> categoryMap, String planType, boolean firstSlot) {
        if (roleMatched(goods, role, categoryMap, planType)) {
            return true;
        }
        if (!firstSlot) {
            return false;
        }
        if ("combo".equals(planType) && "veg".equals(role)) {
            return roleMatched(goods, "base", categoryMap, planType);
        }
        if ("meal".equals(planType) && "veg".equals(role)) {
            return roleMatched(goods, "main", categoryMap, planType);
        }
        return false;
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
        GoodsSku sku = selectPreferredComboSku(goods.getId(), role, peopleCount, resolveWeightProfile("combo"));
        if (sku == null || sku.getSkuWeightG() == null) return 0;
        int weight = sku.getSkuWeightG();
        int serving = resolveServingCount(peopleCount);
        if (serving <= 1) {
            if (weight <= 320) return 8;
            if (weight >= 500) return -8;
            return 0;
        }
        if (serving == 2) {
            if (weight >= 320 && weight <= 620) return 14;
            if (weight < 260) return -14;
            return -2;
        }
        if (weight >= 480) return 18;
        if (weight < 360) return -18;
        return -4;
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
            if (PlanRuleHelper.isSimilarProduceFamily(candidateText, existedText)) sameRootCount += 1;
            if (safe(item.getRole(), "").equals(inferTextRole(candidateText, type))) sameRoleCount += 1;
            if ("fruit".equals(item.getRole())) fruitCount += 1;
            if (isStrongFlavorProduce(existedText)) strongFlavorCount += 1;
            if (isStarchyProduce(existedText)) starchyCount += 1;
            if (hasDirectConflict(candidateText, existedText, goal)) return true;
        }
        if (sameRootCount >= 1) return true;
        if ("combo".equals(type) && sameRoleCount >= 2 && !("hotpot".equals(goal) && "veg".equals(inferTextRole(candidateText, type)))) return true;
        if ("meal".equals(type) && "fruit".equals(inferTextRole(candidateText, type)) && fruitCount >= 1) return true;
        if (("salad".equals(goal) || "juice".equals(goal)) && strongFlavorCount >= 2) return true;
        if ("juice".equals(goal) && starchyCount >= 2) return true;
        return false;
    }

    private boolean hasDirectConflict(String a, String b, String goal) {
        if (PlanRuleHelper.hasConfiguredConflict(a, b, readRuleList("plan.general_conflict_pairs"))) {
            return true;
        }
        if ("meal".equals(goal) && PlanRuleHelper.hasConfiguredConflict(a, b, readRuleList("plan.meal_conflict_pairs"))) {
            return true;
        }
        if ("juice".equals(goal) && PlanRuleHelper.hasConfiguredConflict(a, b, readRuleList("plan.juice_conflict_pairs"))) {
            return true;
        }
        if ("salad".equals(goal) && PlanRuleHelper.hasConfiguredConflict(a, b, readRuleList("plan.salad_conflict_pairs"))) {
            return true;
        }
        if ("hotpot".equals(goal) && PlanRuleHelper.hasConfiguredConflict(a, b, readRuleList("plan.hotpot_conflict_pairs"))) {
            return true;
        }
        if ("bento_side".equals(goal) && PlanRuleHelper.hasConfiguredConflict(a, b, readRuleList("plan.bento_conflict_pairs"))) {
            return true;
        }
        if ("hotpot".equals(goal) && ((a.contains("西瓜") && b.contains("火锅")) || (b.contains("西瓜") && a.contains("火锅")))) {
            return true;
        }
        return false;
    }

    private boolean hasConflictWithGoods(Goods candidate, String planType, String goal, Long... selectedGoodsIds) {
        if (candidate == null || candidate.getId() == null || selectedGoodsIds == null || selectedGoodsIds.length == 0) {
            return false;
        }
        String candidateText = (safe(candidate.getName(), "") + "," + safe(candidate.getKeywords(), "")).toLowerCase();
        for (Long goodsId : selectedGoodsIds) {
            if (goodsId == null || goodsId <= 0) continue;
            Goods selected = goodsMapper.selectById(goodsId);
            if (selected == null || selected.getId() == null || selected.getId().equals(candidate.getId())) continue;
            String selectedText = (safe(selected.getName(), "") + "," + safe(selected.getKeywords(), "")).toLowerCase();
            if (hasDirectConflict(candidateText, selectedText, "combo".equals(planType) ? goal : "meal")) {
                return true;
            }
        }
        return false;
    }

    private boolean hasConflictWithSelectedIds(Goods candidate, String planType, String goal, Set<Long> selectedGoodsIds) {
        if (candidate == null || candidate.getId() == null || selectedGoodsIds == null || selectedGoodsIds.isEmpty()) {
            return false;
        }
        String candidateText = (safe(candidate.getName(), "") + "," + safe(candidate.getKeywords(), "")).toLowerCase();
        String resolvedGoal = "combo".equals(planType) ? goal : "meal";
        for (Long goodsId : selectedGoodsIds) {
            if (goodsId == null || goodsId <= 0 || goodsId.equals(candidate.getId())) continue;
            Goods selected = goodsMapper.selectById(goodsId);
            if (selected == null) continue;
            String selectedText = (safe(selected.getName(), "") + "," + safe(selected.getKeywords(), "")).toLowerCase();
            if (hasDirectConflict(candidateText, selectedText, resolvedGoal)) {
                return true;
            }
        }
        return false;
    }

    private String inferTextRole(String text, String planType) {
        String safeText = safe(text, "").toLowerCase();
        if (PlanRoleHelper.isFruitLike(safeText)) return "fruit";
        if ("combo".equals(planType)) {
            return PlanRoleHelper.isComboBaseLike(safeText) ? "base" : "veg";
        }
        return PlanRoleHelper.isMealVegLike(safeText) ? "veg" : (PlanRoleHelper.isMealMainLike(safeText) ? "main" : "side");
    }

    private boolean isStrongFlavorProduce(String text) {
        return isMealStrongFlavorProduce(text);
    }

    private boolean isMealStrongFlavorProduce(String text) {
        return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.meal_strong_flavor_keywords"));
    }

    private boolean isMealSatietyProduce(String text) {
        return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.meal_satiety_keywords"));
    }

    private boolean isMealHighFiberProduce(String text) {
        return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.meal_high_fiber_keywords"));
    }

    private boolean isMealRefreshingProduce(String text) {
        return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.meal_refreshing_keywords"));
    }

    private boolean isStarchyProduce(String text) {
        return isMealSatietyProduce(text);
    }

    private boolean isWateryFruitProduce(String text) {
        return PlanRuleHelper.containsAnyKeyword(text, readRuleList("plan.watery_fruit_keywords"));
    }

    private boolean shouldPreferVegOnlyCombo(String goalScene) {
        return "hotpot".equals(goalScene);
    }

    private boolean isSeasoningLike(Goods goods) {
        if (goods == null) return false;
        if (hasTag(goods, "seasoning")) return true;
        String text = safe(goods.getName(), "") + "," + safe(goods.getKeywords(), "");
        return isSeasoningLike(text);
    }

    private boolean isSeasoningLike(String text) {
        String safeText = safe(text, "").toLowerCase();
        return safeText.matches(".*(香茅|柠檬草|南姜|子姜|生姜|独头蒜|蒜|蒜苗|蒜苔|香葱|大葱|小米椒|湖南椒|螺丝椒|朝天椒|调味).*");
    }

    private String typeSafeRole(String role) {
        return safe(role, "");
    }

    private List<String> readRuleList(String ruleKey) {
        Map<String, String> config = loadPlanRuleConfig();
        String raw = config.getOrDefault(ruleKey, DEFAULT_PLAN_RULES.getOrDefault(ruleKey, ""));
        if ((raw == null || raw.trim().isEmpty()) && "plan.meal_satiety_keywords".equals(ruleKey)) {
            raw = config.getOrDefault("plan.starchy_keywords", DEFAULT_PLAN_RULES.getOrDefault("plan.meal_satiety_keywords", ""));
        }
        if ((raw == null || raw.trim().isEmpty()) && "plan.meal_strong_flavor_keywords".equals(ruleKey)) {
            raw = config.getOrDefault("plan.strong_flavor_keywords", DEFAULT_PLAN_RULES.getOrDefault("plan.meal_strong_flavor_keywords", ""));
        }
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
        Map<String, String> cached = planRuleConfigThreadCache.get();
        if (cached != null && !cached.isEmpty()) {
            return cached;
        }
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
        if (cached != null) {
            planRuleConfigThreadCache.set(config);
        }
        return config;
    }

    private void beginPlanRuleContext() {
        planRuleConfigThreadCache.set(new HashMap<>());
    }

    private void endPlanRuleContext() {
        planRuleConfigThreadCache.remove();
    }

    private Map<String, String> loadPackPricingRules() {
        Map<String, String> config = new HashMap<>(DEFAULT_PACK_PRICING_RULES);
        try {
            List<Map<String, Object>> rows = seasonalConfigMapper.selectAll();
            if (rows != null) {
                for (Map<String, Object> row : rows) {
                    String key = row.get("configKey") == null ? "" : String.valueOf(row.get("configKey")).trim();
                    if (!key.startsWith("pack.")) continue;
                    if (key.isEmpty()) continue;
                    String value = row.get("configValue") == null ? "" : String.valueOf(row.get("configValue")).trim();
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

    private boolean isStrictMealComposition(List<PlanItem> items) {
        if (items == null || items.size() != 3) return false;
        int fruitCount = 0;
        int vegCount = 0;
        for (PlanItem item : items) {
            if (item == null) return false;
            String actualRole = safe(item.getRole(), "");
            if ("fruit".equals(actualRole)) {
                fruitCount += 1;
                continue;
            }
            if ("veg".equals(actualRole) || "main".equals(actualRole) || "side".equals(actualRole)) {
                vegCount += 1;
                continue;
            }
            return false;
        }
        return vegCount >= 2 && fruitCount == 1;
    }

    private PlanItem buildPlanItem(Goods goods, String role, String reason) {
        String planType = ("base".equals(role) || "veg".equals(role)) ? "combo" : "meal";
        return buildPlanItem(goods, role, reason, planType);
    }

    private PlanItem buildPlanItem(Goods goods, String role, String reason, String planType) {
        return buildPlanItem(goods, role, reason, planType, null);
    }

    private PlanItem buildPlanItem(Goods goods, String role, String reason, String planType, String peopleCount) {
        GoodsSku sku = "combo".equals(planType)
                ? selectPreferredComboSku(goods.getId(), role, peopleCount, resolveWeightProfile(planType))
                : selectPreferredSku(goods.getId(), role, planType, resolveWeightProfile(planType));
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

    private GoodsSku selectPreferredComboSku(Long goodsId, String role, String peopleCount, WeightProfile profile) {
        if (goodsId == null) return null;
        List<GoodsSku> skus = goodsSkuMapper.selectListByGoodsId(goodsId);
        GoodsSku best = null;
        int bestScore = Integer.MIN_VALUE;
        int serving = resolveServingCount(peopleCount);
        for (GoodsSku sku : skus) {
            if (sku == null) continue;
            if (sku.getStatus() == null || sku.getStatus() != 1) continue;
            if (sku.getSkuStock() == null || sku.getSkuStock() <= 0) continue;
            int score = scoreSkuByScene(sku, role, "combo", profile);
            score += PlanScoringHelper.scorePeopleCountFit(sku, serving);
            score += scoreComboSkuServingPreference(sku, serving);
            if (best == null || score > bestScore) {
                best = sku;
                bestScore = score;
            }
        }
        return best;
    }

    private int scoreComboSkuServingPreference(GoodsSku sku, int serving) {
        if (sku == null) return 0;
        String specType = safe(sku.getSpecType(), "").toLowerCase();
        String specValue = safe(sku.getSpecValue(), "").toLowerCase();
        String skuName = safe(sku.getSkuName(), "").toLowerCase();
        String text = specType + "," + specValue + "," + skuName;
        int weight = sku.getSkuWeightG() == null ? 500 : sku.getSkuWeightG();

        if (serving >= 3) {
            if ("family".equals(specType) || text.contains("家庭")) return 36;
            if ("standard".equals(specType) || text.contains("标准")) return 24;
            if ("single".equals(specType) || text.contains("小份")) return -38;
            if (weight >= 480) return 20;
            if (weight < 360) return -26;
            return -6;
        }
        if (serving == 2) {
            if ("family".equals(specType) || text.contains("家庭")) return 16;
            if ("standard".equals(specType) || text.contains("标准")) return 10;
            if ("single".equals(specType) || text.contains("小份")) return -12;
            if (weight >= 360 && weight <= 560) return 10;
            if (weight < 260) return -10;
            return 0;
        }
        if ("single".equals(specType) || text.contains("小份")) return 10;
        if (weight > 520) return -8;
        return 0;
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
        BigDecimal originalTotal = safeTotal;
        BigDecimal packDiscount = calcPackDiscount(safeTotal, planType);
        BigDecimal finalPrice = safeTotal.subtract(packDiscount).max(BigDecimal.ZERO).setScale(2, RoundingMode.HALF_UP);
        BigDecimal savedAmount = packDiscount.max(BigDecimal.ZERO).setScale(2, RoundingMode.HALF_UP);
        BigDecimal couponThreshold = "combo".equals(planType) ? new BigDecimal("59.00") : new BigDecimal("39.00");

        row.put("totalPrice", finalPrice);
        row.put("originalTotalPrice", originalTotal);
        row.put("savedAmount", savedAmount);
        row.put("packagePrice", finalPrice);
        row.put("baseTotalPrice", safeTotal);
        row.put("packDiscount", packDiscount);
        row.put("couponHint", buildCouponHint(finalPrice, savedAmount, couponThreshold));
        return row;
    }

    private BigDecimal calcPackDiscount(BigDecimal totalPrice, String planType) {
        return PlanPricingHelper.calcPackDiscount(totalPrice, planType, loadPackPricingRules());
    }

    private String buildCouponHint(BigDecimal totalPrice, BigDecimal savedAmount, BigDecimal threshold) {
        return PlanPricingHelper.buildCouponHint(totalPrice, savedAmount, threshold);
    }

    private BigDecimal resolveOriginalPrice(Goods goods, BigDecimal price, String planType) {
        return PlanPricingHelper.resolveOriginalPrice(goods, price, planType);
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
        return meal + "·" + goal + "·" + budget + "小份优选";
    }

    private String buildComboName(String goalScene) {
        if ("juice".equals(goalScene)) return "果蔬榨汁搭配";
        if ("hotpot".equals(goalScene)) return "火锅配菜搭配";
        if ("bento_side".equals(goalScene)) return "便当配菜搭配";
        return "清爽沙拉搭配";
    }

    private String buildPrepHint(String goalScene) {
        if ("juice".equals(goalScene)) return "建议按蔬菜:水果=2:1榨汁，口感更平衡。";
        if ("hotpot".equals(goalScene)) return "优先选择耐煮、好配锅的蔬菜，叶菜与根茎类可分批下锅。";
        if ("bento_side".equals(goalScene)) return "焯水后分装，冷藏 48 小时内食用最佳。";
        return "洗净后按喜好搭配沙拉酱或油醋汁即可。";
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
        return PlanRoleHelper.inferRoleByGoods(goods, categoryMap, planType, getTagCodes(goods));
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
        return "combo".equalsIgnoreCase(safe(planType, "")) ? "场景搭配" : "小份优选";
    }

    private void saveCart(CartInfo cartInfo) {
        try {
            cartMapper.insertCart(cartInfo);
        } catch (Exception ignored) {
            cartMapper.insertCartBasic(cartInfo);
        }
    }

    private void updateCart(CartInfo cartInfo) {
        try {
            cartMapper.updateCart(cartInfo);
        } catch (Exception ignored) {
            cartMapper.updateCartBasic(cartInfo);
        }
    }

    private String buildReplacementReason(String role, String planType) {
        String roleText = translateRole(role, planType);
        if ("fruit".equals(role)) return "换成了另一款更适合当前组合的水果";
        if ("combo".equals(planType)) {
            return "换成了更适合这组搭配的" + roleText;
        }
        return "换成了更适合这份套餐的" + roleText;
    }

    private String translateRole(String role, String planType) {
        if ("fruit".equals(role)) return "水果";
        if ("main".equals(role)) return "主食材";
        if ("side".equals(role)) return "搭配食材";
        if ("veg".equals(role)) return "蔬菜";
        if ("base".equals(role)) return "基础食材";
        if ("veg".equals(role)) return "蔬菜";
        return "食材";
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
        Set<String> codes = getTagCodes(goods);
        return codes != null && codes.contains(tagCode);
    }

    private Set<String> getTagCodes(Goods goods) {
        if (goods == null || goods.getId() == null) {
            return Collections.emptySet();
        }
        Set<String> codes = goodsTagCodeMapCache.get(goods.getId());
        return codes == null ? Collections.emptySet() : codes;
    }

    private boolean isExcludedFromPlan(Goods goods) {
        if (goods == null || goods.getId() == null) return false;
        List<String> excludeTags = readRuleList("plan.global_exclude_tags");
        if (excludeTags.isEmpty()) {
            return hasTag(goods, "exclude_plan");
        }
        for (String tagCode : excludeTags) {
            if (tagCode != null && !tagCode.trim().isEmpty() && hasTag(goods, tagCode.trim())) {
                return true;
            }
        }
        return false;
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
