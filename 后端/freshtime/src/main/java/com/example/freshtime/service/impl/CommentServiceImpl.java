package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SubmitCommentRequest;
import com.example.freshtime.entity.CommentInfo;
import com.example.freshtime.entity.OrderInfo;
import com.example.freshtime.mapper.CommentMapper;
import com.example.freshtime.service.CommentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CommentServiceImpl implements CommentService {

    @Autowired
    private CommentMapper commentMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiResponse<?> submitComment(SubmitCommentRequest request) {
        if (request == null || request.getUserId() == null || request.getOrderId() == null || request.getGoodsId() == null) {
            return ApiResponse.badRequest("参数不能为空");
        }
        Integer rating = request.getRating();
        if (rating == null || rating < 1 || rating > 5) {
            return ApiResponse.badRequest("评分范围应为1-5");
        }

        String content = request.getContent() == null ? "" : request.getContent().trim();
        if (content.length() > 500) {
            return ApiResponse.badRequest("评价内容过长");
        }

        OrderInfo order = commentMapper.selectOrderByIdAndUserId(request.getOrderId(), request.getUserId());
        if (order == null) {
            return ApiResponse.notFound("订单不存在");
        }
        if (order.getStatus() == null || order.getStatus() != 3) {
            return ApiResponse.badRequest("仅已完成订单可评价");
        }

        int itemCount = commentMapper.countOrderItem(request.getOrderId(), request.getGoodsId());
        if (itemCount <= 0) {
            return ApiResponse.badRequest("该商品不在订单中");
        }

        int duplicate = commentMapper.countDuplicateComment(request.getUserId(), request.getOrderId(), request.getGoodsId());
        if (duplicate > 0) {
            return ApiResponse.badRequest("该商品已评价，请勿重复提交");
        }

        CommentInfo commentInfo = new CommentInfo();
        commentInfo.setOrderId(request.getOrderId());
        commentInfo.setUserId(request.getUserId());
        commentInfo.setGoodsId(request.getGoodsId());
        commentInfo.setMerchantId(order.getMerchantId());
        commentInfo.setRating(rating);
        commentInfo.setContent(content.isEmpty() ? null : content);
        commentMapper.insertComment(commentInfo);
        return ApiResponse.success("评价成功", null);
    }
}

