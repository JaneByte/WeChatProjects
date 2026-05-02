package com.example.freshtime.mapper;

import com.example.freshtime.entity.UserInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface UserMapper {

    @Select("SELECT * FROM user WHERE openid = #{openid} LIMIT 1")
    UserInfo selectByOpenid(String openid);

    @Select("SELECT * FROM user WHERE id = #{id} LIMIT 1")
    UserInfo selectById(Long id);

    @Insert("INSERT INTO user(openid, nickname, status) VALUES(#{openid}, #{nickname}, 1)")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertUser(UserInfo userInfo);

    @Update("UPDATE user SET nickname = #{nickname} WHERE id = #{id}")
    int updateNickname(UserInfo userInfo);
}
