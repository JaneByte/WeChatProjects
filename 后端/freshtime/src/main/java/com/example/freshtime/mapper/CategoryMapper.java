package com.example.freshtime.mapper;

import com.example.freshtime.entity.Category;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface CategoryMapper {

    // 查询顶级分类（如：蔬菜、水果）
    @Select("SELECT * FROM category WHERE parent_id = 0 AND status = 1 ORDER BY sort")
    List<Category> selectTopCategories();

    // 查询指定父分类下的子分类
    @Select("SELECT * FROM category WHERE parent_id = #{parentId} AND status = 1 ORDER BY sort")
    List<Category> selectByParentId(Long parentId);

    // 根据分类ID查询分类详情
    @Select("SELECT * FROM category WHERE id = #{id}")
    Category selectById(Long id);
}
