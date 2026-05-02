package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.TraceRecordInfo;
import com.example.freshtime.mapper.TraceMapper;
import com.example.freshtime.service.TraceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class TraceServiceImpl implements TraceService {

    @Autowired
    private TraceMapper traceMapper;

    @Override
    public ApiResponse<?> detail(Long goodsId) {
        if (goodsId == null) {
            return ApiResponse.badRequest("goodsId不能为空");
        }
        TraceRecordInfo record = traceMapper.selectLatestByGoodsId(goodsId);
        if (record == null) {
            return ApiResponse.notFound("未找到溯源信息");
        }

        Map<String, Object> trace = new HashMap<>();
        trace.put("id", record.getId());
        trace.put("name", record.getOriginName());
        trace.put("desc", record.getCardDesc());
        trace.put("meta", record.getCardMeta());

        List<Map<String, Object>> list = new ArrayList<>();
        list.add(buildRow("产地位置", record.getLocation()));
        list.add(buildRow("采收日期", record.getHarvestDate()));
        list.add(buildRow("质检批次", record.getBatchNo()));
        list.add(buildRow("冷链状态", record.getColdChainStatus()));

        Map<String, Object> data = new HashMap<>();
        data.put("trace", trace);
        data.put("list", list);
        return ApiResponse.success(data);
    }

    private Map<String, Object> buildRow(String label, Object value) {
        Map<String, Object> row = new HashMap<>();
        row.put("label", label);
        row.put("value", value == null ? "" : value);
        return row;
    }
}
