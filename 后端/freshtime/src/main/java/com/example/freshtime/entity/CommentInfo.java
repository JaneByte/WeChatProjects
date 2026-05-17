package com.example.freshtime.entity;

import lombok.Data;

@Data
public class CommentInfo {
    private Long id;
    private Long orderId;
    private Long userId;
    private Long goodsId;
    private Integer rating;
    private String content;
    private String images;
    private java.time.LocalDateTime createTime;
}
