package com.example.freshtime.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String openid;
    private String nickname;
}
