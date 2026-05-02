package com.example.freshtime.mapper;

import com.example.freshtime.entity.CartInfo;
import com.example.freshtime.entity.Goods;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

import java.util.List;

@Mapper
public interface CartMapper {

    @Select("SELECT c.id, c.user_id AS user_id, c.goods_id AS goods_id, c.merchant_id AS merchant_id, " +
            "c.quantity, c.selected, c.create_time AS create_time, g.name, g.main_image AS image, g.price, " +
            "g.stock, g.unit, g.status, g.origin " +
            "FROM cart c LEFT JOIN goods g ON g.id = c.goods_id " +
            "WHERE c.user_id = #{userId} ORDER BY c.id DESC")
    List<CartInfo> selectCartListByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM cart WHERE user_id = #{userId} AND goods_id = #{goodsId} LIMIT 1")
    CartInfo selectCartByUserIdAndGoodsId(@Param("userId") Long userId, @Param("goodsId") Long goodsId);

    @Select("SELECT * FROM goods WHERE id = #{goodsId} LIMIT 1")
    Goods selectGoodsById(@Param("goodsId") Long goodsId);

    @Insert("INSERT INTO cart(user_id, goods_id, merchant_id, quantity, selected) " +
            "VALUES(#{userId}, #{goodsId}, #{merchantId}, #{quantity}, #{selected})")
    int insertCart(CartInfo cartInfo);

    @Update("UPDATE cart SET quantity = #{quantity}, selected = #{selected} WHERE id = #{id}")
    int updateCart(CartInfo cartInfo);

    @Update("UPDATE cart SET selected = #{selected} WHERE user_id = #{userId} AND goods_id = #{goodsId}")
    int updateSelectedByUserIdAndGoodsId(@Param("userId") Long userId,
                                         @Param("goodsId") Long goodsId,
                                         @Param("selected") Integer selected);

    @Update("UPDATE cart SET selected = #{selected} WHERE user_id = #{userId}")
    int updateSelectedByUserId(@Param("userId") Long userId, @Param("selected") Integer selected);

    @Delete("DELETE FROM cart WHERE user_id = #{userId} AND goods_id = #{goodsId}")
    int deleteByUserIdAndGoodsId(@Param("userId") Long userId, @Param("goodsId") Long goodsId);

    @Delete("DELETE FROM cart WHERE user_id = #{userId} AND selected = 1")
    int deleteSelectedByUserId(@Param("userId") Long userId);

    @Delete("DELETE FROM cart WHERE user_id = #{userId}")
    int deleteAllByUserId(@Param("userId") Long userId);
}
