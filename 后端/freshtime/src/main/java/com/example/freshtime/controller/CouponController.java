package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
import com.example.freshtime.service.CouponService;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/coupon")
@CrossOrigin(origins = "*")
public class CouponController {

    @Autowired
    private CouponService couponService;

    @GetMapping("/list")
    public ApiResponse<?> list(@RequestParam(required = false) Long userId) {
        return couponService.list(resolveUserId(userId));
    }

    @GetMapping("/available")
    public ApiResponse<?> available(@RequestParam(required = false) Long userId) {
        return couponService.listAvailable(resolveUserId(userId));
    }

    @PostMapping("/claim")
    public ApiResponse<?> claim(@RequestParam(required = false) Long userId,
                                @RequestParam(required = false) Long couponId,
                                @RequestBody(required = false) ClaimCouponRequest body) {
        Long finalCouponId = couponId;
        if (finalCouponId == null && body != null) {
            finalCouponId = body.getCouponId();
        }
        return couponService.claim(resolveUserId(userId), finalCouponId);
    }

    private Long resolveUserId(Long userId) {
        Long authUserId = AuthContext.getUserId();
        return authUserId != null ? authUserId : userId;
    }

    @Data
    private static class ClaimCouponRequest {
        private Long couponId;
    }
}
