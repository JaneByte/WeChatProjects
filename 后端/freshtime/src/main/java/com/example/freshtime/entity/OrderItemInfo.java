package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class OrderItemInfo {
    private Long id;
    private Long orderId;
    private Long goodsId;
    private Long skuId;
    private String goodsName;
    private String goodsImage;
    private String skuName;
    private Integer skuWeightG;
    private BigDecimal price;
    private Integer quantity;
    private BigDecimal totalPrice;
    private String sourceType;
    private Long sourcePlanId;
    private String sourceScene;
    private Integer commentCount;
    private Integer hasCommented;
    private Long commentId;
}
