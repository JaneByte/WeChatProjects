package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class FaqInfo {
    private Long id;
    private String question;
    private String answer;
    private Integer sort;
    private Integer status;
    private LocalDateTime createTime;
}
