package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.entity.SkuComponent;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.GoodsSkuMapper;
import com.example.freshtime.mapper.SkuComponentMapper;
import com.example.freshtime.service.GoodsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class GoodsServiceImpl implements GoodsService {
    private static final int SCENE_LIST_LIMIT = 30;

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private GoodsSkuMapper goodsSkuMapper;

    @Autowired
    private SkuComponentMapper skuComponentMapper;

    @Override
    public ApiResponse<?> getGoodsList(Long categoryId) {
        List<Goods> list = goodsMapper.selectByCategoryId(categoryId);
        return ApiResponse.success(buildGoodsCardList(list));
    }

    @Override
    public ApiResponse<?> getGoodsListByScene(String scene) {
        String cleanScene = scene == null ? "" : scene.trim();
        if (cleanScene.isEmpty()) {
            return ApiResponse.success(goodsMapper.selectRecommendList());
        }
        String tagName;
        if ("小份量".equals(cleanScene)) {
            tagName = "小份量";
        } else if ("搭配".equals(cleanScene)) {
            tagName = "搭配";
        } else if ("时令".equals(cleanScene)) {
            tagName = "时令";
        } else {
            tagName = "";
        }
        List<Goods> list;
        if (tagName.isEmpty()) {
            list = goodsMapper.selectBySceneKeyword(cleanScene);
        } else {
            list = goodsMapper.selectByTagName(tagName);
            if (list == null || list.isEmpty()) {
                list = goodsMapper.selectBySceneKeyword(resolveSceneFallbackKeyword(cleanScene));
            }
        }
        if (list != null && list.size() > SCENE_LIST_LIMIT) {
            list = new ArrayList<>(list.subList(0, SCENE_LIST_LIMIT));
        }
        return ApiResponse.success(buildSceneGoodsList(cleanScene, list));
    }

    @Override
    public ApiResponse<?> getRecommendList() {
        List<Goods> list = goodsMapper.selectRecommendList();
        return ApiResponse.success(buildGoodsCardList(list));
    }

    @Override
    public ApiResponse<?> getGoodsDetail(Long id) {
        Goods goods = goodsMapper.selectById(id);
        if (goods != null) {
            Map<String, Object> data = new HashMap<>();
            data.put("id", goods.getId());
            data.put("categoryId", goods.getCategoryId());
            data.put("name", goods.getName());
            data.put("mainImage", goods.getMainImage());
            data.put("images", goods.getImages());
            data.put("detail", goods.getDetail());
            data.put("price", goods.getPrice());
            data.put("originalPrice", goods.getOriginalPrice());
            data.put("stock", goods.getStock());
            data.put("unit", goods.getUnit());
            data.put("salesVolume", goods.getSalesVolume());
            data.put("isFlash", goods.getIsFlash());
            data.put("flashPrice", goods.getFlashPrice());
            data.put("flashStartTime", goods.getFlashStartTime());
            data.put("flashEndTime", goods.getFlashEndTime());
            data.put("flashStock", goods.getFlashStock());
            data.put("status", goods.getStatus());
            data.put("origin", goods.getOrigin());
            data.put("keywords", goods.getKeywords());
            data.put("skuList", buildSkuViewList(goods));
            return ApiResponse.success(data);
        }
        return ApiResponse.fail(404, "商品不存在");
    }

    @Override
    public ApiResponse<?> searchGoods(String keyword, Integer page, Integer pageSize) {
        String cleanKeyword = keyword == null ? "" : keyword.trim();
        int safePage = (page == null || page < 1) ? 1 : page;
        int safePageSize = (pageSize == null || pageSize < 1) ? 20 : Math.min(pageSize, 50);
        int offset = (safePage - 1) * safePageSize;
        List<Goods> list = goodsMapper.searchByKeyword(cleanKeyword, offset, safePageSize);
        Integer total = goodsMapper.countByKeyword(cleanKeyword);
        int totalCount = total == null ? 0 : total;

        Map<String, Object> data = new HashMap<>();
        data.put("list", buildGoodsCardList(list));
        data.put("page", safePage);
        data.put("pageSize", safePageSize);
        data.put("total", totalCount);
        data.put("hasMore", offset + safePageSize < totalCount);
        return ApiResponse.success(data);
    }

    public List<Map<String, Object>> buildGoodsCardList(List<Goods> list) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (list == null || list.isEmpty()) {
            return result;
        }
        for (Goods goods : list) {
            if (goods == null) continue;
            Map<String, Object> row = new HashMap<>();
            row.put("id", goods.getId());
            row.put("categoryId", goods.getCategoryId());
            row.put("name", goods.getName());
            row.put("mainImage", goods.getMainImage());
            row.put("images", goods.getImages());
            row.put("detail", goods.getDetail());
            row.put("price", goods.getPrice());
            row.put("originalPrice", goods.getOriginalPrice());
            row.put("stock", goods.getStock());
            row.put("unit", goods.getUnit());
            row.put("salesVolume", goods.getSalesVolume());
            row.put("isFlash", goods.getIsFlash());
            row.put("flashPrice", goods.getFlashPrice());
            row.put("flashStartTime", goods.getFlashStartTime());
            row.put("flashEndTime", goods.getFlashEndTime());
            row.put("flashStock", goods.getFlashStock());
            row.put("status", goods.getStatus());
            row.put("origin", goods.getOrigin());
            row.put("keywords", goods.getKeywords());
            row.put("skuList", buildSkuViewList(goods));
            result.add(row);
        }
        return result;
    }

    private List<Map<String, Object>> buildSceneGoodsList(String scene, List<Goods> list) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (list == null || list.isEmpty()) {
            return result;
        }
        for (Goods goods : list) {
            List<Map<String, Object>> skuList = buildSkuViewList(goods);
            Map<String, Object> row = new HashMap<>();
            row.put("id", goods.getId());
            row.put("categoryId", goods.getCategoryId());
            row.put("name", goods.getName());
            row.put("mainImage", goods.getMainImage());
            row.put("price", goods.getPrice());
            row.put("originalPrice", goods.getOriginalPrice());
            row.put("stock", goods.getStock());
            row.put("unit", goods.getUnit());
            row.put("salesVolume", goods.getSalesVolume());
            row.put("isFlash", goods.getIsFlash());
            row.put("flashPrice", goods.getFlashPrice());
            row.put("flashStartTime", goods.getFlashStartTime());
            row.put("flashEndTime", goods.getFlashEndTime());
            row.put("flashStock", goods.getFlashStock());
            row.put("origin", goods.getOrigin());
            row.put("keywords", goods.getKeywords());
            row.put("sceneType", resolveSceneType(scene, goods));
            row.put("comboMode", resolveComboMode(scene, goods));
            row.put("packType", resolvePackType(scene, goods));
            row.put("couponThresholdHint", resolveCouponThresholdHint(scene, goods));
            row.put("skuList", skuList);
            result.add(row);
        }
        return result;
    }

    private List<Map<String, Object>> buildSkuViewList(Goods goods) {
        List<GoodsSku> skuList = goodsSkuMapper.selectListByGoodsId(goods.getId());
        List<Map<String, Object>> result = new ArrayList<>();
        if (skuList == null || skuList.isEmpty()) {
            result.add(buildVirtualSku(goods));
            return result;
        }
        for (GoodsSku sku : skuList) {
            result.add(buildSkuView(goods, sku));
        }
        return result;
    }

    private Map<String, Object> buildVirtualSku(Goods goods) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", null);
        row.put("goodsId", goods.getId());
        row.put("skuName", "标准装");
        row.put("skuWeightG", 500);
        row.put("skuPrice", goods.getPrice());
        row.put("skuStock", goods.getStock());
        row.put("status", 1);
        row.put("sort", 0);
        return row;
    }

    private Map<String, Object> buildSkuView(Goods goods, GoodsSku sku) {
        Map<String, Object> row = new HashMap<>();
        row.put("id", sku.getId());
        row.put("goodsId", goods.getId());
        row.put("skuName", sku.getSkuName());
        row.put("skuWeightG", sku.getSkuWeightG());
        row.put("skuPrice", sku.getSkuPrice());
        row.put("skuStock", sku.getSkuStock());
        row.put("status", sku.getStatus());
        row.put("sort", sku.getSort());
        row.put("specType", sku.getSpecType());
        row.put("specValue", sku.getSpecValue());
        row.put("components", buildSkuComponents(sku.getId()));
        return row;
    }

    private List<Map<String, Object>> buildSkuComponents(Long skuId) {
        List<Map<String, Object>> result = new ArrayList<>();
        if (skuId == null) {
            return result;
        }
        List<SkuComponent> list = skuComponentMapper.selectBySkuId(skuId);
        if (list == null || list.isEmpty()) {
            return result;
        }
        for (SkuComponent item : list) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", item.getId());
            row.put("skuId", item.getSkuId());
            row.put("componentGoodsId", item.getComponentGoodsId());
            row.put("componentName", item.getComponentName());
            row.put("componentWeightG", item.getComponentWeightG());
            row.put("quantity", item.getQuantity());
            row.put("componentPrice", item.getComponentPrice());
            row.put("sort", item.getSort());
            result.add(row);
        }
        return result;
    }

    private String resolveSceneType(String scene, Goods goods) {
        if ("小份量".equals(scene)) {
            return resolvePackType(scene, goods);
        }
        if ("搭配".equals(scene)) {
            return resolveComboMode(scene, goods);
        }
        return "all";
    }

    private String resolvePackType(String scene, Goods goods) {
        if (!"小份量".equals(scene)) {
            return "single";
        }
        String text = safeText(goods.getName()) + "," + safeText(goods.getKeywords()) + "," + safeText(goods.getDetail());
        if (containsAny(text, "随机", "盲盒", "自选")) return "random";
        if (containsAny(text, "拼盘", "组合", "礼盒", "果切", "菜谱", "净菜", "免洗", "预处理", "加工")) return "platter";
        return "single";
    }

    private String resolveComboMode(String scene, Goods goods) {
        if (!"搭配".equals(scene)) {
            return "fixed";
        }
        String text = safeText(goods.getName()) + "," + safeText(goods.getKeywords()) + "," + safeText(goods.getDetail());
        if (containsAny(text, "随机", "任选", "自选", "2蔬", "两蔬", "一果", "1果")) return "random";
        return "fixed";
    }

    private String resolveCouponThresholdHint(String scene, Goods goods) {
        BigDecimal price = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
        if ("搭配".equals(scene)) {
            if (price.compareTo(new BigDecimal("99")) >= 0) return "满99可用大额券";
            if (price.compareTo(new BigDecimal("50")) >= 0) return "满50可用满减券";
            return "建议凑单到满50更划算";
        }
        if ("小份量".equals(scene)) {
            if (price.compareTo(new BigDecimal("39")) >= 0) return "满足新人券门槛";
            return "建议凑单到满39更划算";
        }
        return "";
    }

    private List<Map<String, Object>> buildSpecRules(List<Map<String, Object>> skuList) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (skuList == null || skuList.isEmpty()) {
            return list;
        }
        Map<String, Object> first = skuList.get(0);
        BigDecimal basePrice = toBigDecimal(first.get("skuPrice"));
        list.add(buildSpecRule("standard", "标准", basePrice, 1, first));
        list.add(buildSpecRule("plus", "加量", basePrice.multiply(new BigDecimal("1.5")), 2, first));
        list.add(buildSpecRule("family", "家庭装", basePrice.multiply(new BigDecimal("2.5")), 3, first));
        return list;
    }

    private Map<String, Object> buildSpecRule(String key, String label, BigDecimal price, int quantity, Map<String, Object> sku) {
        Map<String, Object> rule = new HashMap<>();
        rule.put("key", key);
        rule.put("label", label);
        rule.put("price", price.setScale(2, RoundingMode.HALF_UP));
        rule.put("quantity", quantity);
        rule.put("skuId", sku == null ? null : sku.get("id"));
        rule.put("skuName", sku == null ? null : sku.get("skuName"));
        return rule;
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        }
        if (value instanceof Number) {
            return new BigDecimal(String.valueOf(value));
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (Exception error) {
            return BigDecimal.ZERO;
        }
    }

    private boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) return true;
        }
        return false;
    }

    private String safeText(String text) {
        return text == null ? "" : text;
    }

    private String resolveSceneFallbackKeyword(String scene) {
        if ("小份量".equals(scene)) {
            return "小份";
        }
        if ("搭配".equals(scene)) {
            return "搭配";
        }
        if ("时令".equals(scene)) {
            return "时令";
        }
        return scene;
    }
}
