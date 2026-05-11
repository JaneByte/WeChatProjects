package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class KnowledgeArticle {
    private Long id;
    private String title;
    private String summary;
    private String tags;
    private String pickGuide;
    private String nutrition;
    private String pairing;
    private String cautions;
    private String content;
    private String searchKeyword;
    private Integer status;
    private Integer sort;
    private LocalDateTime createTime;
}
