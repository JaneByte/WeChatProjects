package com.example.freshtime.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Insert;

import java.util.List;
import java.util.Map;

@Mapper
public interface PackPricingRuleMapper {

    @Select("SELECT rule_key AS ruleKey, rule_value AS ruleValue, description FROM pack_pricing_rule")
    List<Map<String, Object>> selectAll();

    @Insert("INSERT INTO pack_pricing_rule(rule_key, rule_value, description) VALUES(#{ruleKey}, #{ruleValue}, #{description}) "
        + "ON DUPLICATE KEY UPDATE rule_value = VALUES(rule_value), description = VALUES(description)")
    int upsert(@Param("ruleKey") String ruleKey, @Param("ruleValue") String ruleValue, @Param("description") String description);
}
