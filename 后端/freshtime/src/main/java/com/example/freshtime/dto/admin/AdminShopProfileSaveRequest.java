package com.example.freshtime.dto.admin;

import lombok.Data;

@Data
public class AdminShopProfileSaveRequest {
    private String shopName;
    private String contactName;
    private String phone;
    private String address;
}
