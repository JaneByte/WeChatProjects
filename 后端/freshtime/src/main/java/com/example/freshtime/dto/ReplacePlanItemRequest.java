package com.example.freshtime.dto;

import lombok.Data;

import java.util.List;

@Data
public class ReplacePlanItemRequest {
    private String planType;
    private Long planId;
    private Long originGoodsId;
    private Long originSkuId;
    private String originRole;
    private Integer itemIndex;
    private String goalScene;
    private String peopleCount;
    private List<Long> currentGoodsIds;
    private List<CurrentPlanItem> currentItems;

    @Data
    public static class CurrentPlanItem {
        private Long goodsId;
        private String role;
    }
}
