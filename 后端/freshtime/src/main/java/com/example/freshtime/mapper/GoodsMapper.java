package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface GoodsMapper {

    // 根据分类ID查询商品
    @Select("SELECT * FROM goods WHERE category_id = #{categoryId} AND status = 1 ORDER BY is_recommend DESC, create_time DESC")
    List<Goods> selectByCategoryId(Long categoryId);

    // 查询推荐商品
    @Select("SELECT * FROM goods WHERE is_recommend = 1 AND status = 1 ORDER BY create_time DESC")
    List<Goods> selectRecommendList();

    // 根据ID查询商品详情
    @Select("SELECT * FROM goods WHERE id = #{id}")
    Goods selectById(Long id);

    // 搜索商品（匹配名称、关键词、产地）
    @Select("SELECT * FROM goods WHERE status = 1 AND (name LIKE CONCAT('%',#{keyword},'%') OR keywords LIKE CONCAT('%',#{keyword},'%') OR origin LIKE CONCAT('%',#{keyword},'%')) ORDER BY create_time DESC")
    List<Goods> searchByKeyword(String keyword);
}