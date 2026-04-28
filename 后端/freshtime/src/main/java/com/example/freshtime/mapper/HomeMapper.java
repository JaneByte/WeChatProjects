package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.HomeOriginCard;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;

@Mapper
public interface HomeMapper {

    @Select("SELECT * FROM goods " +
            "WHERE status = 1 AND show_in_home = 1 AND is_recommend = 1 " +
            "ORDER BY home_sort ASC, sales_volume DESC, create_time DESC LIMIT 1")
    Goods selectTodayRecommend();

    @Select("SELECT * FROM goods " +
            "WHERE status = 1 AND is_flash = 1 AND flash_stock > 0 " +
            "AND flash_start_time IS NOT NULL AND flash_end_time IS NOT NULL " +
            "AND flash_start_time <= #{now} AND flash_end_time >= #{now} " +
            "ORDER BY home_sort ASC, flash_price ASC, create_time DESC LIMIT #{limit}")
    List<Goods> selectFlashSaleList(@Param("now") LocalDateTime now, @Param("limit") Integer limit);

    @Select("SELECT * FROM home_origin_card WHERE status = 1 ORDER BY sort ASC, create_time DESC LIMIT #{limit}")
    List<HomeOriginCard> selectOriginCards(@Param("limit") Integer limit);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND create_time >= #{sinceTime}")
    Integer countNewArrivals(@Param("sinceTime") LocalDateTime sinceTime);

    @Select("SELECT * FROM goods " +
            "WHERE status = 1 AND show_in_home = 1 " +
            "ORDER BY home_sort ASC, sales_volume DESC, create_time DESC " +
            "LIMIT #{offset}, #{pageSize}")
    List<Goods> selectHomeGoodsPage(@Param("offset") Integer offset, @Param("pageSize") Integer pageSize);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND show_in_home = 1")
    Integer countHomeGoods();
}
