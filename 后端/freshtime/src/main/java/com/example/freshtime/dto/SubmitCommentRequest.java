package com.example.freshtime.dto;

import lombok.Data;

@Data
public class SubmitCommentRequest {
    private Long userId;
    private Long orderId;
    private Long goodsId;
    private Integer rating;
    private String content;
}

