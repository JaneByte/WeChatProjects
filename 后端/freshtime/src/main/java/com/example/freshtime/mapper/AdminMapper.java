package com.example.freshtime.mapper;

import com.example.freshtime.entity.AdminInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface AdminMapper {

    @Select("SELECT id, username, password, nickname, shop_name, contact_name, phone, address, description, status " +
            "FROM admin WHERE username = #{username} LIMIT 1")
    AdminInfo selectByUsername(String username);

    @Select("SELECT id, username, password, nickname, shop_name, contact_name, phone, address, description, status " +
            "FROM admin WHERE id = #{id} LIMIT 1")
    AdminInfo selectById(Long id);
}
