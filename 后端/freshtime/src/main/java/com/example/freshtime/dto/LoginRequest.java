package com.example.freshtime.dto;

import lombok.Data;

@Data
public class LoginRequest {
    private String code;
    private String openid;
    private String nickname;
    private String avatar;
    private String loginType;
}
