package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class SkuComponent {
    private Long id;
    private Long skuId;
    private Long componentGoodsId;
    private String componentName;
    private Integer componentWeightG;
    private Integer quantity;
    private BigDecimal componentPrice;
    private Integer sort;
}
