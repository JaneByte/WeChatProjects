package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.HomeOriginCard;
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
        List<HomeOriginCard> traceList = homeMapper.selectOriginCards(10);
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
        data.put("notices", (noticeList == null || noticeList.isEmpty()) ? buildDefaultNotices() : noticeList);
        data.put("navList", (navList == null || navList.isEmpty()) ? buildDefaultNavList() : navList);

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

    private List<Map<String, Object>> buildDefaultNotices() {
        List<Map<String, Object>> notices = new ArrayList<>();
        notices.add(buildNoticeItem("1", "今日上新优先发货，最快次日达", "none", ""));
        notices.add(buildNoticeItem("2", "限时秒杀库存有限，先到先得", "goods", "flash"));
        return notices;
    }

    private Map<String, Object> buildNoticeItem(String id, String text, String linkType, String linkValue) {
        Map<String, Object> item = new HashMap<>();
        item.put("id", id);
        item.put("text", text);
        item.put("linkType", linkType);
        item.put("linkValue", linkValue);
        return item;
    }

    private List<Map<String, Object>> buildDefaultNavList() {
        List<Map<String, Object>> navList = new ArrayList<>();
        navList.add(buildNavItem("seasonal", "时令优选", "时", "goods", "seasonal"));
        navList.add(buildNavItem("hot", "热销爆款", "热", "goods", "hot"));
        navList.add(buildNavItem("flash", "限时秒杀", "秒", "goods", "flash"));
        navList.add(buildNavItem("category", "全部分类", "类", "category", "category"));
        return navList;
    }

    private Map<String, Object> buildNavItem(String type, String text, String iconText, String linkType, String linkValue) {
        Map<String, Object> item = new HashMap<>();
        item.put("type", type);
        item.put("text", text);
        item.put("iconText", iconText);
        item.put("linkType", linkType);
        item.put("linkValue", linkValue);
        return item;
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
