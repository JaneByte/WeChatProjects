package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.UpdateSeasonalConfigRequest;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.GoodsSkuMapper;
import com.example.freshtime.mapper.GoodsTagMapper;
import com.example.freshtime.mapper.SeasonalConfigMapper;
import com.example.freshtime.service.SeasonalService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.YearMonth;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.HashSet;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class SeasonalServiceImpl implements SeasonalService {

    private static final Map<String, String> DEFAULT_CONFIG = buildDefaultConfig();

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private GoodsSkuMapper goodsSkuMapper;

    @Autowired
    private SeasonalConfigMapper seasonalConfigMapper;

    @Autowired
    private GoodsTagMapper goodsTagMapper;

    @Override
    public ApiResponse<?> list(Integer limit, String season, String region, String budgetLevel, String sortBy, String produceType, Boolean strictTag) {
        int finalLimit = normalizeLimit(limit);
        String finalSeason = normalizeSeason(season);
        String finalRegion = normalizeRegion(region);
        String finalBudgetLevel = normalizeBudgetLevel(budgetLevel);
        String finalSortBy = normalizeSortBy(sortBy);
        String finalProduceType = normalizeProduceType(produceType);
        boolean finalStrictTag = normalizeStrictTag(strictTag);
        Map<String, String> config = loadRuntimeConfig();

        List<Goods> goodsList = goodsMapper.selectOnSaleWithStockLimit(200);
        List<Map<String, Object>> ranked = rankGoods(
                goodsList, finalSeason, finalRegion, finalBudgetLevel, finalSortBy, finalProduceType, finalStrictTag, finalLimit, config
        );
        Map<String, Object> data = buildPayload(
                finalSeason, finalRegion, finalBudgetLevel, finalSortBy, finalProduceType, finalStrictTag, finalLimit, ranked, goodsList, config
        );
        return ApiResponse.success(data);
    }

    @Override
    public ApiResponse<?> refresh(Integer limit, String season, String region, String budgetLevel, String sortBy, String produceType, Boolean strictTag) {
        return list(limit, season, region, budgetLevel, sortBy, produceType, strictTag);
    }

    @Override
    public ApiResponse<?> getConfig() {
        return ApiResponse.success(loadRuntimeConfig());
    }

    @Override
    public ApiResponse<?> updateConfig(UpdateSeasonalConfigRequest request) {
        if (request == null || request.getConfig() == null || request.getConfig().isEmpty()) {
            return ApiResponse.badRequest("config不能为空");
        }
        Map<String, String> incoming = request.getConfig();
        for (Map.Entry<String, String> entry : incoming.entrySet()) {
            String key = entry.getKey() == null ? "" : entry.getKey().trim();
            if (key.isEmpty()) continue;
            String value = entry.getValue() == null ? "" : entry.getValue().trim();
            seasonalConfigMapper.upsert(key, value);
        }
        return ApiResponse.success("更新成功", loadRuntimeConfig());
    }

    private Map<String, String> loadRuntimeConfig() {
        Map<String, String> config = new HashMap<>(DEFAULT_CONFIG);
        try {
            List<Map<String, Object>> rows = seasonalConfigMapper.selectAll();
            if (rows != null) {
                for (Map<String, Object> row : rows) {
                    String key = row.get("configKey") == null ? "" : String.valueOf(row.get("configKey")).trim();
                    if (key.isEmpty()) continue;
                    String value = row.get("configValue") == null ? "" : String.valueOf(row.get("configValue")).trim();
                    config.put(key, value);
                }
            }
        } catch (Exception ignored) {
            // 配置表不存在或读取失败时自动回退到默认配置
        }
        return config;
    }

    private static Map<String, String> buildDefaultConfig() {
        Map<String, String> cfg = new HashMap<>();
        cfg.put("weight.season", "0.26");
        cfg.put("weight.freshness", "0.18");
        cfg.put("weight.sales", "0.18");
        cfg.put("weight.margin", "0.14");
        cfg.put("weight.stock", "0.14");
        cfg.put("weight.budget", "0.10");
        cfg.put("title.template", "{seasonText}当季精选");
        cfg.put("subtitle.template", "优先新鲜度、当季适配和库存稳定性");
        return cfg;
    }

    private int normalizeLimit(Integer limit) {
        int n = limit == null ? 12 : limit;
        if (n < 4) return 4;
        return Math.min(n, 30);
    }

    private String normalizeSeason(String season) {
        if (season == null || season.trim().isEmpty()) return detectCurrentSeason();
        String s = season.trim().toLowerCase(Locale.ROOT);
        if ("spring".equals(s) || "summer".equals(s) || "autumn".equals(s) || "winter".equals(s)) return s;
        if ("春".equals(s) || "春季".equals(s)) return "spring";
        if ("夏".equals(s) || "夏季".equals(s)) return "summer";
        if ("秋".equals(s) || "秋季".equals(s)) return "autumn";
        if ("冬".equals(s) || "冬季".equals(s)) return "winter";
        return detectCurrentSeason();
    }

    private String detectCurrentSeason() {
        int month = LocalDate.now().getMonthValue();
        if (month >= 3 && month <= 5) return "spring";
        if (month >= 6 && month <= 8) return "summer";
        if (month >= 9 && month <= 11) return "autumn";
        return "winter";
    }

    private String normalizeRegion(String region) {
        if (region == null || region.trim().isEmpty()) return "all";
        return region.trim();
    }

    private String normalizeBudgetLevel(String budgetLevel) {
        String val = budgetLevel == null ? "" : budgetLevel.trim().toLowerCase(Locale.ROOT);
        if ("economy".equals(val) || "standard".equals(val) || "plus".equals(val)) return val;
        return "all";
    }

    private String normalizeSortBy(String sortBy) {
        String val = sortBy == null ? "" : sortBy.trim().toLowerCase(Locale.ROOT);
        if ("score".equals(val) || "price_asc".equals(val) || "price_desc".equals(val) || "sales_desc".equals(val)) return val;
        return "score";
    }

    private String normalizeProduceType(String produceType) {
        String val = produceType == null ? "" : produceType.trim().toLowerCase(Locale.ROOT);
        if ("fruits".equals(val) || "vegetables".equals(val)) return val;
        return "all";
    }

    private boolean normalizeStrictTag(Boolean strictTag) {
        return strictTag == null || strictTag;
    }

    private List<Map<String, Object>> rankGoods(
            List<Goods> goodsList,
            String season,
            String region,
            String budgetLevel,
            String sortBy,
            String produceType,
            boolean strictTag,
            int limit,
            Map<String, String> config
    ) {
        if (goodsList == null || goodsList.isEmpty()) return new ArrayList<>();
        Map<Long, Set<String>> goodsTagCodeMap = loadGoodsTagCodeMap(goodsList);
        List<Goods> filtered = goodsList.stream()
                .filter(it -> matchRegion(it, region))
                .filter(it -> matchBudget(it, budgetLevel))
                .filter(it -> matchProduceType(it, produceType, goodsTagCodeMap.getOrDefault(it.getId(), new HashSet<>()), strictTag))
                .filter(it -> matchSeasonWindow(it, season))
                .collect(Collectors.toList());
        boolean fallbackUsed = filtered.isEmpty() && !goodsList.isEmpty();
        List<Goods> source = fallbackUsed ? goodsList : filtered;

        List<ScoredGoods> scored = new ArrayList<>();
        int maxSales = source.stream().map(Goods::getSalesVolume).filter(v -> v != null && v > 0).max(Integer::compareTo).orElse(1);
        int maxStock = source.stream().map(Goods::getStock).filter(v -> v != null && v > 0).max(Integer::compareTo).orElse(1);

        for (Goods goods : source) {
            if (goods == null || goods.getId() == null) continue;
            Set<String> tagCodes = goodsTagCodeMap.getOrDefault(goods.getId(), new HashSet<>());
            ScoreBreakdown breakdown = computeScore(goods, season, maxSales, maxStock, budgetLevel, config, tagCodes, strictTag);
            scored.add(new ScoredGoods(goods, breakdown));
        }
        sortScoredGoods(scored, sortBy);
        List<Map<String, Object>> result = scored.stream().limit(limit).map(it -> toItem(it, config)).collect(Collectors.toList());
        if (fallbackUsed) {
            for (Map<String, Object> item : result) {
                item.put("fallbackUsed", true);
            }
        }
        return result;
    }

    private boolean matchProduceType(Goods goods, String produceType, Set<String> tagCodes, boolean strictTag) {
        if ("all".equals(produceType)) return true;
        if (tagCodes == null || tagCodes.isEmpty()) return false;
        if ("fruits".equals(produceType)) return tagCodes.contains("produce:fruits");
        if ("vegetables".equals(produceType)) return tagCodes.contains("produce:vegetables");
        if (!strictTag) return true;
        return false;
    }

    private ScoreBreakdown computeScore(
            Goods goods,
            String season,
            int maxSales,
            int maxStock,
            String budgetLevel,
            Map<String, String> config,
            Set<String> tagCodes,
            boolean strictTag
    ) {
        double seasonScore = calcSeasonScore(goods, season, tagCodes, strictTag);
        double freshnessScore = calcFreshnessScore(goods);
        double salesScore = normalize(goods.getSalesVolume(), maxSales) * 100;
        double stockScore = normalize(goods.getStock(), maxStock) * 100;
        double marginScore = calcMarginScore(goods);
        double budgetScore = calcBudgetScore(goods, budgetLevel);

        double weightSeason = readWeight(config, "weight.season", 0.26);
        double weightFreshness = readWeight(config, "weight.freshness", 0.18);
        double weightSales = readWeight(config, "weight.sales", 0.18);
        double weightMargin = readWeight(config, "weight.margin", 0.14);
        double weightStock = readWeight(config, "weight.stock", 0.14);
        double weightBudget = readWeight(config, "weight.budget", 0.10);
        double weightSum = weightSeason + weightFreshness + weightSales + weightMargin + weightStock + weightBudget;
        if (weightSum <= 0) weightSum = 1;

        double total = (
                seasonScore * weightSeason
                        + freshnessScore * weightFreshness
                        + salesScore * weightSales
                        + marginScore * weightMargin
                        + stockScore * weightStock
                        + budgetScore * weightBudget
        ) / weightSum;

        return new ScoreBreakdown(
                round2(total),
                round2(seasonScore),
                round2(freshnessScore),
                round2(salesScore),
                round2(marginScore),
                round2(stockScore)
        );
    }

    private double readWeight(Map<String, String> config, String key, double fallback) {
        try {
            String val = config.get(key);
            if (val == null || val.trim().isEmpty()) return fallback;
            double v = Double.parseDouble(val.trim());
            if (v < 0) return fallback;
            return v;
        } catch (Exception ignored) {
            return fallback;
        }
    }

    private void sortScoredGoods(List<ScoredGoods> scored, String sortBy) {
        if ("price_asc".equals(sortBy)) {
            scored.sort(Comparator.comparing(it -> it.goods.getPrice() == null ? BigDecimal.ZERO : it.goods.getPrice()));
            return;
        }
        if ("price_desc".equals(sortBy)) {
            scored.sort((a, b) -> {
                BigDecimal pa = a.goods.getPrice() == null ? BigDecimal.ZERO : a.goods.getPrice();
                BigDecimal pb = b.goods.getPrice() == null ? BigDecimal.ZERO : b.goods.getPrice();
                return pb.compareTo(pa);
            });
            return;
        }
        if ("sales_desc".equals(sortBy)) {
            scored.sort(Comparator.comparingInt((ScoredGoods it) -> it.goods.getSalesVolume() == null ? 0 : it.goods.getSalesVolume()).reversed());
            return;
        }
        scored.sort(Comparator.comparingDouble((ScoredGoods it) -> it.breakdown.totalScore).reversed());
    }

    private boolean matchRegion(Goods goods, String region) {
        if ("all".equals(region)) return true;
        String origin = goods.getOrigin() == null ? "" : goods.getOrigin().toLowerCase(Locale.ROOT);
        return origin.contains(region.toLowerCase(Locale.ROOT));
    }

    private boolean matchBudget(Goods goods, String budgetLevel) {
        if ("all".equals(budgetLevel)) return true;
        BigDecimal price = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
        if ("economy".equals(budgetLevel)) return price.compareTo(BigDecimal.valueOf(10)) <= 0;
        if ("standard".equals(budgetLevel)) return price.compareTo(BigDecimal.valueOf(10)) > 0 && price.compareTo(BigDecimal.valueOf(20)) <= 0;
        return price.compareTo(BigDecimal.valueOf(20)) > 0;
    }

    private double calcBudgetScore(Goods goods, String budgetLevel) {
        if ("all".equals(budgetLevel)) return 70;
        BigDecimal price = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
        if ("economy".equals(budgetLevel)) {
            if (price.compareTo(BigDecimal.valueOf(8)) <= 0) return 100;
            if (price.compareTo(BigDecimal.valueOf(10)) <= 0) return 85;
            return 40;
        }
        if ("standard".equals(budgetLevel)) {
            if (price.compareTo(BigDecimal.valueOf(12)) >= 0 && price.compareTo(BigDecimal.valueOf(18)) <= 0) return 100;
            if (price.compareTo(BigDecimal.valueOf(20)) <= 0) return 80;
            return 50;
        }
        if (price.compareTo(BigDecimal.valueOf(20)) >= 0) return 100;
        if (price.compareTo(BigDecimal.valueOf(16)) >= 0) return 80;
        return 45;
    }

    private double calcSeasonScore(Goods goods, String season, Set<String> tagCodes, boolean strictTag) {
        if (hasSeasonWindowConfig(goods)) {
            if (matchSeasonWindow(goods, season)) {
                return calcSeasonWindowScore(goods);
            }
            return strictTag ? 38 : 50;
        }
        if (tagCodes == null || tagCodes.isEmpty()) return strictTag ? 45 : 58;
        String seasonCode = "season:" + season;
        if (tagCodes.contains(seasonCode)) return calcSeasonStageScore(season);
        boolean hasOtherSeasonTag = tagCodes.contains("season:spring")
                || tagCodes.contains("season:summer")
                || tagCodes.contains("season:autumn")
                || tagCodes.contains("season:winter");
        if (hasOtherSeasonTag) return strictTag ? 68 : 75;
        return strictTag ? 45 : 58;
    }

    private boolean hasSeasonWindowConfig(Goods goods) {
        if (goods == null) return false;
        return goods.getSeasonStartMonth() != null && goods.getSeasonEndMonth() != null;
    }

    private boolean matchSeasonWindow(Goods goods, String season) {
        if (goods == null) return false;
        if (!hasSeasonWindowConfig(goods)) return true;
        int currentMonth = LocalDate.now().getMonthValue();
        Integer startMonth = goods.getSeasonStartMonth();
        Integer endMonth = goods.getSeasonEndMonth();
        if (startMonth == null || endMonth == null) return true;
        if (startMonth <= endMonth) {
          return currentMonth >= startMonth && currentMonth <= endMonth;
        }
        return currentMonth >= startMonth || currentMonth <= endMonth;
    }

    private double calcSeasonWindowScore(Goods goods) {
        String stage = detectGoodsSeasonStage(goods);
        if ("late".equals(stage)) return 91;
        if ("early".equals(stage)) return 96;
        return 100;
    }

    private double calcSeasonStageScore(String season) {
        String stage = detectSeasonStage(season);
        if ("late".equals(stage)) return 92;
        if ("early".equals(stage)) return 95;
        return 100;
    }

    private Map<Long, Set<String>> loadGoodsTagCodeMap(List<Goods> goodsList) {
        Map<Long, Set<String>> map = new HashMap<>();
        if (goodsList == null || goodsList.isEmpty()) return map;
        List<Long> goodsIds = goodsList.stream()
                .filter(it -> it != null && it.getId() != null)
                .map(Goods::getId)
                .collect(Collectors.toList());
        if (goodsIds.isEmpty()) return map;
        try {
            List<Map<String, Object>> rows = goodsTagMapper.selectTagCodesByGoodsIds(goodsIds);
            if (rows == null) return map;
            for (Map<String, Object> row : rows) {
                if (row == null) continue;
                Object goodsIdVal = row.get("goodsId");
                Object tagCodeVal = row.get("tagCode");
                if (goodsIdVal == null || tagCodeVal == null) continue;
                Long goodsId;
                try {
                    goodsId = Long.valueOf(String.valueOf(goodsIdVal));
                } catch (Exception ignored) {
                    continue;
                }
                String tagCode = String.valueOf(tagCodeVal).trim().toLowerCase(Locale.ROOT);
                if (tagCode.isEmpty()) continue;
                map.computeIfAbsent(goodsId, k -> new HashSet<>()).add(tagCode);
            }
        } catch (Exception ignored) {
            return map;
        }
        return map;
    }

    private double calcFreshnessScore(Goods goods) {
        int recommendBoost = goods.getIsRecommend() != null && goods.getIsRecommend() == 1 ? 18 : 0;
        int stock = goods.getStock() == null ? 0 : goods.getStock();
        int stockPart = stock >= 200 ? 35 : (stock >= 80 ? 26 : (stock >= 20 ? 18 : 10));
        int flashPenalty = goods.getIsFlash() != null && goods.getIsFlash() == 1 ? -5 : 0;
        return clamp(45 + recommendBoost + stockPart + flashPenalty);
    }

    private double calcMarginScore(Goods goods) {
        BigDecimal p = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
        BigDecimal op = goods.getOriginalPrice() == null ? BigDecimal.ZERO : goods.getOriginalPrice();
        if (op.compareTo(BigDecimal.ZERO) <= 0 || p.compareTo(BigDecimal.ZERO) <= 0) return 65;
        BigDecimal ratio = op.subtract(p).multiply(BigDecimal.valueOf(100)).divide(op, 2, RoundingMode.HALF_UP);
        return clamp(55 + ratio.doubleValue());
    }

    private double normalize(Integer value, int maxValue) {
        if (value == null || value <= 0 || maxValue <= 0) return 0;
        return Math.min(1d, value.doubleValue() / (double) maxValue);
    }

    private double round2(double value) {
        return BigDecimal.valueOf(value).setScale(2, RoundingMode.HALF_UP).doubleValue();
    }

    private double clamp(double value) {
        if (value < 0) return 0;
        return Math.min(value, 100);
    }

    private Map<String, Object> toItem(ScoredGoods it, Map<String, String> config) {
        Goods g = it.goods;
        GoodsSku defaultSku = resolveDefaultSku(g == null ? null : g.getId());
        Map<String, Object> item = new HashMap<>();
        String seasonCode = detectSeasonByMonth(LocalDate.now().getMonthValue());
        String seasonStage = hasSeasonWindowConfig(g) ? detectGoodsSeasonStage(g) : detectSeasonStage(seasonCode);
        item.put("id", g.getId());
        item.put("name", g.getName());
        item.put("mainImage", g.getMainImage());
        item.put("price", g.getPrice());
        item.put("originalPrice", g.getOriginalPrice());
        item.put("stock", g.getStock());
        item.put("unit", g.getUnit());
        item.put("salesVolume", g.getSalesVolume());
        item.put("origin", g.getOrigin());
        item.put("keywords", g.getKeywords());
        item.put("defaultSkuId", defaultSku == null ? null : defaultSku.getId());
        item.put("skuId", defaultSku == null ? null : defaultSku.getId());
        item.put("skuName", defaultSku == null ? "" : defaultSku.getSkuName());
        item.put("skuWeightG", defaultSku == null ? null : defaultSku.getSkuWeightG());
        item.put("seasonScore", it.breakdown.seasonScore);
        item.put("freshnessScore", it.breakdown.freshnessScore);
        item.put("salesScore", it.breakdown.salesScore);
        item.put("marginScore", it.breakdown.marginScore);
        item.put("stockScore", it.breakdown.stockScore);
        item.put("totalScore", it.breakdown.totalScore);
        item.put("recommendReason", buildReason(g, it.breakdown));
        item.put("tags", buildTags(g, it.breakdown));
        item.put("seasonStage", seasonStage);
        item.put("seasonStageText", toSeasonStageText(seasonStage));
        item.put("seasonFreshnessHint", buildSeasonFreshnessHint(g, seasonStage));
        item.put("seasonMarketingText", buildSeasonMarketingText(g, seasonStage));
        item.put("seasonMonthRangeText", buildSeasonMonthRangeText(g));
        return item;
    }

    private GoodsSku resolveDefaultSku(Long goodsId) {
        if (goodsId == null) return null;
        List<GoodsSku> skuList = goodsSkuMapper.selectListByGoodsId(goodsId);
        if (skuList == null || skuList.isEmpty()) return null;
        for (GoodsSku sku : skuList) {
            if (sku == null || sku.getId() == null) continue;
            Integer stock = sku.getSkuStock();
            if (stock != null && stock > 0) {
                return sku;
            }
        }
        return skuList.get(0);
    }

    private String buildReason(Goods g, ScoreBreakdown score) {
        String origin = g.getOrigin() == null || g.getOrigin().trim().isEmpty() ? "时令" : g.getOrigin().trim();
        if (hasSeasonWindowConfig(g) && "late".equals(detectGoodsSeasonStage(g))) {
            return origin + "供应期接近尾声，建议按需尽快采购";
        }
        if (score.seasonScore >= 85) return origin + "当季适配高，风味稳定";
        if (score.freshnessScore >= 80) return "库存新鲜度表现好，适合本周购买";
        if (score.salesScore >= 70) return "近期销量高，用户复购表现稳定";
        return "综合评分均衡，适合作为当季备选";
    }

    private List<String> buildTags(Goods g, ScoreBreakdown score) {
        List<String> tags = new ArrayList<>();
        tags.add("当季精选");
        String seasonStage = hasSeasonWindowConfig(g) ? detectGoodsSeasonStage(g) : detectSeasonStage(detectCurrentSeason());
        if ("late".equals(seasonStage)) tags.add("即将过季");
        if ("peak".equals(seasonStage)) tags.add("应季正鲜");
        if (hasSeasonWindowConfig(g)) tags.add("供应期可配");
        if (score.totalScore >= 85) tags.add("高评分");
        if (g.getStock() != null && g.getStock() >= 100) tags.add("库存充足");
        if (g.getIsRecommend() != null && g.getIsRecommend() == 1) tags.add("店长推荐");
        return tags;
    }

    private Map<String, Object> buildPayload(
            String season,
            String region,
            String budgetLevel,
            String sortBy,
            String produceType,
            boolean strictTag,
            int limit,
            List<Map<String, Object>> items,
            List<Goods> allOnSaleGoods,
            Map<String, String> config
    ) {
        Map<String, Object> data = new HashMap<>();
        String seasonText = toSeasonText(season);
        String titleTpl = config.getOrDefault("title.template", "{seasonText}当季精选");
        String subTitleTpl = config.getOrDefault("subtitle.template", "优先新鲜度、当季适配和库存稳定性");
        data.put("season", season);
        data.put("seasonText", seasonText);
        data.put("region", region);
        data.put("regionOptions", buildRegionOptions(allOnSaleGoods));
        data.put("budgetLevel", budgetLevel);
        data.put("sortBy", sortBy);
        data.put("produceType", produceType);
        data.put("strictTag", strictTag);
        data.put("limit", limit);
        data.put("refreshTime", System.currentTimeMillis());
        data.put("headline", titleTpl.replace("{seasonText}", seasonText));
        data.put("subHeadline", subTitleTpl.replace("{seasonText}", seasonText));
        data.put("seasonStage", detectSeasonStage(season));
        data.put("seasonStageText", toSeasonStageText(detectSeasonStage(season)));
        data.put("items", items);
        data.put("fallbackUsed", items != null && items.stream().anyMatch(it -> Boolean.TRUE.equals(it.get("fallbackUsed"))));
        data.put("fallbackMessage", items != null && items.stream().anyMatch(it -> Boolean.TRUE.equals(it.get("fallbackUsed")))
                ? "当前筛选条件下暂无直接命中的商品，以下为你展示当季推荐结果"
                : "");
        appendCoverageWarning(data, produceType, strictTag, items, allOnSaleGoods);
        data.put("configVersion", System.currentTimeMillis());
        return data;
    }

    private String detectSeasonByMonth(int month) {
        if (month >= 3 && month <= 5) return "spring";
        if (month >= 6 && month <= 8) return "summer";
        if (month >= 9 && month <= 11) return "autumn";
        return "winter";
    }

    private String detectSeasonStage(String season) {
        int month = LocalDate.now().getMonthValue();
        int offset;
        if ("spring".equals(season)) offset = month - 3;
        else if ("summer".equals(season)) offset = month - 6;
        else if ("autumn".equals(season)) offset = month - 9;
        else offset = month == 12 ? 0 : month;
        if (offset <= 0) return "early";
        if (offset >= 2) return "late";
        return "peak";
    }

    private String detectGoodsSeasonStage(Goods goods) {
        if (!hasSeasonWindowConfig(goods)) {
            return detectSeasonStage(detectCurrentSeason());
        }
        LocalDate currentDate = LocalDate.now();
        SeasonWindow window = resolveSeasonWindow(goods, currentDate);
        if (window == null) return "peak";
        if (!currentDate.isAfter(window.startDate)) return "early";
        if (!currentDate.isBefore(window.endDate)) return "late";
        int safeLateThresholdDays = resolveLateThresholdDays(goods);
        if (!currentDate.isBefore(window.endDate.minusDays(safeLateThresholdDays))) return "late";
        int earlyThresholdDays = Math.min(15, Math.max(3, safeLateThresholdDays / 2));
        if (!currentDate.isAfter(window.startDate.plusDays(earlyThresholdDays))) return "early";
        return "peak";
    }

    private List<Integer> expandSeasonMonths(Integer startMonth, Integer endMonth) {
        List<Integer> months = new ArrayList<>();
        if (startMonth == null || endMonth == null) return months;
        int start = Math.max(1, Math.min(12, startMonth));
        int end = Math.max(1, Math.min(12, endMonth));
        if (start <= end) {
            for (int m = start; m <= end; m++) months.add(m);
            return months;
        }
        for (int m = start; m <= 12; m++) months.add(m);
        for (int m = 1; m <= end; m++) months.add(m);
        return months;
    }

    private String toSeasonStageText(String seasonStage) {
        if ("early".equals(seasonStage)) return "季初上新";
        if ("late".equals(seasonStage)) return "即将过季";
        return "应季正鲜";
    }

    private int resolveLateThresholdDays(Goods goods) {
        if (goods == null || goods.getSeasonLateThresholdDays() == null || goods.getSeasonLateThresholdDays() <= 0) {
            return 20;
        }
        return goods.getSeasonLateThresholdDays();
    }

    private SeasonWindow resolveSeasonWindow(Goods goods, LocalDate currentDate) {
        if (goods == null || currentDate == null || !hasSeasonWindowConfig(goods)) return null;
        int startMonth = Math.max(1, Math.min(12, goods.getSeasonStartMonth()));
        int endMonth = Math.max(1, Math.min(12, goods.getSeasonEndMonth()));
        int currentYear = currentDate.getYear();
        if (startMonth <= endMonth) {
            LocalDate startDate = LocalDate.of(currentYear, startMonth, 1);
            LocalDate endDate = YearMonth.of(currentYear, endMonth).atEndOfMonth();
            return new SeasonWindow(startDate, endDate);
        }
        if (currentDate.getMonthValue() >= startMonth) {
            LocalDate startDate = LocalDate.of(currentYear, startMonth, 1);
            LocalDate endDate = YearMonth.of(currentYear + 1, endMonth).atEndOfMonth();
            return new SeasonWindow(startDate, endDate);
        }
        LocalDate startDate = LocalDate.of(currentYear - 1, startMonth, 1);
        LocalDate endDate = YearMonth.of(currentYear, endMonth).atEndOfMonth();
        return new SeasonWindow(startDate, endDate);
    }

    private static class SeasonWindow {
        private final LocalDate startDate;
        private final LocalDate endDate;

        private SeasonWindow(LocalDate startDate, LocalDate endDate) {
            this.startDate = startDate;
            this.endDate = endDate;
        }
    }

    private String buildSeasonFreshnessHint(Goods goods, String seasonStage) {
        if (hasSeasonWindowConfig(goods)) {
            if ("early".equals(seasonStage) && notBlank(goods.getSeasonEarlyHint())) return goods.getSeasonEarlyHint().trim();
            if ("peak".equals(seasonStage) && notBlank(goods.getSeasonPeakHint())) return goods.getSeasonPeakHint().trim();
            if ("late".equals(seasonStage) && notBlank(goods.getSeasonLateHint())) return goods.getSeasonLateHint().trim();
        }
        if ("early".equals(seasonStage)) return "新一季刚上架，适合尝鲜";
        if ("late".equals(seasonStage)) return "供应窗口缩短，建议尽快下单";
        return "当前正处在最佳赏味期";
    }

    private String buildSeasonMarketingText(Goods goods, String seasonStage) {
        BigDecimal price = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
        BigDecimal originalPrice = goods.getOriginalPrice() == null ? BigDecimal.ZERO : goods.getOriginalPrice();
        boolean hasDiscount = originalPrice.compareTo(price) > 0;
        if ("late".equals(seasonStage)) {
            return hasDiscount ? "临近季末，当前价格更有优势" : "临近季末，建议按需下单及时尝鲜";
        }
        if ("early".equals(seasonStage)) {
            return "新季风味刚到位，适合本周首购尝鲜";
        }
        return hasDiscount ? "应季口感稳定，当前还有当季价优势" : "应季供应稳定，口感和新鲜度更均衡";
    }

    private String buildSeasonMonthRangeText(Goods goods) {
        if (!hasSeasonWindowConfig(goods)) return "";
        return goods.getSeasonStartMonth() + "-" + goods.getSeasonEndMonth() + "月供应";
    }

    private boolean notBlank(String value) {
        return value != null && !value.trim().isEmpty();
    }

    private List<Map<String, String>> buildRegionOptions(List<Goods> allOnSaleGoods) {
        List<Map<String, String>> options = new ArrayList<>();
        options.add(option("all", "全部产地"));
        if (allOnSaleGoods == null || allOnSaleGoods.isEmpty()) return options;

        Map<String, Integer> regionCount = new LinkedHashMap<>();
        for (Goods goods : allOnSaleGoods) {
            if (goods == null || goods.getOrigin() == null) continue;
            String origin = goods.getOrigin().trim();
            if (origin.isEmpty()) continue;
            String[] parts = origin.split("[,，/|]");
            for (String part : parts) {
                String region = part == null ? "" : part.trim();
                if (region.isEmpty()) continue;
                regionCount.put(region, regionCount.getOrDefault(region, 0) + 1);
            }
        }

        regionCount.entrySet().stream()
                .sorted((a, b) -> {
                    int cmp = Integer.compare(b.getValue(), a.getValue());
                    if (cmp != 0) return cmp;
                    return a.getKey().compareTo(b.getKey());
                })
                .limit(12)
                .forEach(it -> options.add(option(it.getKey(), it.getKey())));
        return options;
    }

    private Map<String, String> option(String key, String text) {
        Map<String, String> item = new HashMap<>();
        item.put("key", key);
        item.put("text", text);
        return item;
    }

    private void appendCoverageWarning(Map<String, Object> data, String produceType, boolean strictTag, List<Map<String, Object>> items, List<Goods> allOnSaleGoods) {
        if (!strictTag) return;
        if ("all".equals(produceType)) return;
        int total = allOnSaleGoods == null ? 0 : allOnSaleGoods.size();
        int current = items == null ? 0 : items.size();
        if (total <= 0) return;
        if (current <= 2 || ((double) current / (double) total) < 0.05d) {
            data.put("coverageWarning", "当前筛选命中较少，请检查商品是否已补齐 produce/season 标签");
        }
    }

    private String toSeasonText(String season) {
        if ("spring".equals(season)) return "春季";
        if ("summer".equals(season)) return "夏季";
        if ("autumn".equals(season)) return "秋季";
        return "冬季";
    }

    private static class ScoredGoods {
        private final Goods goods;
        private final ScoreBreakdown breakdown;

        private ScoredGoods(Goods goods, ScoreBreakdown breakdown) {
            this.goods = goods;
            this.breakdown = breakdown;
        }
    }

    private static class ScoreBreakdown {
        private final double totalScore;
        private final double seasonScore;
        private final double freshnessScore;
        private final double salesScore;
        private final double marginScore;
        private final double stockScore;

        private ScoreBreakdown(double totalScore, double seasonScore, double freshnessScore, double salesScore, double marginScore, double stockScore) {
            this.totalScore = totalScore;
            this.seasonScore = seasonScore;
            this.freshnessScore = freshnessScore;
            this.salesScore = salesScore;
            this.marginScore = marginScore;
            this.stockScore = stockScore;
        }
    }
}
