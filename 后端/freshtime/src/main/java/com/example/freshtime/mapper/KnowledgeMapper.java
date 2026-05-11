package com.example.freshtime.mapper;

import com.example.freshtime.entity.KnowledgeArticle;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface KnowledgeMapper {

    @Select("SELECT id, title, summary, tags, pick_guide AS pickGuide, nutrition, pairing, cautions, content, search_keyword AS searchKeyword, status, sort, create_time AS createTime " +
            "FROM knowledge_article WHERE id = #{id} AND status = 1 LIMIT 1")
    KnowledgeArticle selectArticleById(@Param("id") Long id);
}
