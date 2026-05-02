package com.example.freshtime.dto;

import lombok.Data;

@Data
public class SaveAddressRequest {
    private Long id;
    private Long userId;
    private String receiverName;
    private String receiverPhone;
    private String province;
    private String city;
    private String district;
    private String detail;
    private Integer isDefault;
}
