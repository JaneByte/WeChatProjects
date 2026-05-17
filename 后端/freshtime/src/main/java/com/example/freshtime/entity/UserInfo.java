package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserInfo {
    private Long id;
    private String openid;
    private String nickname;
    private String avatar;
    private Integer status;
    private LocalDateTime createTime;
}
