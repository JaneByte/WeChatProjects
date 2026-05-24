package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AdminContext;
import com.example.freshtime.dto.admin.AdminCategorySaveRequest;
import com.example.freshtime.dto.admin.AdminCouponSaveRequest;
import com.example.freshtime.dto.admin.AdminGoodsSaveRequest;
import com.example.freshtime.dto.admin.AdminShopProfileSaveRequest;
import com.example.freshtime.entity.AdminInfo;
import com.example.freshtime.mapper.AdminMapper;
import com.example.freshtime.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@CrossOrigin(origins = "*")
public class AdminController {

    @Autowired
    private AdminService adminService;

    @Autowired
    private AdminMapper adminMapper;

    @GetMapping("/session/me")
    public ApiResponse<?> getCurrentAdmin() {
        Long adminId = AdminContext.getAdminId();
        if (adminId == null) {
            return ApiResponse.unauthorized("请先登录");
        }
        AdminInfo adminInfo = adminMapper.selectById(adminId);
        if (adminInfo == null) {
            return ApiResponse.notFound("店铺账号不存在");
        }
        return ApiResponse.success("查询成功", adminInfo);
    }

    @PostMapping("/session/profile")
    public ApiResponse<?> saveShopProfile(@RequestBody AdminShopProfileSaveRequest request) {
        Long adminId = AdminContext.getAdminId();
        if (adminId == null) {
            return ApiResponse.unauthorized("请先登录");
        }
        return adminService.saveShopProfile(adminId, request);
    }

    @GetMapping("/dashboard/overview")
    public ApiResponse<?> getDashboardOverview() {
        return adminService.getDashboardOverview();
    }

    @GetMapping("/goods/list")
    public ApiResponse<?> getGoodsList(@RequestParam(required = false) String keyword,
                                       @RequestParam(required = false) Integer status,
                                       @RequestParam(required = false) Long categoryId) {
        return adminService.getGoodsList(keyword, status, categoryId);
    }

    @GetMapping("/tag/list")
    public ApiResponse<?> getTagList(@RequestParam(required = false) Boolean structuredOnly) {
        return adminService.getTagList(structuredOnly);
    }

    @GetMapping("/goods/tags")
    public ApiResponse<?> getGoodsTags(@RequestParam Long goodsId) {
        return adminService.getGoodsTags(goodsId);
    }

    @PostMapping("/goods/save")
    public ApiResponse<?> saveGoods(@RequestBody AdminGoodsSaveRequest request) {
        return adminService.saveGoods(request);
    }

    @PostMapping("/goods/status")
    public ApiResponse<?> updateGoodsStatus(@RequestParam Long id, @RequestParam Integer status) {
        return adminService.updateGoodsStatus(id, status);
    }

    @GetMapping("/category/list")
    public ApiResponse<?> getCategoryList() {
        return adminService.getCategoryList();
    }

    @PostMapping("/category/save")
    public ApiResponse<?> saveCategory(@RequestBody AdminCategorySaveRequest request) {
        return adminService.saveCategory(request);
    }

    @PostMapping("/category/status")
    public ApiResponse<?> updateCategoryStatus(@RequestParam Long id, @RequestParam Integer status) {
        return adminService.updateCategoryStatus(id, status);
    }

    @GetMapping("/order/list")
    public ApiResponse<?> getOrderList(@RequestParam(required = false) Integer status,
                                       @RequestParam(required = false) Long userId) {
        return adminService.getOrderList(status, userId);
    }

    @GetMapping("/order/detail")
    public ApiResponse<?> getOrderDetail(@RequestParam Long orderId) {
        return adminService.getOrderDetail(orderId);
    }

    @PostMapping("/order/status")
    public ApiResponse<?> updateOrderStatus(@RequestParam Long orderId, @RequestParam Integer status) {
        return adminService.updateOrderStatus(orderId, status);
    }

    @GetMapping("/coupon/list")
    public ApiResponse<?> getCouponList() {
        return adminService.getCouponList();
    }

    @PostMapping("/coupon/save")
    public ApiResponse<?> saveCoupon(@RequestBody AdminCouponSaveRequest request) {
        return adminService.saveCoupon(request);
    }

    @PostMapping("/coupon/status")
    public ApiResponse<?> updateCouponStatus(@RequestParam Long id, @RequestParam Integer status) {
        return adminService.updateCouponStatus(id, status);
    }

    @GetMapping("/plan-rules")
    public ApiResponse<?> getPlanRuleConfig() {
        return adminService.getPlanRuleConfig();
    }

    @PostMapping("/plan-rules/save")
    public ApiResponse<?> savePlanRuleConfig(@RequestBody Map<String, String> config) {
        return adminService.savePlanRuleConfig(config);
    }

    @GetMapping("/seasonal-config")
    public ApiResponse<?> getSeasonalConfig() {
        return adminService.getSeasonalConfig();
    }

    @PostMapping("/seasonal-config/save")
    public ApiResponse<?> saveSeasonalConfig(@RequestBody Map<String, String> config) {
        return adminService.saveSeasonalConfig(config);
    }

    @GetMapping("/pack-pricing-rules")
    public ApiResponse<?> getPackPricingRules() {
        return adminService.getPackPricingRules();
    }

    @PostMapping("/pack-pricing-rules/save")
    public ApiResponse<?> savePackPricingRules(@RequestBody Map<String, String> config) {
        return adminService.savePackPricingRules(config);
    }

}
