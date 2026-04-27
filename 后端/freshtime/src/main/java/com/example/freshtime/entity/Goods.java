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
    private Integer isHot;
    private Integer isRecommend;
    private Integer status;
    private String origin;        // 产地
    private String keywords;      // 搜索关键词
    private LocalDateTime createTime;
}