package com.example.freshtime.dto;

import lombok.Data;

import java.util.List;

@Data
public class AddPlanToCartRequest {
    private String planType;
    private Long planId;
    private List<PlanCartItem> items;

    @Data
    public static class PlanCartItem {
        private Long goodsId;
        private Long skuId;
        private Integer quantity;
        private String sourceType;
        private Long sourcePlanId;
        private String sourceScene;
    }
}
