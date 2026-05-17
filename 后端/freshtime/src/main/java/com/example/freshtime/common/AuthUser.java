package com.example.freshtime.common;

import lombok.Data;

@Data
public class AuthUser {
    private Long userId;
    private String openid;
    private String nickname;
}
