package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import org.apache.ibatis.annotations.*;

import java.util.List;

@Mapper
public interface GoodsMapper {

    String GOODS_COLUMNS = "id, category_id, name, main_image, images, detail, price, original_price, stock, unit, " +
            "sales_volume, is_recommend, is_flash, flash_price, flash_start_time, flash_end_time, flash_stock, " +
            "home_sort, show_in_home, status, origin, keywords, season_start_month, season_end_month, season_late_threshold_days, season_early_hint, season_peak_hint, season_late_hint, create_time";

    // 根据分类ID查询商品
    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE category_id = #{categoryId} AND status = 1 ORDER BY is_recommend DESC, create_time DESC")
    List<Goods> selectByCategoryId(Long categoryId);

    // 查询推荐商品
    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE is_recommend = 1 AND status = 1 ORDER BY create_time DESC")
    List<Goods> selectRecommendList();

    // 根据ID查询商品详情
    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE id = #{id}")
    Goods selectById(Long id);

    // 搜索商品（匹配名称、关键词、产地）
    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE status = 1 AND (name LIKE CONCAT('%',#{keyword},'%') OR keywords LIKE CONCAT('%',#{keyword},'%') OR origin LIKE CONCAT('%',#{keyword},'%')) ORDER BY sales_volume DESC, is_recommend DESC, create_time DESC LIMIT #{offset}, #{pageSize}")
    List<Goods> searchByKeyword(@Param("keyword") String keyword, @Param("offset") Integer offset, @Param("pageSize") Integer pageSize);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND (name LIKE CONCAT('%',#{keyword},'%') OR keywords LIKE CONCAT('%',#{keyword},'%') OR origin LIKE CONCAT('%',#{keyword},'%'))")
    Integer countByKeyword(@Param("keyword") String keyword);

    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE status = 1 AND stock > 0 AND " +
            "(name LIKE CONCAT('%',#{sceneKeyword},'%') OR keywords LIKE CONCAT('%',#{sceneKeyword},'%')) " +
            "ORDER BY sales_volume DESC, is_recommend DESC, create_time DESC")
    List<Goods> selectBySceneKeyword(@Param("sceneKeyword") String sceneKeyword);

    @Select("SELECT g.id, g.category_id, g.name, g.main_image, g.images, g.detail, g.price, g.original_price, g.stock, g.unit, " +
            "g.sales_volume, g.is_recommend, g.is_flash, g.flash_price, g.flash_start_time, g.flash_end_time, g.flash_stock, " +
            "g.home_sort, g.show_in_home, g.status, g.origin, g.keywords, g.create_time FROM goods g " +
            "INNER JOIN goods_tag gt ON gt.goods_id = g.id " +
            "INNER JOIN tag t ON t.id = gt.tag_id " +
            "WHERE g.status = 1 AND g.stock > 0 AND t.tag_name = #{tagName} " +
            "ORDER BY g.sales_volume DESC, g.is_recommend DESC, g.create_time DESC")
    List<Goods> selectByTagName(@Param("tagName") String tagName);

    @Select("<script>" +
            "SELECT " + GOODS_COLUMNS + " FROM goods WHERE 1 = 1 " +
            "<if test='keyword != null and keyword != \"\"'> " +
            "AND (name LIKE CONCAT('%',#{keyword},'%') OR keywords LIKE CONCAT('%',#{keyword},'%') OR origin LIKE CONCAT('%',#{keyword},'%')) " +
            "</if>" +
            "<if test='status != null'> AND status = #{status} </if>" +
            "<if test='categoryId != null'> AND category_id = #{categoryId} </if>" +
            "ORDER BY create_time DESC" +
            "</script>")
    List<Goods> selectAdminGoodsList(@Param("keyword") String keyword,
                                     @Param("status") Integer status,
                                     @Param("categoryId") Long categoryId);

    @Insert("INSERT INTO goods(category_id, name, main_image, images, detail, price, original_price, stock, unit, sales_volume, " +
            "is_recommend, is_flash, flash_price, flash_start_time, flash_end_time, flash_stock, home_sort, show_in_home, status, origin, keywords, season_start_month, season_end_month, season_late_threshold_days, season_early_hint, season_peak_hint, season_late_hint) " +
            "VALUES(#{categoryId}, #{name}, #{mainImage}, #{images}, #{detail}, #{price}, #{originalPrice}, #{stock}, #{unit}, #{salesVolume}, " +
            "#{isRecommend}, #{isFlash}, #{flashPrice}, #{flashStartTime}, #{flashEndTime}, #{flashStock}, #{homeSort}, #{showInHome}, #{status}, #{origin}, #{keywords}, #{seasonStartMonth}, #{seasonEndMonth}, #{seasonLateThresholdDays}, #{seasonEarlyHint}, #{seasonPeakHint}, #{seasonLateHint})")
    @Options(useGeneratedKeys = true, keyProperty = "id")
    int insertGoods(Goods goods);

    @Update("UPDATE goods SET category_id = #{categoryId}, name = #{name}, main_image = #{mainImage}, images = #{images}, " +
            "detail = #{detail}, price = #{price}, original_price = #{originalPrice}, stock = #{stock}, unit = #{unit}, is_recommend = #{isRecommend}, " +
            "is_flash = #{isFlash}, flash_price = #{flashPrice}, flash_start_time = #{flashStartTime}, flash_end_time = #{flashEndTime}, flash_stock = #{flashStock}, " +
            "home_sort = #{homeSort}, show_in_home = #{showInHome}, status = #{status}, origin = #{origin}, keywords = #{keywords}, " +
            "season_start_month = #{seasonStartMonth}, season_end_month = #{seasonEndMonth}, season_late_threshold_days = #{seasonLateThresholdDays}, " +
            "season_early_hint = #{seasonEarlyHint}, season_peak_hint = #{seasonPeakHint}, season_late_hint = #{seasonLateHint} WHERE id = #{id}")
    int updateGoods(Goods goods);

    @Update("UPDATE goods SET status = #{status} WHERE id = #{id}")
    int updateGoodsStatus(@Param("id") Long id, @Param("status") Integer status);

    @Select("SELECT COUNT(1) FROM goods")
    Integer countAllGoods();

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1")
    Integer countOnSaleGoods();

    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE status = 1 AND stock > 0 ORDER BY is_recommend DESC, sales_volume DESC, create_time DESC LIMIT #{limit}")
    List<Goods> selectOnSaleWithStockLimit(@Param("limit") Integer limit);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND is_flash = 1")
    Integer countFlashOnSaleGoods();

    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE status = 1 AND is_flash = 1 ORDER BY flash_start_time ASC, id ASC LIMIT #{limit}")
    List<Goods> selectFlashGoodsLimit(@Param("limit") Integer limit);

}
