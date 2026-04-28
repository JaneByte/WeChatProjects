package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class OrderItemInfo {
    private Long id;
    private Long orderId;
    private Long goodsId;
    private String goodsName;
    private String goodsImage;
    private BigDecimal price;
    private Integer quantity;
    private BigDecimal totalPrice;
}
