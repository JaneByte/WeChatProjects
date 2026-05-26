package com.example.freshtime.dto;

import lombok.Data;

import java.util.List;

@Data
public class GenerateComboPlanRequest {
    private String goalScene;
    private String peopleCount;
    private String budgetLevel;
    private String tastePref;
    private List<Long> dislikeGoodsIds;
    private List<Long> previousPlanGoodsIds;
    private Long shuffleSeed;
}
