package com.example.freshtime.mapper;

import com.example.freshtime.entity.GoodsSku;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface GoodsSkuMapper {

    String SKU_COLUMNS = "id, goods_id, sku_name, sku_weight_g, sku_price, sku_stock, status, sort, spec_type, spec_value";

    @Select("SELECT " + SKU_COLUMNS + " FROM goods_sku WHERE goods_id = #{goodsId} AND status = 1 ORDER BY sort ASC, id ASC")
    List<GoodsSku> selectListByGoodsId(@Param("goodsId") Long goodsId);

    @Select("SELECT " + SKU_COLUMNS + " FROM goods_sku WHERE id = #{skuId} LIMIT 1")
    GoodsSku selectById(@Param("skuId") Long skuId);

    @Select("SELECT " + SKU_COLUMNS + " FROM goods_sku WHERE id = #{skuId} FOR UPDATE")
    GoodsSku selectByIdForUpdate(@Param("skuId") Long skuId);

    @Update("UPDATE goods_sku SET sku_stock = sku_stock - #{quantity} WHERE id = #{skuId} AND sku_stock >= #{quantity}")
    int deductSkuStock(@Param("skuId") Long skuId, @Param("quantity") Integer quantity);

    @Update("UPDATE goods_sku SET sku_stock = sku_stock + #{quantity} WHERE id = #{skuId}")
    int restoreSkuStock(@Param("skuId") Long skuId, @Param("quantity") Integer quantity);
}
