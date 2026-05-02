package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.dto.SubmitCommentRequest;

public interface CommentService {
    ApiResponse<?> submitComment(SubmitCommentRequest request);
}

