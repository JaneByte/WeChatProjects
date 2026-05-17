package com.example.freshtime.dto;

import java.util.Map;

public class UpdateSeasonalConfigRequest {
    private Map<String, String> config;

    public Map<String, String> getConfig() {
        return config;
    }

    public void setConfig(Map<String, String> config) {
        this.config = config;
    }
}

