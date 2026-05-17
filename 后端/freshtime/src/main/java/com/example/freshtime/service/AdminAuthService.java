package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.admin.AdminLoginRequest;

public interface AdminAuthService {
    ApiResponse<?> login(AdminLoginRequest request);
}
