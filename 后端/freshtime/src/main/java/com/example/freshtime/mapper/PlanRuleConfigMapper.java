package com.example.freshtime.mapper;

import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface PlanRuleConfigMapper {

    @Select("SELECT rule_key AS ruleKey, rule_value AS ruleValue, update_time AS updateTime FROM plan_rule_config")
    List<Map<String, Object>> selectAll();

    @Insert("INSERT INTO plan_rule_config(rule_key, rule_value) VALUES(#{ruleKey}, #{ruleValue}) " +
            "ON DUPLICATE KEY UPDATE rule_value = VALUES(rule_value), update_time = NOW()")
    int upsert(@Param("ruleKey") String ruleKey, @Param("ruleValue") String ruleValue);
}
