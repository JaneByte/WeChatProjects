package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
public class CouponInfo {
    private Long id;
    private Long userId;
    private String title;
    private String conditionText;
    private BigDecimal thresholdAmount;
    private BigDecimal discountAmount;
    private LocalDate expireDate;
    private Integer status;
}
