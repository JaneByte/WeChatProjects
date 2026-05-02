package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class CartInfo {
    private Long id;
    private Long userId;
    private Long goodsId;
    private Long merchantId;
    private Integer quantity;
    private Integer selected;
    private LocalDateTime createTime;

    private String name;
    private String image;
    private BigDecimal price;
    private Integer stock;
    private String unit;
    private Integer status;
    private String origin;
}

