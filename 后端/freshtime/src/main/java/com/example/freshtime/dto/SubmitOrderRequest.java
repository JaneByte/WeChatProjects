package com.example.freshtime.dto;

import lombok.Data;

import java.util.List;

@Data
public class SubmitOrderRequest {
    private Long userId;
    private Long merchantId;
    private Long addressId;
    private Long couponId;
    private String receiverName;
    private String receiverPhone;
    private String receiverAddress;
    private String remark;
    private List<Item> items;

    @Data
    public static class Item {
        private Long goodsId;
        private Integer quantity;
    }
}
