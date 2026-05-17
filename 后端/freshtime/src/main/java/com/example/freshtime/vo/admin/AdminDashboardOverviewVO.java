package com.example.freshtime.vo.admin;

import lombok.Data;

import java.math.BigDecimal;

@Data
public class AdminDashboardOverviewVO {
    private Integer goodsCount;
    private Integer onSaleGoodsCount;
    private Integer userCount;
    private Integer enabledUserCount;
    private Integer orderCount;
    private Integer pendingDeliveryOrderCount;
    private BigDecimal totalSalesAmount;
    private Integer mealOrderCount;
    private Integer comboOrderCount;
    private Integer seasonalOrderCount;
    private Integer mixedOrderCount;
}
