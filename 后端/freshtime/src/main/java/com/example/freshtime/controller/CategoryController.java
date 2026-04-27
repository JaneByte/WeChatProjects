package com.example.freshtime.controller;

import com.example.freshtime.entity.Category;
import com.example.freshtime.mapper.CategoryMapper;
import com.example.freshtime.service.CategoryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/category")
@CrossOrigin(origins = "*")  // 允许小程序跨域请求
public class CategoryController {

    @Autowired
    private CategoryService categoryService;

    @GetMapping("/tree")
    public Map<String,Object> getCategoryTree(){
        return categoryService.getCategoryTree();
    }

}
