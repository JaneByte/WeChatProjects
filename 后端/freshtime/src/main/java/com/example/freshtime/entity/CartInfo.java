package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class CartInfo {
    public static final String SOURCE_TYPE_NORMAL = "NORMAL";
    public static final String SOURCE_TYPE_FLASH = "FLASH";
    public static final String SOURCE_TYPE_MEAL = "MEAL";
    public static final String SOURCE_TYPE_COMBO = "COMBO";
    public static final String SOURCE_TYPE_SEASONAL = "SEASONAL";

    private Long id;
    private Long userId;
    private Long goodsId;
    private Long skuId;
    private Integer quantity;
    private Integer selected;
    private String sourceType;
    private Long sourcePlanId;
    private String sourceScene;

    private String name;
    private String image;
    private BigDecimal price;
    private Integer stock;
    private String unit;
    private String skuName;
    private Integer skuWeightG;
    private Integer status;
    private String origin;
    private BigDecimal goodsPrice;
    private Integer isFlash;
    private BigDecimal flashPrice;
    private LocalDateTime flashStartTime;
    private LocalDateTime flashEndTime;
    private Integer flashStock;
}
