package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AdminTokenUtil;
import com.example.freshtime.dto.admin.AdminLoginRequest;
import com.example.freshtime.entity.AdminInfo;
import com.example.freshtime.mapper.AdminMapper;
import com.example.freshtime.service.AdminAuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

@Service
public class AdminAuthServiceImpl implements AdminAuthService {

    @Autowired
    private AdminMapper adminMapper;

    @Autowired
    private AdminTokenUtil adminTokenUtil;

    @Override
    public ApiResponse<?> login(AdminLoginRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("登录参数不能为空");
        }
        String username = trim(request.getUsername());
        String password = trim(request.getPassword());
        if (username.isEmpty() || password.isEmpty()) {
            return ApiResponse.badRequest("账号和密码不能为空");
        }
        AdminInfo adminInfo = adminMapper.selectByUsername(username);
        if (adminInfo == null) {
            return ApiResponse.notFound("店铺账号不存在");
        }
        if (adminInfo.getStatus() == null || adminInfo.getStatus() != 1) {
            return ApiResponse.forbidden("店铺账号不可用");
        }
        if (!password.equals(trim(adminInfo.getPassword()))) {
            return ApiResponse.badRequest("账号或密码错误");
        }
        Map<String, Object> data = new HashMap<>();
        data.put("adminId", adminInfo.getId());
        data.put("username", adminInfo.getUsername());
        data.put("nickname", adminInfo.getNickname());
        data.put("shopName", adminInfo.getShopName());
        data.put("token", adminTokenUtil.generateToken(adminInfo));
        data.put("tokenExpireAt", adminTokenUtil.getExpireAtMillis());
        return ApiResponse.success("登录成功", data);
    }

    private String trim(String text) {
        return text == null ? "" : text.trim();
    }
}
