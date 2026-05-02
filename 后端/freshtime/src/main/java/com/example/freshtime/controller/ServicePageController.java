package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.ServicePageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/service")
@CrossOrigin(origins = "*")
public class ServicePageController {

    @Autowired
    private ServicePageService servicePageService;

    @GetMapping("/info")
    public ApiResponse<?> info() {
        return servicePageService.getPageData();
    }
}
