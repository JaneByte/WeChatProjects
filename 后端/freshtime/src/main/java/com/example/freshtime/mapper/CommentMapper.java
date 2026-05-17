package com.example.freshtime.mapper;

import com.example.freshtime.entity.CommentInfo;
import com.example.freshtime.entity.OrderInfo;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface CommentMapper {

    @Select("SELECT id, user_id, status FROM `order` WHERE id = #{orderId} AND user_id = #{userId} LIMIT 1")
    OrderInfo selectOrderByIdAndUserId(@Param("orderId") Long orderId, @Param("userId") Long userId);

    @Select("SELECT COUNT(1) FROM order_item WHERE order_id = #{orderId} AND goods_id = #{goodsId}")
    int countOrderItem(@Param("orderId") Long orderId, @Param("goodsId") Long goodsId);

    @Select("SELECT COUNT(1) FROM comment WHERE user_id = #{userId} AND order_id = #{orderId} AND goods_id = #{goodsId}")
    int countDuplicateComment(@Param("userId") Long userId,
                              @Param("orderId") Long orderId,
                              @Param("goodsId") Long goodsId);

    @Insert("INSERT INTO comment(order_id, user_id, goods_id, rating, content) " +
            "VALUES(#{orderId}, #{userId}, #{goodsId}, #{rating}, #{content})")
    int insertComment(CommentInfo commentInfo);

    @Select("SELECT id, order_id AS orderId, user_id AS userId, goods_id AS goodsId, rating, content, images, create_time AS createTime " +
            "FROM comment WHERE goods_id = #{goodsId} ORDER BY create_time DESC LIMIT #{offset}, #{limit}")
    List<CommentInfo> selectByGoodsId(@Param("goodsId") Long goodsId,
                                      @Param("offset") Integer offset,
                                      @Param("limit") Integer limit);

    @Select("SELECT COUNT(1) FROM comment WHERE goods_id = #{goodsId}")
    int countByGoodsId(@Param("goodsId") Long goodsId);

    @Select("SELECT " +
            "COUNT(1) AS totalCount, " +
            "IFNULL(ROUND(AVG(rating), 2), 0) AS avgRating, " +
            "SUM(CASE WHEN rating = 5 THEN 1 ELSE 0 END) AS star5Count, " +
            "SUM(CASE WHEN rating = 4 THEN 1 ELSE 0 END) AS star4Count, " +
            "SUM(CASE WHEN rating = 3 THEN 1 ELSE 0 END) AS star3Count, " +
            "SUM(CASE WHEN rating = 2 THEN 1 ELSE 0 END) AS star2Count, " +
            "SUM(CASE WHEN rating = 1 THEN 1 ELSE 0 END) AS star1Count " +
            "FROM comment WHERE goods_id = #{goodsId}")
    Map<String, Object> summaryByGoodsId(@Param("goodsId") Long goodsId);

    @Select("SELECT id, order_id AS orderId, user_id AS userId, goods_id AS goodsId, rating, content, images, create_time AS createTime " +
            "FROM comment WHERE id = #{commentId} AND user_id = #{userId} LIMIT 1")
    CommentInfo selectByIdAndUserId(@Param("commentId") Long commentId, @Param("userId") Long userId);
}
