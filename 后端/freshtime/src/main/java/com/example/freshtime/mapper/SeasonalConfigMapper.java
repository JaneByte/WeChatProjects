package com.example.freshtime.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface SeasonalConfigMapper {

    @Select("SELECT config_key AS configKey, config_value AS configValue, update_time AS updateTime FROM seasonal_config")
    List<Map<String, Object>> selectAll();

    @Insert("INSERT INTO seasonal_config(config_key, config_value) VALUES(#{configKey}, #{configValue}) " +
            "ON DUPLICATE KEY UPDATE config_value = VALUES(config_value), update_time = NOW()")
    int upsert(@Param("configKey") String configKey, @Param("configValue") String configValue);
}

