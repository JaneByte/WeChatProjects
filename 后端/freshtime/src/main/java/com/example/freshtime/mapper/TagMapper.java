package com.example.freshtime.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface TagMapper {

    @Select("<script>" +
            "SELECT id, tag_name AS tagName, type, tag_code AS tagCode, tag_type AS tagType, sort " +
            "FROM tag " +
            "WHERE status = 1 " +
            "<if test='structuredOnly != null and structuredOnly'> " +
            "AND tag_type IS NOT NULL AND tag_type != '' " +
            "</if> " +
            "ORDER BY tag_type ASC, sort ASC, id ASC" +
            "</script>")
    List<Map<String, Object>> selectTagList(@Param("structuredOnly") Boolean structuredOnly);
}

