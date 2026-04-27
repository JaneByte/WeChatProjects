package com.example.freshtime.service.impl;

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
    public Map<String, Object>getCategoryTree() {
        //1.查顶级分类
        List<Category> topList= categoryMapper.selectTopCategories();

        //2.组装树形结构
        //准备一个空列表来存数据
        List<Map<String,Object>> result = new ArrayList<>();

        //首先遍历每一个顶级分类
        for(Category top : topList){
            //把顶级分类的信息放到一个Map里
            Map<String,Object> item = new HashMap<>();
            item.put("id",top.getId());
            item.put("name",top.getName());
            //查子分类，把每个子分类也转成Map，并把它们挂到对应顶级分类下
            List<Category> children = categoryMapper.selectByParentId(top.getId());
            item.put("children",children);
            //把组装好的父分类加到结果列表
            result.add(item);
        }

        //3.返回统一格式
        Map<String,Object> response = new HashMap<>();
        response.put("code",200);
        response.put("data",result);
        return response;

        /*
        *****数据库查出来的*****
        id=1, name="蔬菜", parent_id=0
        id=5, name="叶菜类", parent_id=1
        id=6, name="根茎类", parent_id=1
        id=2, name="水果", parent_id=0
        id=13, name="浆果类", parent_id=2

        ****经过service处理之后的树形结构****
        {
          "code": 200,
          "msg": "success",
          "data": [
            {
              "id": 1,
              "name": "蔬菜",
              "children": [
                { "id": 5, "name": "叶菜类" },
                { "id": 6, "name": "根茎类" }
              ]
            },
            {
              "id": 2,
              "name": "水果",
              "children": [
                { "id": 13, "name": "浆果类" }
              ]
            }
          ]
        }
        */
    }
}
