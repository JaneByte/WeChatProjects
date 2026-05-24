package com.example.freshtime.mapper;

import com.example.freshtime.entity.UserInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface UserMapper {

    String USER_COLUMNS = "id, openid, nickname, avatar, status, create_time";

    @Select("SELECT " + USER_COLUMNS + " FROM `user` WHERE openid = #{openid} LIMIT 1")
    UserInfo selectByOpenid(String openid);

    @Select("SELECT " + USER_COLUMNS + " FROM `user` WHERE id = #{id} LIMIT 1")
    UserInfo selectById(Long id);

    @Insert("INSERT INTO `user`(openid, nickname, avatar, status) VALUES(#{openid}, #{nickname}, #{avatar}, 1)")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertUser(UserInfo userInfo);

    @Update("UPDATE `user` SET nickname = #{nickname} WHERE id = #{id}")
    int updateNickname(UserInfo userInfo);

    @Update("UPDATE `user` SET nickname = #{nickname}, avatar = #{avatar} WHERE id = #{id}")
    int updateProfile(UserInfo userInfo);

    @Select("SELECT " + USER_COLUMNS + " FROM `user` ORDER BY id ASC")
    List<UserInfo> selectAllUsers();

    @Select("SELECT COUNT(1) FROM `user`")
    Integer countAllUsers();

    @Select("SELECT COUNT(1) FROM `user` WHERE status = 1")
    Integer countEnabledUsers();
}
