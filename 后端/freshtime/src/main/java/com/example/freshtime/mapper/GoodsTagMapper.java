package com.example.freshtime.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface GoodsTagMapper {

    @Select({
            "<script>",
            "SELECT gt.goods_id AS goodsId, t.tag_code AS tagCode",
            "FROM goods_tag gt",
            "JOIN tag t ON t.id = gt.tag_id",
            "WHERE t.status = 1",
            "AND t.tag_code IS NOT NULL",
            "<if test='goodsIds != null and goodsIds.size() > 0'>",
            "AND gt.goods_id IN",
            "<foreach collection='goodsIds' item='id' open='(' separator=',' close=')'>#{id}</foreach>",
            "</if>",
            "</script>"
    })
    List<Map<String, Object>> selectTagCodesByGoodsIds(@Param("goodsIds") List<Long> goodsIds);

    @Select("SELECT t.id AS id, t.tag_name AS tagName, t.tag_code AS tagCode, t.tag_type AS tagType, t.type AS type " +
            "FROM goods_tag gt JOIN tag t ON t.id = gt.tag_id WHERE gt.goods_id = #{goodsId} ORDER BY t.id ASC")
    List<Map<String, Object>> selectTagsByGoodsId(@Param("goodsId") Long goodsId);

    @Delete("DELETE gt FROM goods_tag gt JOIN tag t ON t.id = gt.tag_id WHERE gt.goods_id = #{goodsId} AND t.tag_type IS NOT NULL AND t.tag_type != ''")
    int deleteStructuredTagsByGoodsId(@Param("goodsId") Long goodsId);

    @Insert("INSERT IGNORE INTO goods_tag(goods_id, tag_id) VALUES(#{goodsId}, #{tagId})")
    int insertGoodsTag(@Param("goodsId") Long goodsId, @Param("tagId") Long tagId);
}
