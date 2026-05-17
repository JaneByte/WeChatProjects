package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
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
    public ApiResponse<?> list(@RequestParam(required = false) Long userId) {
        return cartService.getCartList(resolveUserId(userId));
    }

    @PostMapping("/add")
    public ApiResponse<?> add(
            @RequestParam(required = false) Long userId,
            @RequestParam Long goodsId,
            @RequestParam(required = false) Long skuId,
            @RequestParam(defaultValue = "1") Integer quantity,
            @RequestParam(required = false) String sourceType,
            @RequestParam(required = false) Long sourcePlanId,
            @RequestParam(required = false) String sourceScene) {
        return cartService.addToCart(resolveUserId(userId), goodsId, skuId, quantity, sourceType, sourcePlanId, sourceScene);
    }

    @PostMapping("/quantity")
    public ApiResponse<?> quantity(
            @RequestParam(required = false) Long userId,
            @RequestParam Long goodsId,
            @RequestParam(required = false) Long skuId,
            @RequestParam Integer quantity) {
        return cartService.updateQuantity(resolveUserId(userId), goodsId, skuId, quantity);
    }

    @PostMapping("/select")
    public ApiResponse<?> select(
            @RequestParam(required = false) Long userId,
            @RequestParam Long goodsId,
            @RequestParam(required = false) Long skuId,
            @RequestParam Integer selected) {
        return cartService.updateSelected(resolveUserId(userId), goodsId, skuId, selected);
    }

    @PostMapping("/select-all")
    public ApiResponse<?> selectAll(
            @RequestParam(required = false) Long userId,
            @RequestParam Integer selected) {
        return cartService.updateSelectedAll(resolveUserId(userId), selected);
    }

    @PostMapping("/delete")
    public ApiResponse<?> delete(
            @RequestParam(required = false) Long userId,
            @RequestParam Long goodsId,
            @RequestParam(required = false) Long skuId) {
        return cartService.deleteItem(resolveUserId(userId), goodsId, skuId);
    }

    @PostMapping("/delete-selected")
    public ApiResponse<?> deleteSelected(@RequestParam(required = false) Long userId) {
        return cartService.deleteSelected(resolveUserId(userId));
    }

    private Long resolveUserId(Long userId) {
        Long authUserId = AuthContext.getUserId();
        return authUserId != null ? authUserId : userId;
    }
}
