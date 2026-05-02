package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.CouponService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
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
    public ApiResponse<?> list(@RequestParam Long userId) {
        return couponService.list(userId);
    }

    @org.springframework.web.bind.annotation.PostMapping("/dev/grant-default")
    public ApiResponse<?> grantDefault(@RequestParam(required = false) Long userId) {
        return couponService.grantDefaultCoupons(userId);
    }
}
