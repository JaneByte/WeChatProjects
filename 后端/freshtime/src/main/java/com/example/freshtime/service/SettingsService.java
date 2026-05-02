package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SaveUserSettingsRequest;

public interface SettingsService {
    ApiResponse<?> getByUserId(Long userId);
    ApiResponse<?> save(SaveUserSettingsRequest request);
}
