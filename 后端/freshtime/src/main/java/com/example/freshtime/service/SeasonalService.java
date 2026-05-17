package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.UpdateSeasonalConfigRequest;

public interface SeasonalService {

    /**
     * 获取当季精选列表
     */
    ApiResponse<?> list(Integer limit, String season, String region, String budgetLevel, String sortBy, String produceType, Boolean strictTag);

    /**
     * 刷新当季精选（开发模式手动触发）
     */
    ApiResponse<?> refresh(Integer limit, String season, String region, String budgetLevel, String sortBy, String produceType, Boolean strictTag);

    /**
     * 获取当季精选运营配置
     */
    ApiResponse<?> getConfig();

    /**
     * 更新当季精选运营配置
     */
    ApiResponse<?> updateConfig(UpdateSeasonalConfigRequest request);
}
