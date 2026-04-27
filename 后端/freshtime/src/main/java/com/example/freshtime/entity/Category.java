package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class Category {
    private Long id;                    //id
    private Long parentId;              //父类id
    private String name;                //分类名
    private String icon;                //分类对应图标路径
    private Integer sort;               //排序值，越小越靠前
    private Integer status;             //当前状态，是否启用
    private LocalDateTime createTime;   //分类创建时间

    public Category() {}

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public Integer getSort() {
        return sort;
    }

    public void setSort(Integer sort) {
        this.sort = sort;
    }

    public Integer getStatus() {
        return status;
    }

    public void setStatus(Integer status) {
        this.status = status;
    }

    public LocalDateTime getCreateTime() {
        return createTime;
    }

    public void setCreateTime(LocalDateTime createTime) {
        this.createTime = createTime;
    }
}