package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.AddPlanToCartRequest;
import com.example.freshtime.dto.GenerateComboPlanRequest;
import com.example.freshtime.dto.GenerateMealPlanRequest;
import com.example.freshtime.dto.ReplacePlanItemRequest;

public interface PlanService {
    ApiResponse<?> generateMealPlan(Long userId, GenerateMealPlanRequest request);

    ApiResponse<?> generateComboPlan(Long userId, GenerateComboPlanRequest request);

    ApiResponse<?> replacePlanItem(Long userId, ReplacePlanItemRequest request);

    ApiResponse<?> addPlanToCart(Long userId, AddPlanToCartRequest request);
}
