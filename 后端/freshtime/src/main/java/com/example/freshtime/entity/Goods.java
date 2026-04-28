package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class Goods {
    private Long id;
    private Long merchantId;
    private Long categoryId;
    private String name;
    private String mainImage;
    private String images;
    private String detail;
    private BigDecimal price;
    private BigDecimal originalPrice;
    private Integer stock;
    private String unit;
    private Integer salesVolume;
    private Integer isRecommend;
    private Integer isFlash;
    private BigDecimal flashPrice;
    private LocalDateTime flashStartTime;
    private LocalDateTime flashEndTime;
    private Integer flashStock;
    private Integer homeSort;
    private Integer showInHome;
    private Integer status;
    private String origin;
    private String keywords;
    private LocalDateTime createTime;
}
