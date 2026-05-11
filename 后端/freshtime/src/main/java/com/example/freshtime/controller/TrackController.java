package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.TrackEventLog;
import com.example.freshtime.mapper.TrackMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/track")
@CrossOrigin(origins = "*")
public class TrackController {

    @Autowired
    private TrackMapper trackMapper;

    @PostMapping("/event")
    public ApiResponse<?> event(@RequestBody Map<String, Object> req) {
        String eventName = req == null ? "" : String.valueOf(req.getOrDefault("eventName", ""));
        if (eventName.trim().isEmpty()) {
            return ApiResponse.badRequest("eventName不能为空");
        }

        Object payloadObj = req.get("payload");
        String payload = payloadObj == null ? "{}" : payloadObj.toString();

        TrackEventLog log = new TrackEventLog();
        log.setUserId(0L);
        log.setEventName(eventName);
        log.setPayload(payload);
        trackMapper.insertTrackEvent(log);

        Map<String, Object> data = new HashMap<>();
        data.put("ok", true);
        return ApiResponse.success(data);
    }
}
