package com.example.freshtime.dto;

import lombok.Data;

@Data
public class GenerateComboPlanRequest {
    private String goalScene;
    private String peopleCount;
    private String budgetLevel;
    private String tastePref;
    private Long shuffleSeed;
}
