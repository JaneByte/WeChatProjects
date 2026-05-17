package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SubmitCommentRequest;

public interface CommentService {
    ApiResponse<?> submitComment(SubmitCommentRequest request);

    ApiResponse<?> listByGoodsId(Long goodsId, Integer page, Integer pageSize);

    ApiResponse<?> summaryByGoodsId(Long goodsId);

    ApiResponse<?> detailById(Long userId, Long commentId);
}
