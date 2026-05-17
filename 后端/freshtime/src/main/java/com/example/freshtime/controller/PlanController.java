package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.common.AuthContext;
import com.example.freshtime.dto.AddPlanToCartRequest;
import com.example.freshtime.dto.GenerateComboPlanRequest;
import com.example.freshtime.dto.GenerateMealPlanRequest;
import com.example.freshtime.dto.ReplacePlanItemRequest;
import com.example.freshtime.service.PlanService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class PlanController {

    @Autowired
    private PlanService planService;

    @PostMapping("/meal-plan/generate")
    public ApiResponse<?> generateMealPlan(@RequestBody(required = false) GenerateMealPlanRequest request) {
        return planService.generateMealPlan(AuthContext.getUserId(), request);
    }

    @PostMapping("/combo-plan/generate")
    public ApiResponse<?> generateComboPlan(@RequestBody(required = false) GenerateComboPlanRequest request) {
        return planService.generateComboPlan(AuthContext.getUserId(), request);
    }

    @PostMapping("/plan/item/replace")
    public ApiResponse<?> replacePlanItem(@RequestBody(required = false) ReplacePlanItemRequest request) {
        return planService.replacePlanItem(AuthContext.getUserId(), request);
    }

    @PostMapping("/plan/add-cart")
    public ApiResponse<?> addPlanToCart(@RequestBody(required = false) AddPlanToCartRequest request) {
        return planService.addPlanToCart(AuthContext.getUserId(), request);
    }
}
