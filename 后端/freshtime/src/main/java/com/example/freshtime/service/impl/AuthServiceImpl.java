package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.LoginRequest;
import com.example.freshtime.entity.UserInfo;
import com.example.freshtime.mapper.UserMapper;
import com.example.freshtime.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@Service
public class AuthServiceImpl implements AuthService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public ApiResponse<?> login(LoginRequest request) {
        if (request == null) {
            return ApiResponse.badRequest("登录参数不能为空");
        }

        String openid = safeText(request.getOpenid());
        if (openid.isEmpty()) {
            openid = "dev_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12);
        }
        String nickname = safeText(request.getNickname());
        if (nickname.isEmpty()) {
            nickname = "新用户";
        }

        UserInfo user = userMapper.selectByOpenid(openid);
        if (user == null) {
            user = new UserInfo();
            user.setOpenid(openid);
            user.setNickname(nickname);
            userMapper.insertUser(user);
            user = userMapper.selectById(user.getId());
        } else if (!nickname.equals(user.getNickname())) {
            user.setNickname(nickname);
            userMapper.updateNickname(user);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("userId", user.getId());
        data.put("nickname", user.getNickname());
        data.put("openid", user.getOpenid());
        return ApiResponse.success("登录成功", data);
    }

    private String safeText(String raw) {
        return raw == null ? "" : raw.trim();
    }
}
