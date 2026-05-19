package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.admin.AdminCategorySaveRequest;
import com.example.freshtime.dto.admin.AdminCouponSaveRequest;
import com.example.freshtime.dto.admin.AdminGoodsSaveRequest;
import com.example.freshtime.dto.admin.AdminShopProfileSaveRequest;

public interface AdminService {
    ApiResponse<?> getDashboardOverview();

    ApiResponse<?> getGoodsList(String keyword, Integer status, Long categoryId);

    ApiResponse<?> getTagList(Boolean structuredOnly);

    ApiResponse<?> getGoodsTags(Long goodsId);

    ApiResponse<?> saveGoods(AdminGoodsSaveRequest request);

    ApiResponse<?> updateGoodsStatus(Long id, Integer status);

    ApiResponse<?> getCategoryList();

    ApiResponse<?> saveCategory(AdminCategorySaveRequest request);

    ApiResponse<?> updateCategoryStatus(Long id, Integer status);

    ApiResponse<?> getOrderList(Integer status, Long userId);

    ApiResponse<?> getOrderDetail(Long orderId);

    ApiResponse<?> updateOrderStatus(Long orderId, Integer status);

    ApiResponse<?> getUserList(Integer status, String keyword);

    ApiResponse<?> updateUserStatus(Long userId, Integer status);

    ApiResponse<?> getCouponList();

    ApiResponse<?> saveCoupon(AdminCouponSaveRequest request);

    ApiResponse<?> updateCouponStatus(Long id, Integer status);

    ApiResponse<?> saveShopProfile(Long adminId, AdminShopProfileSaveRequest request);

    ApiResponse<?> getPlanRuleConfig();

    ApiResponse<?> savePlanRuleConfig(java.util.Map<String, String> config);

    ApiResponse<?> getSeasonalConfig();

    ApiResponse<?> saveSeasonalConfig(java.util.Map<String, String> config);

    ApiResponse<?> getPackPricingRules();

    ApiResponse<?> savePackPricingRules(java.util.Map<String, String> config);

    ApiResponse<?> refreshFlashPool(Integer targetCount);

    ApiResponse<?> getFlashOverview(Integer previewLimit);

    ApiResponse<?> cleanupSourceSceneData();

    ApiResponse<?> backfillHistoricalOrderSources();
}
