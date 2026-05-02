package com.example.freshtime.mapper;

import com.example.freshtime.entity.CommentInfo;
import com.example.freshtime.entity.OrderInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CommentMapper {

    @Select("SELECT * FROM `order` WHERE id = #{orderId} AND user_id = #{userId} LIMIT 1")
    OrderInfo selectOrderByIdAndUserId(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Select("SELECT COUNT(1) FROM order_item WHERE order_id = #{orderId} AND goods_id = #{goodsId}")
    int countOrderItem(@Param("orderId") Long orderId, @Param("goodsId") Long goodsId);

    @Select("SELECT COUNT(1) FROM comment WHERE user_id = #{userId} AND order_id = #{orderId} AND goods_id = #{goodsId}")
    int countDuplicateComment(@Param("userId") Long userId,
                              @Param("orderId") Long orderId,
                              @Param("goodsId") Long goodsId);

    @Insert("INSERT INTO comment(order_id, user_id, goods_id, merchant_id, rating, content) " +
            "VALUES(#{orderId}, #{userId}, #{goodsId}, #{merchantId}, #{rating}, #{content})")
    int insertComment(CommentInfo commentInfo);
}

