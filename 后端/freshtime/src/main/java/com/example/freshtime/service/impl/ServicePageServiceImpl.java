package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.FaqInfo;
import com.example.freshtime.mapper.ServiceMapper;
import com.example.freshtime.service.ServicePageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Service
public class ServicePageServiceImpl implements ServicePageService {

    @Autowired
    private ServiceMapper serviceMapper;

    @Override
    public ApiResponse<?> getPageData() {
        List<FaqInfo> faqList = serviceMapper.selectFaqList();
        List<Map<String, Object>> faqRows = new ArrayList<>();
        for (FaqInfo item : faqList) {
            Map<String, Object> row = new HashMap<>();
            row.put("q", item.getQuestion());
            row.put("a", item.getAnswer());
            faqRows.add(row);
        }
        Map<String, Object> data = new HashMap<>();
        data.put("hotline", "400-888-1024");
        data.put("serviceTime", "09:00 - 21:00");
        data.put("faqList", faqRows);
        return ApiResponse.success(data);
    }
}
