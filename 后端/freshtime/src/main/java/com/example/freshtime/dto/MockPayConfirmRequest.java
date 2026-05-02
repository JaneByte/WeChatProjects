package com.example.freshtime.dto;

import lombok.Data;

@Data
public class MockPayConfirmRequest {
    private Long userId;
    private Long orderId;
    private String payTradeNo;
}
