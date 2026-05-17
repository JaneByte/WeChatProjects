package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.admin.AdminCategorySaveRequest;
import com.example.freshtime.dto.admin.AdminCouponSaveRequest;
import com.example.freshtime.dto.admin.AdminGoodsSaveRequest;
import com.example.freshtime.entity.Category;
import com.example.freshtime.entity.CouponInfo;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import com.example.freshtime.entity.UserInfo;
import com.example.freshtime.mapper.CategoryMapper;
import com.example.freshtime.mapper.CouponMapper;
import com.example.freshtime.mapper.FlashPoolMapper;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.GoodsTagMapper;
import com.example.freshtime.mapper.OrderMapper;
import com.example.freshtime.mapper.PackPricingRuleMapper;
import com.example.freshtime.mapper.PlanRuleConfigMapper;
import com.example.freshtime.mapper.SeasonalConfigMapper;
import com.example.freshtime.mapper.TagMapper;
import com.example.freshtime.mapper.UserMapper;
import com.example.freshtime.service.AdminService;
import com.example.freshtime.vo.admin.AdminDashboardOverviewVO;
import com.example.freshtime.vo.admin.AdminOrderDetailVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import java.util.ArrayList;

@Service
public class AdminServiceImpl implements AdminService {
    private static final DateTimeFormatter DATE_TIME_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");

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
    private FlashPoolMapper flashPoolMapper;

    @Autowired
    private TagMapper tagMapper;

    @Autowired
    private GoodsTagMapper goodsTagMapper;

    @Autowired
    private PlanRuleConfigMapper planRuleConfigMapper;

    @Autowired
    private SeasonalConfigMapper seasonalConfigMapper;

    @Autowired
    private PackPricingRuleMapper packPricingRuleMapper;

    @Override
    public ApiResponse<?> getDashboardOverview() {
        AdminDashboardOverviewVO overview = new AdminDashboardOverviewVO();
        overview.setGoodsCount(defaultInt(goodsMapper.countAllGoods()));
        overview.setOnSaleGoodsCount(defaultInt(goodsMapper.countOnSaleGoods()));
        overview.setUserCount(defaultInt(userMapper.countAllUsers()));
        overview.setEnabledUserCount(defaultInt(userMapper.countEnabledUsers()));
        overview.setOrderCount(defaultInt(orderMapper.countAllOrders()));
        overview.setPendingDeliveryOrderCount(defaultInt(orderMapper.countPendingDeliveryOrders()));
        overview.setTotalSalesAmount(defaultAmount(orderMapper.sumPaidActualAmount()));
        overview.setMealOrderCount(defaultInt(orderMapper.countOrdersBySource(OrderInfo.ORDER_SOURCE_MEAL)));
        overview.setComboOrderCount(defaultInt(orderMapper.countOrdersBySource(OrderInfo.ORDER_SOURCE_COMBO)));
        overview.setSeasonalOrderCount(defaultInt(orderMapper.countOrdersBySource(OrderInfo.ORDER_SOURCE_SEASONAL)));
        overview.setMixedOrderCount(defaultInt(orderMapper.countOrdersBySource(OrderInfo.ORDER_SOURCE_MIXED)));
        return ApiResponse.success("查询成功", overview);
    }

    @Override
    public ApiResponse<?> getGoodsList(String keyword, Integer status, Long categoryId) {
        return ApiResponse.success("查询成功", goodsMapper.selectAdminGoodsList(trim(keyword), status, categoryId));
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

        Goods goods = new Goods();
        goods.setId(request.getId());
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

        if (goods.getId() == null) {
          goodsMapper.insertGoods(goods);
        } else {
          Goods current = goodsMapper.selectById(goods.getId());
          if (current == null) {
              return ApiResponse.notFound("商品不存在");
          }
          goods.setSalesVolume(current.getSalesVolume());
          goods.setCreateTime(current.getCreateTime());
          goodsMapper.updateGoods(goods);
        }
        syncStructuredGoodsTags(goods.getId(), request.getTagIds());
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
        category.setIcon(trim(request.getIcon()));
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
        orderMapper.updateOrderStatusDirect(orderId, status);
        return ApiResponse.success("更新成功", orderMapper.selectOrderById(orderId));
    }

    @Override
    public ApiResponse<?> getUserList(Integer status, String keyword) {
        return ApiResponse.success("查询成功", userMapper.selectAdminUserList(status, trim(keyword)));
    }

    @Override
    public ApiResponse<?> updateUserStatus(Long userId, Integer status) {
        if (userId == null || status == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        UserInfo user = userMapper.selectById(userId);
        if (user == null) {
            return ApiResponse.notFound("用户不存在");
        }
        userMapper.updateUserStatus(userId, status);
        return ApiResponse.success("更新成功", userMapper.selectById(userId));
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
        return ApiResponse.success("查询成功", packPricingRuleMapper.selectAll());
    }

    @Override
    public ApiResponse<?> savePackPricingRules(Map<String, String> config) {
        if (config == null || config.isEmpty()) {
            return ApiResponse.badRequest("套餐优惠配置不能为空");
        }
        for (Map.Entry<String, String> entry : config.entrySet()) {
            String key = trim(entry.getKey());
            if (key.isEmpty()) continue;
            packPricingRuleMapper.upsert(key, trim(entry.getValue()), resolvePackPricingDescription(key));
        }
        return ApiResponse.success("保存成功", packPricingRuleMapper.selectAll());
    }

    @Override
    public ApiResponse<?> refreshFlashPool(Integer targetCount) {
        int count = targetCount == null ? 18 : targetCount;
        if (count < 6) count = 6;
        if (count > 60) count = 60;
        flashPoolMapper.refreshFlashPool(count);
        Map<String, Object> data = new HashMap<>();
        data.put("targetCount", count);
        data.put("flashCount", defaultInt(goodsMapper.countFlashOnSaleGoods()));
        data.put("invalidFlashCount", defaultInt(flashPoolMapper.countInvalidFlashGoods()));
        data.put("preview", goodsMapper.selectFlashGoodsLimit(20));
        return ApiResponse.success("秒杀池刷新成功", data);
    }

    @Override
    public ApiResponse<?> getFlashOverview(Integer previewLimit) {
        int limit = previewLimit == null ? 20 : previewLimit;
        if (limit < 5) limit = 5;
        if (limit > 100) limit = 100;
        Map<String, Object> data = new HashMap<>();
        data.put("flashCount", defaultInt(goodsMapper.countFlashOnSaleGoods()));
        data.put("invalidFlashCount", defaultInt(flashPoolMapper.countInvalidFlashGoods()));
        data.put("preview", goodsMapper.selectFlashGoodsLimit(limit));
        return ApiResponse.success("查询成功", data);
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

    private BigDecimal defaultAmount(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
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

    private String resolvePackPricingDescription(String ruleKey) {
        if (ruleKey.startsWith("pack.combo.")) {
            if (ruleKey.endsWith("discount_rate")) return "蔬果搭配基础折扣率";
            if (ruleKey.endsWith("min_discount")) return "蔬果搭配最低优惠额";
            if (ruleKey.endsWith("max_discount")) return "蔬果搭配最高优惠额";
        }
        if (ruleKey.startsWith("pack.meal.")) {
            if (ruleKey.endsWith("discount_rate")) return "一人食基础折扣率";
            if (ruleKey.endsWith("min_discount")) return "一人食最低优惠额";
            if (ruleKey.endsWith("max_discount")) return "一人食最高优惠额";
        }
        return "套餐优惠配置";
    }

    private void syncStructuredGoodsTags(Long goodsId, List<Long> tagIds) {
        if (goodsId == null) {
            return;
        }
        goodsTagMapper.deleteStructuredTagsByGoodsId(goodsId);
        if (tagIds == null || tagIds.isEmpty()) {
            return;
        }
        for (Long tagId : new ArrayList<>(tagIds)) {
            if (tagId == null || tagId <= 0) continue;
            goodsTagMapper.insertGoodsTag(goodsId, tagId);
        }
    }
}
