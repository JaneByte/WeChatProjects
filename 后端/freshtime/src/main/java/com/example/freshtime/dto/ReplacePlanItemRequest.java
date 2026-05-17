package com.example.freshtime.dto;

import lombok.Data;

@Data
public class ReplacePlanItemRequest {
    private String planType;
    private Long planId;
    private Long originGoodsId;
    private Long originSkuId;
}
