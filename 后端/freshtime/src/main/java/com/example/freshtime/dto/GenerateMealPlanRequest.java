package com.example.freshtime.dto;

import lombok.Data;

import java.util.List;

@Data
public class GenerateMealPlanRequest {
    private String mealType;
    private String budgetLevel;
    private String dietGoal;
    private String cookMode;
    private List<String> dislikeTags;
    private Long shuffleSeed;
}
