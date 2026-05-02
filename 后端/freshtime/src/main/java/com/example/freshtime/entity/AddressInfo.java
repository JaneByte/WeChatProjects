package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AddressInfo {
    private Long id;
    private Long userId;
    private String receiverName;
    private String receiverPhone;
    private String province;
    private String city;
    private String district;
    private String detail;
    private Integer isDefault;
    private LocalDateTime createTime;
}
