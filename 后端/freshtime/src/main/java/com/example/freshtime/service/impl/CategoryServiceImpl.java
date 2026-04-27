package com.example.freshtime.service.impl;

import com.example.freshtime.common.ApiResponse;
import com.example.freshtime.entity.Category;
import com.example.freshtime.mapper.CategoryMapper;
import com.example.freshtime.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class CategoryServiceImpl implements CategoryService {

    @Autowired
    private CategoryMapper categoryMapper;

    @Override
    public ApiResponse<?> getCategoryTree() {
        List<Category> topList = categoryMapper.selectTopCategories();

        List<Map<String, Object>> result = new ArrayList<>();
        for (Category top : topList) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", top.getId());
            item.put("name", top.getName());

            List<Category> children = categoryMapper.selectByParentId(top.getId());
            item.put("children", children);
            result.add(item);
        }

        return ApiResponse.success(result);
    }
}
