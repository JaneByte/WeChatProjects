package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
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
        return orderService.submitOrder(request);
    }

    @GetMapping("/list")
    public ApiResponse<?> getOrderList(
            @RequestParam Long userId,
            @RequestParam(defaultValue = "20") Integer limit,
            @RequestParam(required = false) Integer status) {
        return orderService.getOrderList(userId, limit, status);
    }

    @PostMapping("/cancel")
    public ApiResponse<?> cancelOrder(
            @RequestParam Long userId,
            @RequestParam Long orderId) {
        return orderService.cancelOrder(userId, orderId);
    }

    @PostMapping("/finish")
    public ApiResponse<?> finishOrder(
            @RequestParam Long userId,
            @RequestParam Long orderId) {
        return orderService.finishOrder(userId, orderId);
    }

    @PostMapping("/pay")
    public ApiResponse<?> payOrder(
            @RequestParam Long userId,
            @RequestParam Long orderId) {
        return orderService.payOrder(userId, orderId);
    }

    @PostMapping("/expire")
    public ApiResponse<?> expireOrder(
            @RequestParam Long userId,
            @RequestParam Long orderId) {
        return orderService.expireOrder(userId, orderId);
    }

    @PostMapping("/deliver")
    public ApiResponse<?> deliverOrder(
            @RequestParam Long userId,
            @RequestParam Long orderId) {
        return orderService.deliverOrder(userId, orderId);
    }
}
