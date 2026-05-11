package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

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
            "ORDER BY flash_end_time ASC, home_sort ASC, flash_price ASC, sales_volume DESC LIMIT #{limit}")
    List<Goods> selectFlashSaleList(@Param("now") LocalDateTime now, @Param("limit") Integer limit);

    @Select("SELECT id, title, image, link_type AS linkType, link_value AS linkValue " +
            "FROM banner WHERE status = 1 ORDER BY sort ASC, create_time DESC LIMIT #{limit}")
    List<Map<String, Object>> selectActiveBanners(@Param("limit") Integer limit);

    @Select("SELECT id, notice_text AS text, link_type AS linkType, link_value AS linkValue " +
            "FROM home_notice WHERE status = 1 ORDER BY sort ASC, create_time DESC LIMIT #{limit}")
    List<Map<String, Object>> selectActiveNotices(@Param("limit") Integer limit);

    @Select("SELECT nav_type AS type, nav_text AS text, icon_text AS iconText, link_type AS linkType, link_value AS linkValue " +
            "FROM home_nav WHERE status = 1 ORDER BY sort ASC, create_time DESC LIMIT #{limit}")
    List<Map<String, Object>> selectActiveNavList(@Param("limit") Integer limit);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND create_time >= #{sinceTime}")
    Integer countNewArrivals(@Param("sinceTime") LocalDateTime sinceTime);

    @Select("SELECT id, name, main_image AS mainImage, price, unit, create_time AS createTime " +
            "FROM goods WHERE status = 1 AND show_in_home = 1 " +
            "ORDER BY create_time DESC LIMIT #{limit}")
    List<Map<String, Object>> selectNewArrivalList(@Param("limit") Integer limit);

    @Select("SELECT * FROM goods " +
            "WHERE status = 1 AND show_in_home = 1 " +
            "ORDER BY sales_volume DESC, home_sort ASC, create_time DESC " +
            "LIMIT #{offset}, #{pageSize}")
    List<Goods> selectHomeGoodsPage(@Param("offset") Integer offset, @Param("pageSize") Integer pageSize);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND show_in_home = 1")
    Integer countHomeGoods();

    @Select("SELECT * FROM goods " +
            "WHERE status = 1 AND show_in_home = 1 AND stock > 0 AND " +
            "(name LIKE CONCAT('%', #{keyword}, '%') OR keywords LIKE CONCAT('%', #{keyword}, '%')) " +
            "ORDER BY sales_volume DESC, home_sort ASC, create_time DESC LIMIT #{limit}")
    List<Goods> selectRecommendGoodsByKeyword(@Param("keyword") String keyword, @Param("limit") Integer limit);
}
