package com.example.freshtime.mapper;

import com.example.freshtime.entity.FaqInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ServiceMapper {

    @Select("SELECT id, question, answer, sort, status, create_time " +
            "FROM service_faq " +
            "WHERE status = 1 " +
            "ORDER BY sort ASC, id ASC")
    List<FaqInfo> selectFaqList();
}
