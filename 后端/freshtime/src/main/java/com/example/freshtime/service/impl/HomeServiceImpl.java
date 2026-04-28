package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.HomeOriginCard;
import com.example.freshtime.mapper.HomeMapper;
import com.example.freshtime.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class HomeServiceImpl implements HomeService {

    @Autowired
    private HomeMapper homeMapper;

    @Override
    public ApiResponse<?> getHomeIndex() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime sevenDaysAgo = now.minusDays(7);

        Goods todayRecommend = homeMapper.selectTodayRecommend();
        List<Goods> flashList = homeMapper.selectFlashSaleList(now, 10);
        List<HomeOriginCard> traceList = homeMapper.selectOriginCards(10);
        Integer newArrivalCount = homeMapper.countNewArrivals(sevenDaysAgo);

        Map<String, Object> data = new HashMap<>();
        data.put("newArrivalCount", newArrivalCount == null ? 0 : newArrivalCount);
        data.put("todayRecommend", todayRecommend);

        Map<String, Object> flash = new HashMap<>();
        if (flashList != null && !flashList.isEmpty()) {
            LocalDateTime maxEndTime = flashList.stream()
                    .map(Goods::getFlashEndTime)
                    .filter(t -> t != null)
                    .max(LocalDateTime::compareTo)
                    .orElse(null);
            flash.put("endTime", maxEndTime);
        } else {
            flash.put("endTime", null);
        }
        flash.put("list", flashList);
        data.put("flash", flash);

        data.put("traceList", traceList);
        return ApiResponse.success(data);
    }

    @Override
    public ApiResponse<?> getHomeGoods(Integer page, Integer pageSize) {
        int safePage = (page == null || page < 1) ? 1 : page;
        int safePageSize = (pageSize == null || pageSize < 1) ? 10 : Math.min(pageSize, 50);
        int offset = (safePage - 1) * safePageSize;

        List<Goods> list = homeMapper.selectHomeGoodsPage(offset, safePageSize);
        Integer total = homeMapper.countHomeGoods();
        int totalCount = total == null ? 0 : total;
        boolean hasMore = offset + safePageSize < totalCount;

        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("page", safePage);
        data.put("pageSize", safePageSize);
        data.put("total", totalCount);
        data.put("hasMore", hasMore);
        return ApiResponse.success(data);
    }
}
