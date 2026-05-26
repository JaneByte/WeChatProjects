package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.admin.AdminCategorySaveRequest;
import com.example.freshtime.dto.admin.AdminCouponSaveRequest;
import com.example.freshtime.dto.admin.AdminGoodsSaveRequest;
import com.example.freshtime.dto.admin.AdminShopProfileSaveRequest;
import com.example.freshtime.entity.AdminInfo;
import com.example.freshtime.entity.Category;
import com.example.freshtime.entity.CouponInfo;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import com.example.freshtime.mapper.AdminMapper;
import com.example.freshtime.mapper.CategoryMapper;
import com.example.freshtime.mapper.CouponMapper;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.GoodsSkuMapper;
import com.example.freshtime.mapper.GoodsTagMapper;
import com.example.freshtime.mapper.OrderMapper;
import com.example.freshtime.mapper.PlanRuleConfigMapper;
import com.example.freshtime.mapper.SeasonalConfigMapper;
import com.example.freshtime.mapper.TagMapper;
import com.example.freshtime.mapper.UserMapper;
import com.example.freshtime.service.AdminService;
import com.example.freshtime.service.impl.support.AdminConfigHelper;
import com.example.freshtime.service.impl.support.AdminDashboardHelper;
import com.example.freshtime.service.impl.support.AdminGoodsSkuHelper;
import com.example.freshtime.vo.admin.AdminDashboardOverviewVO;
import com.example.freshtime.vo.admin.AdminOrderDetailVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class AdminServiceImpl implements AdminService {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

    @Autowired
    private AdminMapper adminMapper;

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private CategoryMapper categoryMapper;

    @Autowired
    private OrderMapper orderMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private TagMapper tagMapper;

    @Autowired
    private GoodsTagMapper goodsTagMapper;

    @Autowired
    private GoodsSkuMapper goodsSkuMapper;

    @Autowired
    private PlanRuleConfigMapper planRuleConfigMapper;

    @Autowired
    private SeasonalConfigMapper seasonalConfigMapper;

    @Autowired
    private AdminDashboardHelper adminDashboardHelper;

    @Autowired
    private AdminConfigHelper adminConfigHelper;

    @Autowired
    private AdminGoodsSkuHelper adminGoodsSkuHelper;

    @Override
    public ApiResponse<?> getDashboardOverview() {
        AdminDashboardOverviewVO overview = adminDashboardHelper.buildOverview();
        return ApiResponse.success("查询成功", overview);
    }

    @Override
    public ApiResponse<?> getGoodsList(String keyword, Integer status, Long categoryId) {
        List<Goods> rows = goodsMapper.selectAdminGoodsList(trim(keyword), status, categoryId);
        Map<Long, Integer> skuSalesMap = adminGoodsSkuHelper.buildSkuSalesMap();
        List<Map<String, Object>> data = new ArrayList<>();
        for (Goods goods : rows) {
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
            row.put("isRecommend", goods.getIsRecommend());
            row.put("isFlash", goods.getIsFlash());
            row.put("flashPrice", goods.getFlashPrice());
            row.put("flashStartTime", goods.getFlashStartTime());
            row.put("flashEndTime", goods.getFlashEndTime());
            row.put("flashStock", goods.getFlashStock());
            row.put("homeSort", goods.getHomeSort());
            row.put("showInHome", goods.getShowInHome());
            row.put("status", goods.getStatus());
            row.put("origin", goods.getOrigin());
            row.put("keywords", goods.getKeywords());
            row.put("seasonStartMonth", goods.getSeasonStartMonth());
            row.put("seasonEndMonth", goods.getSeasonEndMonth());
            row.put("seasonLateThresholdDays", goods.getSeasonLateThresholdDays());
            row.put("seasonEarlyHint", goods.getSeasonEarlyHint());
            row.put("seasonPeakHint", goods.getSeasonPeakHint());
            row.put("seasonLateHint", goods.getSeasonLateHint());
            row.put("createTime", goods.getCreateTime());
            List<GoodsSku> skuList = goodsSkuMapper.selectAdminListByGoodsId(goods.getId());
            List<Map<String, Object>> skuViewList = new ArrayList<>();
            for (GoodsSku sku : skuList) {
                if (sku == null) continue;
                Map<String, Object> skuRow = new HashMap<>();
                skuRow.put("id", sku.getId());
                skuRow.put("goodsId", sku.getGoodsId());
                skuRow.put("skuName", sku.getSkuName());
                skuRow.put("skuWeightG", sku.getSkuWeightG());
                skuRow.put("skuPrice", sku.getSkuPrice());
                skuRow.put("skuStock", sku.getSkuStock());
                skuRow.put("status", sku.getStatus());
                skuRow.put("sort", sku.getSort());
                skuRow.put("specType", sku.getSpecType());
                skuRow.put("specValue", sku.getSpecValue());
                skuRow.put("salesVolume", skuSalesMap.getOrDefault(sku.getId(), 0));
                skuViewList.add(skuRow);
            }
            row.put("skuList", skuViewList);
            data.add(row);
        }
        return ApiResponse.success("查询成功", data);
    }

    @Override
    public ApiResponse<?> getTagList(Boolean structuredOnly) {
        return ApiResponse.success("查询成功", tagMapper.selectTagList(structuredOnly));
    }

    @Override
    public ApiResponse<?> getGoodsTags(Long goodsId) {
        if (goodsId == null) {
            return ApiResponse.badRequest("商品ID不能为空");
        }
        Goods goods = goodsMapper.selectById(goodsId);
        if (goods == null) {
            return ApiResponse.notFound("商品不存在");
        }
        return ApiResponse.success("查询成功", goodsTagMapper.selectTagsByGoodsId(goodsId));
    }

    @Override
    @Transactional
    public ApiResponse<?> saveGoods(AdminGoodsSaveRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("商品参数不能为空");
        }
        String name = trim(request.getName());
        if (name.isEmpty()) {
            return ApiResponse.badRequest("商品名称不能为空");
        }
        if (request.getCategoryId() == null) {
            return ApiResponse.badRequest("分类不能为空");
        }
        if (request.getPrice() == null || request.getPrice().compareTo(BigDecimal.ZERO) < 0) {
            return ApiResponse.badRequest("商品价格不能为空");
        }
        String skuError = adminGoodsSkuHelper.validateSkuList(request.getSkuList());
        if (!skuError.isEmpty()) {
            return ApiResponse.badRequest(skuError);
        }

        Goods goods;
        if (request.getId() == null) {
            goods = new Goods();
            goods.setId(null);
            goods.setCategoryId(request.getCategoryId());
            goods.setName(name);
            goods.setMainImage(trim(request.getMainImage()));
            goods.setImages(trim(request.getImages()));
            goods.setDetail(trim(request.getDetail()));
            goods.setPrice(request.getPrice());
            goods.setOriginalPrice(request.getOriginalPrice());
            goods.setStock(defaultInt(request.getStock()));
            goods.setUnit(defaultText(request.getUnit(), "斤"));
            goods.setSalesVolume(0);
            goods.setIsRecommend(defaultFlag(request.getIsRecommend()));
            goods.setIsFlash(defaultFlag(request.getIsFlash()));
            goods.setFlashPrice(request.getFlashPrice());
            goods.setFlashStartTime(parseDateTime(request.getFlashStartTime()));
            goods.setFlashEndTime(parseDateTime(request.getFlashEndTime()));
            goods.setFlashStock(defaultInt(request.getFlashStock()));
            goods.setHomeSort(defaultInt(request.getHomeSort()));
            goods.setShowInHome(defaultFlag(request.getShowInHome()));
            goods.setStatus(request.getStatus() == null ? 1 : request.getStatus());
            goods.setOrigin(trim(request.getOrigin()));
            goods.setKeywords(trim(request.getKeywords()));
            goods.setSeasonStartMonth(request.getSeasonStartMonth());
            goods.setSeasonEndMonth(request.getSeasonEndMonth());
            goods.setSeasonLateThresholdDays(request.getSeasonLateThresholdDays() == null ? 20 : request.getSeasonLateThresholdDays());
            goods.setSeasonEarlyHint(trim(request.getSeasonEarlyHint()));
            goods.setSeasonPeakHint(trim(request.getSeasonPeakHint()));
            goods.setSeasonLateHint(trim(request.getSeasonLateHint()));
            goodsMapper.insertGoods(goods);
        } else {
            Goods current = goodsMapper.selectById(request.getId());
            if (current == null) {
                return ApiResponse.notFound("商品不存在");
            }
            goods = new Goods();
            goods.setId(current.getId());
            goods.setCategoryId(request.getCategoryId() == null ? current.getCategoryId() : request.getCategoryId());
            goods.setName(name.isEmpty() ? current.getName() : name);
            goods.setMainImage(request.getMainImage() == null ? current.getMainImage() : trim(request.getMainImage()));
            goods.setImages(request.getImages() == null ? current.getImages() : trim(request.getImages()));
            goods.setDetail(request.getDetail() == null ? current.getDetail() : trim(request.getDetail()));
            goods.setPrice(request.getPrice() == null ? current.getPrice() : request.getPrice());
            goods.setOriginalPrice(request.getOriginalPrice() == null ? current.getOriginalPrice() : request.getOriginalPrice());
            goods.setStock(request.getStock() == null ? current.getStock() : defaultInt(request.getStock()));
            goods.setUnit(request.getUnit() == null ? current.getUnit() : defaultText(request.getUnit(), "斤"));
            goods.setSalesVolume(current.getSalesVolume());
            goods.setIsRecommend(request.getIsRecommend() == null ? current.getIsRecommend() : request.getIsRecommend());
            goods.setIsFlash(request.getIsFlash() == null ? current.getIsFlash() : request.getIsFlash());
            goods.setFlashPrice(request.getFlashPrice() == null ? current.getFlashPrice() : request.getFlashPrice());
            goods.setFlashStartTime(request.getFlashStartTime() == null ? current.getFlashStartTime() : parseDateTime(request.getFlashStartTime()));
            goods.setFlashEndTime(request.getFlashEndTime() == null ? current.getFlashEndTime() : parseDateTime(request.getFlashEndTime()));
            goods.setFlashStock(request.getFlashStock() == null ? current.getFlashStock() : defaultInt(request.getFlashStock()));
            goods.setHomeSort(request.getHomeSort() == null ? current.getHomeSort() : defaultInt(request.getHomeSort()));
            goods.setShowInHome(request.getShowInHome() == null ? current.getShowInHome() : request.getShowInHome());
            goods.setStatus(request.getStatus() == null ? current.getStatus() : request.getStatus());
            goods.setOrigin(request.getOrigin() == null ? current.getOrigin() : trim(request.getOrigin()));
            goods.setKeywords(request.getKeywords() == null ? current.getKeywords() : trim(request.getKeywords()));
            goods.setSeasonStartMonth(request.getSeasonStartMonth() == null ? current.getSeasonStartMonth() : request.getSeasonStartMonth());
            goods.setSeasonEndMonth(request.getSeasonEndMonth() == null ? current.getSeasonEndMonth() : request.getSeasonEndMonth());
            goods.setSeasonLateThresholdDays(request.getSeasonLateThresholdDays() == null ? current.getSeasonLateThresholdDays() : request.getSeasonLateThresholdDays());
            goods.setSeasonEarlyHint(request.getSeasonEarlyHint() == null ? current.getSeasonEarlyHint() : trim(request.getSeasonEarlyHint()));
            goods.setSeasonPeakHint(request.getSeasonPeakHint() == null ? current.getSeasonPeakHint() : trim(request.getSeasonPeakHint()));
            goods.setSeasonLateHint(request.getSeasonLateHint() == null ? current.getSeasonLateHint() : trim(request.getSeasonLateHint()));
            goods.setCreateTime(current.getCreateTime());
            goodsMapper.updateGoods(goods);
        }
        syncStructuredGoodsTags(goods.getId(), request.getTagIds());
        adminGoodsSkuHelper.syncGoodsSkuList(goods, request.getSkuList());
        return ApiResponse.success("保存成功", goodsMapper.selectById(goods.getId()));
    }

    @Override
    public ApiResponse<?> updateGoodsStatus(Long id, Integer status) {
        if (id == null || status == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        Goods goods = goodsMapper.selectById(id);
        if (goods == null) {
            return ApiResponse.notFound("商品不存在");
        }
        goodsMapper.updateGoodsStatus(id, status);
        return ApiResponse.success("更新成功", goodsMapper.selectById(id));
    }

    @Override
    public ApiResponse<?> getCategoryList() {
        return ApiResponse.success("查询成功", categoryMapper.selectAll());
    }

    @Override
    public ApiResponse<?> saveCategory(AdminCategorySaveRequest request) {
        if (request == null || trim(request.getName()).isEmpty()) {
            return ApiResponse.badRequest("分类名称不能为空");
        }
        Category category = new Category();
        category.setId(request.getId());
        category.setParentId(request.getParentId() == null ? 0L : request.getParentId());
        category.setName(trim(request.getName()));
        category.setSort(defaultInt(request.getSort()));
        category.setStatus(request.getStatus() == null ? 1 : request.getStatus());

        if (category.getId() == null) {
            categoryMapper.insertCategory(category);
        } else {
            Category current = categoryMapper.selectById(category.getId());
            if (current == null) {
                return ApiResponse.notFound("分类不存在");
            }
            categoryMapper.updateCategory(category);
        }
        return ApiResponse.success("保存成功", categoryMapper.selectById(category.getId()));
    }

    @Override
    public ApiResponse<?> updateCategoryStatus(Long id, Integer status) {
        if (id == null || status == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        Category category = categoryMapper.selectById(id);
        if (category == null) {
            return ApiResponse.notFound("分类不存在");
        }
        Category next = new Category();
        next.setId(id);
        next.setStatus(status);
        categoryMapper.updateCategoryStatus(next);
        return ApiResponse.success("更新成功", categoryMapper.selectById(id));
    }

    @Override
    public ApiResponse<?> getOrderList(Integer status, Long userId) {
        return ApiResponse.success("查询成功", orderMapper.selectAdminOrderList(status, userId));
    }

    @Override
    public ApiResponse<?> getOrderDetail(Long orderId) {
        if (orderId == null) {
            return ApiResponse.badRequest("订单ID不能为空");
        }
        OrderInfo order = orderMapper.selectOrderById(orderId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        List<OrderItemInfo> items = orderMapper.selectOrderItemsByOrderId(orderId, order.getUserId());
        AdminOrderDetailVO detailVO = new AdminOrderDetailVO();
        detailVO.setOrder(order);
        detailVO.setItems(items);
        return ApiResponse.success("查询成功", detailVO);
    }

    @Override
    public ApiResponse<?> updateOrderStatus(Long orderId, Integer status) {
        if (orderId == null || status == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        OrderInfo order = orderMapper.selectOrderById(orderId);
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        Integer currentStatus = order.getStatus();
        Integer payStatus = order.getPayStatus();
        if (currentStatus == null) {
            return ApiResponse.badRequest("订单状态异常");
        }
        if (status == 2) {
            if (currentStatus != 1) {
                return ApiResponse.badRequest("仅待发货订单可标记发货");
            }
            if (payStatus == null || payStatus != 2) {
                return ApiResponse.badRequest("仅已支付订单可标记发货");
            }
            int updated = orderMapper.updateOrderStatusIfCurrent(orderId, 1, 2);
            if (updated <= 0) {
                return ApiResponse.badRequest("订单状态已变化，请刷新后重试");
            }
        } else if (status == 6) {
            if (currentStatus != 7) {
                return ApiResponse.badRequest("仅售后待审核订单可同意售后");
            }
            int updated = orderMapper.updateOrderStatusIfCurrent(orderId, 7, 6);
            if (updated <= 0) {
                return ApiResponse.badRequest("订单状态已变化，请刷新后重试");
            }
        } else if (status == 1 || status == 3) {
            if (currentStatus != 7) {
                return ApiResponse.badRequest("仅售后待审核订单可拒绝售后");
            }
            Integer rejectTarget = order.getFinishTime() == null ? 1 : 3;
            if (!rejectTarget.equals(status)) {
                return ApiResponse.badRequest("售后拒绝状态不匹配，请刷新后重试");
            }
            int updated = orderMapper.updateOrderStatusIfCurrent(orderId, 7, rejectTarget);
            if (updated <= 0) {
                return ApiResponse.badRequest("订单状态已变化，请刷新后重试");
            }
        } else {
            return ApiResponse.badRequest("管理端仅支持标记发货、审核售后");
        }
        return ApiResponse.success("更新成功", orderMapper.selectOrderById(orderId));
    }

    @Override
    public ApiResponse<?> getCouponList() {
        return ApiResponse.success("查询成功", couponMapper.selectAllCouponTemplates());
    }

    @Override
    public ApiResponse<?> saveCoupon(AdminCouponSaveRequest request) {
        if (request == null || trim(request.getName()).isEmpty()) {
            return ApiResponse.badRequest("优惠券名称不能为空");
        }
        CouponInfo coupon = new CouponInfo();
        coupon.setId(request.getId());
        coupon.setTitle(trim(request.getName()));
        coupon.setConditionText(trim(request.getDescription()));
        coupon.setThresholdAmount(request.getThresholdAmount() == null ? BigDecimal.ZERO : request.getThresholdAmount());
        coupon.setDiscountAmount(request.getDiscountAmount() == null ? BigDecimal.ZERO : request.getDiscountAmount());
        coupon.setExpireDate(parseDate(request.getExpireDate()));
        coupon.setStatus(request.getStatus() == null ? 1 : request.getStatus());

        if (coupon.getId() == null) {
            couponMapper.insertCouponTemplate(coupon);
        } else {
            couponMapper.updateCouponTemplate(coupon);
        }
        return ApiResponse.success("保存成功", couponMapper.selectAllCouponTemplates());
    }

    @Override
    public ApiResponse<?> updateCouponStatus(Long id, Integer status) {
        if (id == null || status == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        couponMapper.updateCouponTemplateStatus(id, status);
        return ApiResponse.success("更新成功", couponMapper.selectAllCouponTemplates());
    }

    @Override
    public ApiResponse<?> saveShopProfile(Long adminId, AdminShopProfileSaveRequest request) {
        if (adminId == null) {
            return ApiResponse.unauthorized("请先登录");
        }
        if (request == null) {
            return ApiResponse.badRequest("店铺信息不能为空");
        }
        AdminInfo current = adminMapper.selectById(adminId);
        if (current == null) {
            return ApiResponse.notFound("店铺账号不存在");
        }
        String shopName = trim(request.getShopName());
        String contactName = trim(request.getContactName());
        String phone = trim(request.getPhone());
        String address = trim(request.getAddress());
        if (shopName.isEmpty()) {
            return ApiResponse.badRequest("店铺名称不能为空");
        }
        if (contactName.isEmpty()) {
            return ApiResponse.badRequest("联系人不能为空");
        }
        if (phone.isEmpty()) {
            return ApiResponse.badRequest("联系电话不能为空");
        }
        AdminInfo next = new AdminInfo();
        next.setId(adminId);
        next.setShopName(shopName);
        next.setContactName(contactName);
        next.setPhone(phone);
        next.setAddress(address);
        int updated = adminMapper.updateShopProfile(next);
        if (updated <= 0) {
            return ApiResponse.badRequest("保存失败，请稍后重试");
        }
        return ApiResponse.success("保存成功", adminMapper.selectById(adminId));
    }

    @Override
    public ApiResponse<?> getPlanRuleConfig() {
        return ApiResponse.success("查询成功", planRuleConfigMapper.selectAll());
    }

    @Override
    public ApiResponse<?> savePlanRuleConfig(Map<String, String> config) {
        if (config == null || config.isEmpty()) {
            return ApiResponse.badRequest("规则配置不能为空");
        }
        for (Map.Entry<String, String> entry : config.entrySet()) {
            String key = trim(entry.getKey());
            if (key.isEmpty()) continue;
            planRuleConfigMapper.upsert(key, trim(entry.getValue()));
        }
        return ApiResponse.success("保存成功", planRuleConfigMapper.selectAll());
    }

    @Override
    public ApiResponse<?> getSeasonalConfig() {
        return ApiResponse.success("查询成功", seasonalConfigMapper.selectAll());
    }

    @Override
    public ApiResponse<?> saveSeasonalConfig(Map<String, String> config) {
        if (config == null || config.isEmpty()) {
            return ApiResponse.badRequest("当季配置不能为空");
        }
        for (Map.Entry<String, String> entry : config.entrySet()) {
            String key = trim(entry.getKey());
            if (key.isEmpty()) continue;
            seasonalConfigMapper.upsert(key, trim(entry.getValue()));
        }
        return ApiResponse.success("保存成功", seasonalConfigMapper.selectAll());
    }

    @Override
    public ApiResponse<?> getPackPricingRules() {
        List<Map<String, Object>> rows = seasonalConfigMapper.selectAll();
        List<Map<String, Object>> data = new ArrayList<>();
        if (rows != null) {
            for (Map<String, Object> row : rows) {
                String key = row.get("configKey") == null ? "" : String.valueOf(row.get("configKey")).trim();
                if (!key.startsWith("pack.")) continue;
                Map<String, Object> item = new HashMap<>();
                item.put("ruleKey", key);
                item.put("ruleValue", row.get("configValue") == null ? "" : String.valueOf(row.get("configValue")));
                item.put("description", adminConfigHelper.resolvePackPricingDescription(key));
                data.add(item);
            }
        }
        return ApiResponse.success("查询成功", data);
    }

    @Override
    public ApiResponse<?> savePackPricingRules(Map<String, String> config) {
        if (config == null || config.isEmpty()) {
            return ApiResponse.badRequest("套餐优惠配置不能为空");
        }
        for (Map.Entry<String, String> entry : config.entrySet()) {
            String key = trim(entry.getKey());
            if (key.isEmpty()) continue;
            seasonalConfigMapper.upsert(key, trim(entry.getValue()));
        }
        return getPackPricingRules();
    }

    private String trim(String text) {
        return text == null ? "" : text.trim();
    }

    private Integer defaultInt(Integer value) {
        return value == null ? 0 : value;
    }

    private Integer defaultFlag(Integer value) {
        return value == null ? 0 : value;
    }

    private String defaultText(String value, String defaultValue) {
        String safe = trim(value);
        return safe.isEmpty() ? defaultValue : safe;
    }

    private LocalDateTime parseDateTime(String value) {
        String safe = trim(value);
        if (safe.isEmpty()) {
            return null;
        }
        return LocalDateTime.parse(safe, DATE_TIME_FORMATTER);
    }

    private LocalDate parseDate(String value) {
        String safe = trim(value);
        if (safe.isEmpty()) {
            return null;
        }
        return LocalDate.parse(safe);
    }

    private void syncStructuredGoodsTags(Long goodsId, List<Long> tagIds) {
        if (goodsId == null) {
            return;
        }
        if (tagIds == null) {
            return;
        }
        goodsTagMapper.deleteStructuredTagsByGoodsId(goodsId);
        if (tagIds.isEmpty()) {
            return;
        }
        for (Long tagId : new ArrayList<>(tagIds)) {
            if (tagId == null || tagId <= 0) continue;
            goodsTagMapper.insertGoodsTag(goodsId, tagId);
        }
    }

}
