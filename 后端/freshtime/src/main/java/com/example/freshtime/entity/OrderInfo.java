package com.example.freshtime.entity;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class OrderInfo {
    public static final String ORDER_SOURCE_NORMAL = "NORMAL";
    public static final String ORDER_SOURCE_FLASH = "FLASH";
    public static final String ORDER_SOURCE_MEAL = "MEAL";
    public static final String ORDER_SOURCE_COMBO = "COMBO";
    public static final String ORDER_SOURCE_SEASONAL = "SEASONAL";
    public static final String ORDER_SOURCE_MIXED = "MIXED";

    private Long id;
    private String orderNo;
    private Long userId;
    private BigDecimal totalAmount;
    private BigDecimal discountAmount;
    private BigDecimal actualAmount;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String remark;
    private Long couponId;
    private String orderSource;
    private Integer status;
    private String payChannel;
    private String payTradeNo;
    private Integer payStatus;
    private LocalDateTime payTime;
    private LocalDateTime deliverTime;
    private LocalDateTime finishTime;
    private LocalDateTime cancelTime;
    private LocalDateTime createTime;
}
