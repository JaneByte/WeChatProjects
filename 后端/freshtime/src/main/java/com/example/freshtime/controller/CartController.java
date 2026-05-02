package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.CartService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    @Autowired
    private CartService cartService;

    @GetMapping("/list")
    public ApiResponse<?> list(@RequestParam Long userId) {
        return cartService.getCartList(userId);
    }

    @PostMapping("/add")
    public ApiResponse<?> add(
            @RequestParam Long userId,
            @RequestParam Long goodsId,
            @RequestParam(defaultValue = "1") Integer quantity) {
        return cartService.addToCart(userId, goodsId, quantity);
    }

    @PostMapping("/quantity")
    public ApiResponse<?> quantity(
            @RequestParam Long userId,
            @RequestParam Long goodsId,
            @RequestParam Integer quantity) {
        return cartService.updateQuantity(userId, goodsId, quantity);
    }

    @PostMapping("/select")
    public ApiResponse<?> select(
            @RequestParam Long userId,
            @RequestParam Long goodsId,
            @RequestParam Integer selected) {
        return cartService.updateSelected(userId, goodsId, selected);
    }

    @PostMapping("/select-all")
    public ApiResponse<?> selectAll(
            @RequestParam Long userId,
            @RequestParam Integer selected) {
        return cartService.updateSelectedAll(userId, selected);
    }

    @PostMapping("/delete")
    public ApiResponse<?> delete(
            @RequestParam Long userId,
            @RequestParam Long goodsId) {
        return cartService.deleteItem(userId, goodsId);
    }

    @PostMapping("/delete-selected")
    public ApiResponse<?> deleteSelected(@RequestParam Long userId) {
        return cartService.deleteSelected(userId);
    }
}

