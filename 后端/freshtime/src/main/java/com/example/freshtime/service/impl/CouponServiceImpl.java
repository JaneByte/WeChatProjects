package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.CouponInfo;
import com.example.freshtime.entity.UserInfo;
import com.example.freshtime.mapper.CouponMapper;
import com.example.freshtime.mapper.UserMapper;
import com.example.freshtime.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CouponServiceImpl implements CouponService {

    @Autowired
    private CouponMapper couponMapper;

    @Autowired
    private UserMapper userMapper;

    @Value("${spring.datasource.url:}")
    private String datasourceUrl;

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
    public ApiResponse<?> grantDefaultCoupons(Long userId) {
        if (datasourceUrl == null || !datasourceUrl.contains("localhost")) {
            return ApiResponse.forbidden("仅开发环境可发放测试优惠券");
        }
        List<UserInfo> users = new ArrayList<>();
        if (userId != null) {
            UserInfo one = userMapper.selectById(userId);
            if (one == null) {
                return ApiResponse.notFound("用户不存在");
            }
            users.add(one);
        } else {
            users = userMapper.selectAllUsers();
        }
        if (users.isEmpty()) {
            return ApiResponse.success("暂无可发放用户", null);
        }

        LocalDate expireDate = LocalDate.of(2026, 12, 31);
        int granted = 0;
        for (UserInfo user : users) {
            granted += tryGrant(user.getId(), "满50减8", "全场可用", new BigDecimal("50.00"), new BigDecimal("8.00"), expireDate);
            granted += tryGrant(user.getId(), "满99减15", "生鲜专区", new BigDecimal("99.00"), new BigDecimal("15.00"), expireDate);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("userCount", users.size());
        data.put("grantedCount", granted);
        return ApiResponse.success("测试优惠券发放完成", data);
    }

    private int tryGrant(Long userId, String title, String conditionText, BigDecimal threshold, BigDecimal discount, LocalDate expireDate) {
        CouponInfo exists = couponMapper.selectActiveByUserIdAndTitle(userId, title, expireDate);
        if (exists != null) {
            return 0;
        }
        CouponInfo row = new CouponInfo();
        row.setUserId(userId);
        row.setTitle(title);
        row.setConditionText(conditionText);
        row.setThresholdAmount(threshold);
        row.setDiscountAmount(discount);
        row.setExpireDate(expireDate);
        row.setStatus(1);
        return couponMapper.insertCoupon(row);
    }
}
