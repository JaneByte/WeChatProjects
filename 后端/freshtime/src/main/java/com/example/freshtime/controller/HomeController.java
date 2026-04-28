package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/home")
@CrossOrigin(origins = "*")
public class HomeController {

    @Autowired
    private HomeService homeService;

    @GetMapping("/index")
    public ApiResponse<?> getHomeIndex() {
        return homeService.getHomeIndex();
    }

    @GetMapping("/goods")
    public ApiResponse<?> getHomeGoods(
            @RequestParam(defaultValue = "1") Integer page,
            @RequestParam(defaultValue = "10") Integer pageSize) {
        return homeService.getHomeGoods(page, pageSize);
    }
}
