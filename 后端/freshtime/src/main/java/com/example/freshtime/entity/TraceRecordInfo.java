package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
public class TraceRecordInfo {
    private Long id;
    private Long goodsId;
    private Long originCardId;
    private String originName;
    private String cardDesc;
    private String cardMeta;
    private String location;
    private LocalDate harvestDate;
    private String batchNo;
    private String coldChainStatus;
    private Integer status;
    private LocalDateTime createTime;
}
