package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.LoginRequest;

public interface AuthService {
    ApiResponse<?> login(LoginRequest request);
}
