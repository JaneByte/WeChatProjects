package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.TrackEventLog;
import com.example.freshtime.mapper.TrackMapper;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger log = LoggerFactory.getLogger(TrackController.class);

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

        TrackEventLog eventLog = new TrackEventLog();
        eventLog.setUserId(0L);
        eventLog.setEventName(eventName);
        eventLog.setPayload(payload);
        try {
            trackMapper.insertTrackEvent(eventLog);
        } catch (Exception ex) {
            log.warn("埋点写入失败，已降级返回成功 eventName={}", eventName, ex);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("ok", true);
        return ApiResponse.success(data);
    }
}
