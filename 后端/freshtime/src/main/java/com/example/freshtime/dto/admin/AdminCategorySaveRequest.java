package com.example.freshtime.dto.admin;

import lombok.Data;

@Data
public class AdminCategorySaveRequest {
    private Long id;
    private Long parentId;
    private String name;
    private String icon;
    private Integer sort;
    private Integer status;
}
