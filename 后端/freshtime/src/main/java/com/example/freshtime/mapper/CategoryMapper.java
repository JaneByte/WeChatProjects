package com.example.freshtime.mapper;

import com.example.freshtime.entity.Category;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CategoryMapper {

    String CATEGORY_COLUMNS = "id, parent_id, name, icon, sort, status";

    // 查询顶级分类（如：蔬菜、水果）
    @Select("SELECT " + CATEGORY_COLUMNS + " FROM category WHERE parent_id = 0 AND status = 1 ORDER BY sort")
    List<Category> selectTopCategories();

    // 查询指定父分类下的子分类
    @Select("SELECT " + CATEGORY_COLUMNS + " FROM category WHERE parent_id = #{parentId} AND status = 1 ORDER BY sort")
    List<Category> selectByParentId(Long parentId);

    // 根据分类ID查询分类详情
    @Select("SELECT " + CATEGORY_COLUMNS + " FROM category WHERE id = #{id}")
    Category selectById(Long id);

    @Select("SELECT " + CATEGORY_COLUMNS + " FROM category ORDER BY parent_id ASC, sort ASC, id ASC")
    List<Category> selectAll();

    @Insert("INSERT INTO category(parent_id, name, icon, sort, status) VALUES(#{parentId}, #{name}, #{icon}, #{sort}, #{status})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertCategory(Category category);

    @Update("UPDATE category SET parent_id = #{parentId}, name = #{name}, icon = #{icon}, sort = #{sort}, status = #{status} WHERE id = #{id}")
    int updateCategory(Category category);

    @Update("UPDATE category SET status = #{status} WHERE id = #{id}")
    int updateCategoryStatus(Category category);
}
