package com.example.freshtime.mapper;

import com.example.freshtime.entity.Category;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface CategoryMapper {

    //查询分类表中大分类：蔬菜 水果
    @Select("SELECT * FROM category WHERE parent_id = 0 AND status = 1 ORDER BY sort")
    List<Category> selectTopCategories();

    //查询分类表中当前选择的（蔬菜/水果）中的所有小分类
    @Select("SELECT * FROM category WHERE parent_id = #{parentId} AND status = 1 ORDER BY sort")
    List<Category> selectByParentId(Long parentId);

    //查询具体id的小分类
    @Select("SELECT * FROM category WHERE id = #{id}")
    Category selectById(Long id);
}