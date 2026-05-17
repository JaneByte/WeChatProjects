package com.example.freshtime.entity;

import lombok.Data;

@Data
public class AdminInfo {
    private Long id;
    private String username;
    private String password;
    private String nickname;
    private String shopName;
    private String contactName;
    private String phone;
    private String address;
    private String description;
    private Integer status;
}
