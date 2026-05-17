package com.example.freshtime.vo.admin;

import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.entity.OrderItemInfo;
import lombok.Data;

import java.util.List;

@Data
public class AdminOrderDetailVO {
    private OrderInfo order;
    private List<OrderItemInfo> items;
}
