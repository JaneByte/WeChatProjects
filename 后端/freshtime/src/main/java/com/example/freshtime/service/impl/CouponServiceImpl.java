package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.CouponInfo;
import com.example.freshtime.mapper.CouponMapper;
import com.example.freshtime.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CouponServiceImpl implements CouponService {

    @Autowired
    private CouponMapper couponMapper;

    @Override
    public ApiResponse<?> list(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        List<CouponInfo> source = couponMapper.selectActiveByUserId(userId);
        List<Map<String, Object>> list = new ArrayList<>();
        for (CouponInfo item : source) {
            Map<String, Object> row = new HashMap<>();
            row.put("id", item.getId());
            row.put("title", item.getTitle());
            row.put("condition", item.getConditionText());
            row.put("thresholdAmount", item.getThresholdAmount());
            row.put("discountAmount", item.getDiscountAmount());
            row.put("expireAt", item.getExpireDate());
            list.add(row);
        }
        return ApiResponse.success(list);
    }

    @Override
    public ApiResponse<?> listAvailable(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        List<CouponInfo> pool = couponMapper.selectCouponPool();
        List<Map<String, Object>> list = new ArrayList<>();
        for (CouponInfo item : pool) {
            CouponInfo owned = couponMapper.selectUserActiveByTitle(userId, item.getTitle());
            Map<String, Object> row = new HashMap<>();
            row.put("id", item.getId());
            row.put("title", item.getTitle());
            row.put("condition", item.getConditionText());
            row.put("thresholdAmount", item.getThresholdAmount());
            row.put("discountAmount", item.getDiscountAmount());
            row.put("expireAt", item.getExpireDate());
            row.put("claimed", owned != null);
            list.add(row);
        }
        return ApiResponse.success(list);
    }

    @Override
    public ApiResponse<?> claim(Long userId, Long couponId) {
        if (userId == null || couponId == null) {
            return ApiResponse.badRequest("userId和couponId不能为空");
        }
        List<CouponInfo> pool = couponMapper.selectCouponPool();
        CouponInfo target = null;
        for (CouponInfo item : pool) {
            if (couponId.equals(item.getId())) {
                target = item;
                break;
            }
        }
        if (target == null) {
            return ApiResponse.notFound("优惠券不存在或不可领取");
        }
        CouponInfo owned = couponMapper.selectUserActiveByTitle(userId, target.getTitle());
        if (owned != null) {
            return ApiResponse.fail(409, "该优惠券已领取");
        }
        CouponInfo row = new CouponInfo();
        row.setCouponId(target.getId());
        row.setUserId(userId);
        row.setTitle(target.getTitle());
        row.setConditionText(target.getConditionText());
        row.setThresholdAmount(target.getThresholdAmount());
        row.setDiscountAmount(target.getDiscountAmount());
        row.setExpireDate(target.getExpireDate());
        row.setStatus(1);
        couponMapper.insertCoupon(row);
        return ApiResponse.success("领取成功");
    }

}
