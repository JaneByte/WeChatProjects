package com.example.freshtime.service;

import com.example.freshtime.common.ApiResponse;

public interface KnowledgeService {

    ApiResponse<?> getArticleDetail(Long id);
}
