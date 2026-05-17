package com.example.freshtime.entity;

import lombok.Data;

@Data
public class ScenePackItem {
    private Long id;
    private Long packId;
    private Long goodsId;
    private Long skuId;
    private String goodsName;
    private String goodsImage;
    private String skuName;
    private Integer skuWeightG;
    private Integer quantity;
    private String itemRole;
    private Integer sort;
}

