package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.mapper.GoodsMapper;
import com.example.freshtime.mapper.OrderMapper;
import com.example.freshtime.mapper.UserMapper;
import com.example.freshtime.vo.admin.AdminDashboardOverviewVO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class AdminDashboardHelper {

    @Autowired
    private GoodsMapper goodsMapper;

    @Autowired
    private UserMapper userMapper;

    @Autowired
    private OrderMapper orderMapper;

    public AdminDashboardOverviewVO buildOverview() {
        AdminDashboardOverviewVO overview = new AdminDashboardOverviewVO();
        overview.setGoodsCount(defaultInt(goodsMapper.countAllGoods()));
        overview.setOnSaleGoodsCount(defaultInt(goodsMapper.countOnSaleGoods()));
        overview.setUserCount(defaultInt(userMapper.countAllUsers()));
        overview.setEnabledUserCount(defaultInt(userMapper.countEnabledUsers()));
        overview.setOrderCount(defaultInt(orderMapper.countAllOrders()));
        overview.setPendingDeliveryOrderCount(defaultInt(orderMapper.countPendingDeliveryOrders()));
        overview.setTotalSalesAmount(defaultAmount(orderMapper.sumPaidActualAmount()));
        overview.setMealOrderCount(defaultInt(orderMapper.countPaidOrdersContainingItemSource(OrderInfo.ORDER_SOURCE_MEAL)));
        overview.setComboOrderCount(defaultInt(orderMapper.countPaidOrdersContainingItemSource(OrderInfo.ORDER_SOURCE_COMBO)));
        overview.setSeasonalOrderCount(defaultInt(orderMapper.countPaidOrdersContainingItemSource(OrderInfo.ORDER_SOURCE_SEASONAL)));
        overview.setMixedOrderCount(defaultInt(orderMapper.countPaidOrdersBySource(OrderInfo.ORDER_SOURCE_MIXED)));
        return overview;
    }

    private Integer defaultInt(Integer value) {
        return value == null ? 0 : value;
    }

    private BigDecimal defaultAmount(BigDecimal value) {
        return value == null ? BigDecimal.ZERO : value;
    }
}
