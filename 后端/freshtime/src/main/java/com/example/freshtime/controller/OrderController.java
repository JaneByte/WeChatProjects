package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
import com.example.freshtime.dto.MockPayConfirmRequest;
import com.example.freshtime.dto.SubmitOrderRequest;
import com.example.freshtime.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/order")
@CrossOrigin(origins = "*")
public class OrderController {

    @Autowired
    private OrderService orderService;

    @PostMapping("/submit")
    public ApiResponse<?> submitOrder(@RequestBody SubmitOrderRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("请求参数不能为空");
        }
        request.setUserId(resolveUserId(request == null ? null : request.getUserId()));
        return orderService.submitOrder(request);
    }

    @GetMapping("/list")
    public ApiResponse<?> getOrderList(
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "20") Integer limit,
            @RequestParam(required = false) Integer status) {
        return orderService.getOrderList(resolveUserId(userId), limit, status);
    }

    @GetMapping("/detail")
    public ApiResponse<?> getOrderDetail(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.getOrderDetail(resolveUserId(userId), orderId);
    }

    @PostMapping("/cancel")
    public ApiResponse<?> cancelOrder(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.cancelOrder(resolveUserId(userId), orderId);
    }

    @PostMapping("/finish")
    public ApiResponse<?> finishOrder(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.finishOrder(resolveUserId(userId), orderId);
    }

    @PostMapping("/pay")
    public ApiResponse<?> payOrder(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.payOrder(resolveUserId(userId), orderId);
    }

    @PostMapping("/pay/mock-create")
    public ApiResponse<?> mockCreate(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.mockPayCreate(resolveUserId(userId), orderId);
    }

    @PostMapping("/pay/mock-confirm")
    public ApiResponse<?> mockConfirm(@RequestBody MockPayConfirmRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("支付确认参数不能为空");
        }
        request.setUserId(resolveUserId(request == null ? null : request.getUserId()));
        return orderService.mockPayConfirm(request);
    }

    @PostMapping("/expire")
    public ApiResponse<?> expireOrder(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.expireOrder(resolveUserId(userId), orderId);
    }

    @PostMapping("/deliver")
    public ApiResponse<?> deliverOrder(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.deliverOrder(resolveUserId(userId), orderId);
    }

    @PostMapping("/refund/apply")
    public ApiResponse<?> applyRefund(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.applyRefund(resolveUserId(userId), orderId);
    }

    @PostMapping("/refund/finish")
    public ApiResponse<?> finishRefund(
            @RequestParam(required = false) Long userId,
            @RequestParam Long orderId) {
        return orderService.finishRefund(resolveUserId(userId), orderId);
    }

    private Long resolveUserId(Long userId) {
        Long authUserId = AuthContext.getUserId();
        return authUserId != null ? authUserId : userId;
    }
}
