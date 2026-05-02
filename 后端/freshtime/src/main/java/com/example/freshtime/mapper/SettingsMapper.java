package com.example.freshtime.mapper;

import com.example.freshtime.entity.UserSettingInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

@Mapper
public interface SettingsMapper {

    @Select("SELECT id, user_id, notify_order, notify_promo, update_time " +
            "FROM user_setting WHERE user_id = #{userId} LIMIT 1")
    UserSettingInfo selectByUserId(@Param("userId") Long userId);

    @Insert("INSERT INTO user_setting(user_id, notify_order, notify_promo) " +
            "VALUES(#{userId}, #{notifyOrder}, #{notifyPromo})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insert(UserSettingInfo settings);

    @Update("UPDATE user_setting SET notify_order = #{notifyOrder}, notify_promo = #{notifyPromo}, update_time = NOW() " +
            "WHERE user_id = #{userId}")
    int updateByUserId(UserSettingInfo settings);
}
