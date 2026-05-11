package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.KnowledgeArticle;
import com.example.freshtime.mapper.KnowledgeMapper;
import com.example.freshtime.service.KnowledgeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class KnowledgeServiceImpl implements KnowledgeService {

    @Autowired
    private KnowledgeMapper knowledgeMapper;

    @Override
    public ApiResponse<?> getArticleDetail(Long id) {
        if (id == null || id < 1) {
            return ApiResponse.badRequest("参数错误");
        }

        KnowledgeArticle article = knowledgeMapper.selectArticleById(id);
        if (article == null) {
            return ApiResponse.notFound("科普内容不存在");
        }
        return ApiResponse.success(article);
    }
}
