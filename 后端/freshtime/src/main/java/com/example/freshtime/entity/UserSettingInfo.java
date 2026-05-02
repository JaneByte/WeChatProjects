package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class UserSettingInfo {
    private Long id;
    private Long userId;
    private Integer notifyOrder;
    private Integer notifyPromo;
    private LocalDateTime updateTime;
}
