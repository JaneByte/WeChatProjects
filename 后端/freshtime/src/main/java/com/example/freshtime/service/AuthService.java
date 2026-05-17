package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.LoginRequest;
import com.example.freshtime.dto.UserProfileUpdateRequest;

public interface AuthService {
    ApiResponse<?> login(LoginRequest request);

    ApiResponse<?> updateProfile(UserProfileUpdateRequest request);
}
