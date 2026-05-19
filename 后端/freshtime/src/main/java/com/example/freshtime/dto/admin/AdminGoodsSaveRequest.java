package com.example.freshtime.dto.admin;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class AdminGoodsSaveRequest {
    private Long id;
    private Long categoryId;
    private String name;
    private String mainImage;
    private String images;
    private String detail;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stock;
    private String unit;
    private Integer isRecommend;
    private Integer isFlash;
    private BigDecimal flashPrice;
    private String flashStartTime;
    private String flashEndTime;
    private Integer flashStock;
    private Integer homeSort;
    private Integer showInHome;
    private Integer status;
    private String origin;
    private String keywords;
    private Integer seasonStartMonth;
    private Integer seasonEndMonth;
    private Integer seasonLateThresholdDays;
    private String seasonEarlyHint;
    private String seasonPeakHint;
    private String seasonLateHint;
    private List<Long> tagIds;
    private List<SkuItem> skuList;

    @Data
    public static class SkuItem {
        private Long id;
        private String skuName;
        private Integer skuWeightG;
        private BigDecimal skuPrice;
        private Integer skuStock;
        private Integer status;
        private Integer sort;
    }
}
