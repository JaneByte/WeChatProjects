package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class HomeOriginCard {
    private Long id;
    private String originName;
    private String cardDesc;
    private String cardMeta;
    private Integer status;
    private Integer sort;
    private LocalDateTime createTime;
}
