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
    @Select("SELECT * FROM goods WHERE status = 1 AND (name LIKE CONCAT('%',#{keyword},'%') OR keywords LIKE CONCAT('%',#{keyword},'%') OR origin LIKE CONCAT('%',#{keyword},'%')) ORDER BY sales_volume DESC, is_recommend DESC, create_time DESC LIMIT #{offset}, #{pageSize}")
    List<Goods> searchByKeyword(@Param("keyword") String keyword, @Param("offset") Integer offset, @Param("pageSize") Integer pageSize);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND (name LIKE CONCAT('%',#{keyword},'%') OR keywords LIKE CONCAT('%',#{keyword},'%') OR origin LIKE CONCAT('%',#{keyword},'%'))")
    Integer countByKeyword(@Param("keyword") String keyword);

    @Select("SELECT * FROM goods WHERE status = 1 AND stock > 0 AND " +
            "(name LIKE CONCAT('%',#{sceneKeyword},'%') OR keywords LIKE CONCAT('%',#{sceneKeyword},'%')) " +
            "ORDER BY sales_volume DESC, is_recommend DESC, create_time DESC")
    List<Goods> selectBySceneKeyword(@Param("sceneKeyword") String sceneKeyword);

    @Select("SELECT g.* FROM goods g " +
            "INNER JOIN goods_tag gt ON gt.goods_id = g.id " +
            "INNER JOIN tag t ON t.id = gt.tag_id " +
            "WHERE g.status = 1 AND g.stock > 0 AND t.tag_name = #{tagName} " +
            "ORDER BY g.sales_volume DESC, g.is_recommend DESC, g.create_time DESC")
    List<Goods> selectByTagName(@Param("tagName") String tagName);
}
