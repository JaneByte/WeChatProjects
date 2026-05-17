package com.example.freshtime.mapper;

import com.example.freshtime.entity.SkuComponent;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface SkuComponentMapper {

    @Select("SELECT id, sku_id AS skuId, component_goods_id AS componentGoodsId, component_name AS componentName, " +
            "component_weight_g AS componentWeightG, quantity, component_price AS componentPrice, sort " +
            "FROM sku_component WHERE sku_id = #{skuId} ORDER BY sort ASC, id ASC")
    List<SkuComponent> selectBySkuId(@Param("skuId") Long skuId);
}
