package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.service.ServicePageService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;

@Service
public class ServicePageServiceImpl implements ServicePageService {

    @Override
    public ApiResponse<?> getPageData() {
        List<Map<String, Object>> faqRows = new ArrayList<>();
        faqRows.add(buildFaq("多久发货？", "常规订单支付成功后会尽快安排发货，生鲜商品会优先处理。"));
        faqRows.add(buildFaq("配送范围怎么查看？", "你可以先填写收货地址，系统会根据当前配送范围判断是否支持下单。"));
        faqRows.add(buildFaq("收到商品不满意怎么办？", "如果商品有质量问题，可在订单详情页发起售后申请，我们会尽快处理。"));
        faqRows.add(buildFaq("下单后可以修改地址吗？", "未发货前可联系客服协助处理，已发货订单请以物流配送信息为准。"));
        Map<String, Object> data = new HashMap<>();
        data.put("hotline", "400-888-1024");
        data.put("serviceTime", "09:00 - 21:00");
        data.put("faqList", faqRows);
        return ApiResponse.success(data);
    }

    private Map<String, Object> buildFaq(String question, String answer) {
        Map<String, Object> row = new HashMap<>();
        row.put("q", question);
        row.put("a", answer);
        return row;
    }
}
