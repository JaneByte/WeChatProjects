package com.example.freshtime.controller;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.TraceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/trace")
@CrossOrigin(origins = "*")
public class TraceController {

    @Autowired
    private TraceService traceService;

    @GetMapping("/detail")
    public ApiResponse<?> detail(@RequestParam Long goodsId) {
        return traceService.detail(goodsId);
    }
}
