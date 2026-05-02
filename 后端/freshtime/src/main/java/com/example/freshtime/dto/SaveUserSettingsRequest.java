package com.example.freshtime.dto;

import lombok.Data;

@Data
public class SaveUserSettingsRequest {
    private Long userId;
    private Boolean notifyOrder;
    private Boolean notifyPromo;
}
