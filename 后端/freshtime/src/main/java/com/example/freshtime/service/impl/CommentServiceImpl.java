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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        commentInfo.setRating(rating);
        commentInfo.setContent(content.isEmpty() ? null : content);
        commentMapper.insertComment(commentInfo);
        return ApiResponse.success("评价成功", null);
    }

    @Override
    public ApiResponse<?> listByGoodsId(Long goodsId, Integer page, Integer pageSize) {
        if (goodsId == null) {
            return ApiResponse.badRequest("goodsId不能为空");
        }
        int safePage = page == null || page < 1 ? 1 : page;
        int safePageSize = pageSize == null || pageSize < 1 ? 10 : Math.min(pageSize, 50);
        int offset = (safePage - 1) * safePageSize;
        List<CommentInfo> list = commentMapper.selectByGoodsId(goodsId, offset, safePageSize);
        int total = commentMapper.countByGoodsId(goodsId);

        Map<String, Object> data = new HashMap<>();
        data.put("list", list);
        data.put("page", safePage);
        data.put("pageSize", safePageSize);
        data.put("total", total);
        data.put("hasMore", offset + safePageSize < total);
        return ApiResponse.success("查询成功", data);
    }

    @Override
    public ApiResponse<?> summaryByGoodsId(Long goodsId) {
        if (goodsId == null) {
            return ApiResponse.badRequest("goodsId不能为空");
        }
        Map<String, Object> summary = commentMapper.summaryByGoodsId(goodsId);
        if (summary == null) {
            summary = new HashMap<>();
            summary.put("totalCount", 0);
            summary.put("avgRating", 0);
            summary.put("star5Count", 0);
            summary.put("star4Count", 0);
            summary.put("star3Count", 0);
            summary.put("star2Count", 0);
            summary.put("star1Count", 0);
        }
        return ApiResponse.success("查询成功", summary);
    }

    @Override
    public ApiResponse<?> detailById(Long userId, Long commentId) {
        if (userId == null || commentId == null) {
            return ApiResponse.badRequest("userId或commentId不能为空");
        }
        CommentInfo row = commentMapper.selectByIdAndUserId(commentId, userId);
        if (row == null) {
            return ApiResponse.notFound("评价不存在");
        }
        return ApiResponse.success("查询成功", row);
    }
}
