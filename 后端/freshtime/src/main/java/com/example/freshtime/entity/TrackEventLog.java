package com.example.freshtime.entity;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class TrackEventLog {
    private Long id;
    private Long userId;
    private String eventName;
    private String payload;
    private LocalDateTime createTime;
}
