package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SaveUserSettingsRequest;
import com.example.freshtime.service.SettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/settings")
@CrossOrigin(origins = "*")
public class SettingsController {

    @Autowired
    private SettingsService settingsService;

    @GetMapping("/detail")
    public ApiResponse<?> detail(@RequestParam Long userId) {
        return settingsService.getByUserId(userId);
    }

    @PostMapping("/save")
    public ApiResponse<?> save(@RequestBody SaveUserSettingsRequest request) {
        return settingsService.save(request);
    }
}
