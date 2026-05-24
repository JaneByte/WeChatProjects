package com.example.freshtime.mapper;

import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.GoodsSku;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CartMapper {

    String CART_COLUMNS = "id, user_id, goods_id, sku_id, quantity, selected, source_type, source_plan_id, source_scene";
    String GOODS_COLUMNS = "id, category_id, name, main_image, images, detail, price, original_price, stock, unit, " +
            "sales_volume, is_recommend, is_flash, flash_price, flash_start_time, flash_end_time, flash_stock, " +
            "home_sort, show_in_home, status, origin, keywords, create_time";

    String SKU_COLUMNS = "id, goods_id, sku_name, sku_weight_g, sku_price, sku_stock, status, sort";

    @Select("SELECT c.id, c.user_id AS user_id, c.goods_id AS goods_id, " +
            "c.sku_id AS sku_id, c.quantity, c.selected, c.source_type AS source_type, c.source_plan_id AS source_plan_id, c.source_scene AS source_scene, g.name, g.main_image AS image, s.sku_price AS price, " +
            "s.sku_stock AS stock, g.unit, s.sku_name AS sku_name, s.sku_weight_g AS sku_weight_g, g.status, g.origin, " +
            "g.price AS goods_price, g.is_flash AS is_flash, g.flash_price AS flash_price, g.flash_start_time AS flash_start_time, " +
            "g.flash_end_time AS flash_end_time, g.flash_stock AS flash_stock " +
            "FROM cart c LEFT JOIN goods g ON g.id = c.goods_id " +
            "LEFT JOIN goods_sku s ON s.id = c.sku_id " +
            "WHERE c.user_id = #{userId} ORDER BY c.id DESC")
    List<CartInfo> selectCartListByUserId(@Param("userId") Long userId);

    @Select("SELECT c.id, c.user_id AS user_id, c.goods_id AS goods_id, " +
            "c.sku_id AS sku_id, c.quantity, c.selected, g.name, g.main_image AS image, s.sku_price AS price, " +
            "s.sku_stock AS stock, g.unit, s.sku_name AS sku_name, s.sku_weight_g AS sku_weight_g, g.status, g.origin, " +
            "g.price AS goods_price, g.is_flash AS is_flash, g.flash_price AS flash_price, g.flash_start_time AS flash_start_time, " +
            "g.flash_end_time AS flash_end_time, g.flash_stock AS flash_stock " +
            "FROM cart c LEFT JOIN goods g ON g.id = c.goods_id " +
            "LEFT JOIN goods_sku s ON s.id = c.sku_id " +
            "WHERE c.user_id = #{userId} ORDER BY c.id DESC")
    List<CartInfo> selectCartListBasicByUserId(@Param("userId") Long userId);

    @Select("SELECT " + CART_COLUMNS + " FROM cart WHERE user_id = #{userId} AND goods_id = #{goodsId} AND sku_id = #{skuId} LIMIT 1")
    CartInfo selectCartByUserIdAndGoodsIdAndSkuId(@Param("userId") Long userId,
                                                   @Param("goodsId") Long goodsId,
                                                   @Param("skuId") Long skuId);

    @Select("SELECT id, user_id, goods_id, sku_id, quantity, selected FROM cart WHERE user_id = #{userId} AND goods_id = #{goodsId} AND sku_id = #{skuId} LIMIT 1")
    CartInfo selectCartBasicByUserIdAndGoodsIdAndSkuId(@Param("userId") Long userId,
                                                        @Param("goodsId") Long goodsId,
                                                        @Param("skuId") Long skuId);

    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE id = #{goodsId} LIMIT 1")
    Goods selectGoodsById(@Param("goodsId") Long goodsId);

    @Select("SELECT " + SKU_COLUMNS + " FROM goods_sku WHERE id = #{skuId} LIMIT 1")
    GoodsSku selectSkuById(@Param("skuId") Long skuId);

    @Select("SELECT " + SKU_COLUMNS + " FROM goods_sku WHERE goods_id = #{goodsId} AND status = 1 AND sku_stock > 0 ORDER BY sort ASC, id ASC LIMIT 1")
    GoodsSku selectFirstAvailableSkuByGoodsId(@Param("goodsId") Long goodsId);

    @Insert("INSERT INTO cart(user_id, goods_id, sku_id, quantity, selected, source_type, source_plan_id, source_scene) " +
            "VALUES(#{userId}, #{goodsId}, #{skuId}, #{quantity}, #{selected}, #{sourceType}, #{sourcePlanId}, #{sourceScene})")
    int insertCart(CartInfo cartInfo);

    @Insert("INSERT INTO cart(user_id, goods_id, sku_id, quantity, selected) " +
            "VALUES(#{userId}, #{goodsId}, #{skuId}, #{quantity}, #{selected})")
    int insertCartBasic(CartInfo cartInfo);

    @Update("UPDATE cart SET quantity = #{quantity}, selected = #{selected}, source_type = #{sourceType}, source_plan_id = #{sourcePlanId}, source_scene = #{sourceScene} WHERE id = #{id}")
    int updateCart(CartInfo cartInfo);

    @Update("UPDATE cart SET quantity = #{quantity}, selected = #{selected} WHERE id = #{id}")
    int updateCartBasic(CartInfo cartInfo);

    @Update("UPDATE cart SET selected = #{selected} WHERE user_id = #{userId} AND goods_id = #{goodsId} AND sku_id = #{skuId}")
    int updateSelectedByUserIdAndGoodsId(@Param("userId") Long userId,
                                         @Param("goodsId") Long goodsId,
                                         @Param("skuId") Long skuId,
                                         @Param("selected") Integer selected);

    @Update("UPDATE cart SET selected = #{selected} WHERE user_id = #{userId}")
    int updateSelectedByUserId(@Param("userId") Long userId, @Param("selected") Integer selected);

    @Delete("DELETE FROM cart WHERE user_id = #{userId} AND goods_id = #{goodsId} AND sku_id = #{skuId}")
    int deleteByUserIdAndGoodsId(@Param("userId") Long userId,
                                 @Param("goodsId") Long goodsId,
                                 @Param("skuId") Long skuId);

    @Delete("DELETE FROM cart WHERE user_id = #{userId} AND selected = 1")
    int deleteSelectedByUserId(@Param("userId") Long userId);

    @Delete("DELETE FROM cart WHERE user_id = #{userId}")
    int deleteAllByUserId(@Param("userId") Long userId);
}
