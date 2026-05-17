package com.example.freshtime.dto.admin;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class AdminCouponSaveRequest {
    private Long id;
    private String name;
    private String description;
    private BigDecimal thresholdAmount;
    private BigDecimal discountAmount;
    private String expireDate;
    private Integer status;
}
