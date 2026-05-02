package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SaveUserSettingsRequest;
import com.example.freshtime.entity.UserSettingInfo;
import com.example.freshtime.mapper.SettingsMapper;
import com.example.freshtime.service.SettingsService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
public class SettingsServiceImpl implements SettingsService {

    @Autowired
    private SettingsMapper settingsMapper;

    @Override
    public ApiResponse<?> getByUserId(Long userId) {
        if (userId == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        UserSettingInfo settings = settingsMapper.selectByUserId(userId);
        if (settings == null) {
            settings = new UserSettingInfo();
            settings.setUserId(userId);
            settings.setNotifyOrder(1);
            settings.setNotifyPromo(0);
            settingsMapper.insert(settings);
            settings = settingsMapper.selectByUserId(userId);
        }
        Map<String, Object> data = new HashMap<>();
        data.put("notifyOrder", settings.getNotifyOrder() != null && settings.getNotifyOrder() == 1);
        data.put("notifyPromo", settings.getNotifyPromo() != null && settings.getNotifyPromo() == 1);
        return ApiResponse.success(data);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> save(SaveUserSettingsRequest request) {
        if (request == null || request.getUserId() == null) {
            return ApiResponse.badRequest("userId不能为空");
        }
        UserSettingInfo settings = settingsMapper.selectByUserId(request.getUserId());
        int notifyOrder = Boolean.TRUE.equals(request.getNotifyOrder()) ? 1 : 0;
        int notifyPromo = Boolean.TRUE.equals(request.getNotifyPromo()) ? 1 : 0;

        if (settings == null) {
            settings = new UserSettingInfo();
            settings.setUserId(request.getUserId());
            settings.setNotifyOrder(notifyOrder);
            settings.setNotifyPromo(notifyPromo);
            settingsMapper.insert(settings);
        } else {
            settings.setNotifyOrder(notifyOrder);
            settings.setNotifyPromo(notifyPromo);
            settingsMapper.updateByUserId(settings);
        }
        return ApiResponse.success("保存成功", null);
    }
}
