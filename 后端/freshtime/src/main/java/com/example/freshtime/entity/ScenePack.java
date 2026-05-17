package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class ScenePack {
    private Long id;
    private String name;
    private String sceneType;
    private String packMode;
    private String coverImage;
    private String summary;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stock;
    private String couponThresholdHint;
    private Integer status;
    private Integer sort;
}

