package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class GoodsSku {
    private Long id;
    private Long goodsId;
    private String skuName;
    private Integer skuWeightG;
    private BigDecimal skuPrice;
    private Integer skuStock;
    private Integer status;
    private Integer sort;
    private String specType;
    private String specValue;
}
