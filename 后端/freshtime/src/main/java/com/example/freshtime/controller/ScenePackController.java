package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
import com.example.freshtime.service.ScenePackService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/scene-pack")
@CrossOrigin(origins = "*")
public class ScenePackController {

    @Autowired
    private ScenePackService scenePackService;

    @GetMapping("/list")
    public ApiResponse<?> list(@RequestParam String scene) {
        return scenePackService.listByScene(scene);
    }

    @PostMapping("/add-cart")
    public ApiResponse<?> addCart(@RequestParam(required = false) Long userId, @RequestParam Long packId) {
        Long authUserId = AuthContext.getUserId();
        Long finalUserId = authUserId != null ? authUserId : userId;
        return scenePackService.addPackToCart(finalUserId, packId);
    }
}

