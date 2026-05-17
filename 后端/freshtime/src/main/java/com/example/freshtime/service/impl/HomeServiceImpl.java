package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.mapper.HomeMapper;
import com.example.freshtime.service.HomeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.ArrayList;
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
        Integer newArrivalCount = homeMapper.countNewArrivals(sevenDaysAgo);
        List<Map<String, Object>> bannerList = homeMapper.selectActiveBanners(5);
        List<Map<String, Object>> noticeList = homeMapper.selectActiveNotices(6);
        List<Map<String, Object>> navList = homeMapper.selectActiveNavList(8);
        List<Map<String, Object>> newArrivalList = homeMapper.selectNewArrivalList(8);

        Map<String, Object> data = new HashMap<>();
        data.put("newArrivalCount", newArrivalCount == null ? 0 : newArrivalCount);
        data.put("todayRecommend", todayRecommend);
        data.put("banners", bannerList == null ? new ArrayList<>() : bannerList);
        data.put("newArrivalList", newArrivalList == null ? new ArrayList<>() : newArrivalList);
        data.put("notices", noticeList == null ? new ArrayList<>() : noticeList);
        data.put("navList", navList == null ? new ArrayList<>() : navList);

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

    @Override
    public ApiResponse<?> getRecommendGoodsByKeyword(String keyword, Integer limit) {
        String clean = keyword == null ? "" : keyword.trim();
        if (clean.isEmpty()) {
            Map<String, Object> data = new HashMap<>();
            data.put("list", new ArrayList<>());
            return ApiResponse.success(data);
        }
        int safeLimit = (limit == null || limit < 1) ? 4 : Math.min(limit, 10);
        List<Goods> list = homeMapper.selectRecommendGoodsByKeyword(clean, safeLimit);
        Map<String, Object> data = new HashMap<>();
        data.put("list", list == null ? new ArrayList<>() : list);
        return ApiResponse.success(data);
    }
}
