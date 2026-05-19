package com.example.freshtime.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.util.List;

@Data
public class SubmitOrderRequest {
    private Long userId;
    private Long addressId;
    private Long couponId;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String remark;
    private BigDecimal packPrice;
    private List<Item> items;

    @Data
    public static class Item {
        private Long goodsId;
        private Long skuId;
        private Integer quantity;
        private String sourceType;
        private Long sourcePlanId;
        private String sourceScene;
    }
}
