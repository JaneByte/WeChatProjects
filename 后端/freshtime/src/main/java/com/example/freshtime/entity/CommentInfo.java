package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class CommentInfo {
    private Long id;
    private Long orderId;
    private Long userId;
    private Long goodsId;
    private Long merchantId;
    private Integer rating;
    private String content;
    private String images;
    private LocalDateTime createTime;
}

