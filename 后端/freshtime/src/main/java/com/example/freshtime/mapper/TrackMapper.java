package com.example.freshtime.mapper;

import com.example.freshtime.entity.Goods;
import com.example.freshtime.entity.TrackEventLog;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface TrackMapper {

    String GOODS_COLUMNS = "id, category_id, name, main_image, images, detail, price, original_price, stock, unit, " +
            "sales_volume, is_recommend, is_flash, flash_price, flash_start_time, flash_end_time, flash_stock, " +
            "home_sort, show_in_home, status, origin, keywords, create_time";

    @Insert("INSERT INTO track_event_log(user_id, event_name, payload) VALUES(#{userId}, #{eventName}, #{payload})")
    int insertTrackEvent(TrackEventLog log);

    @Select("SELECT " + GOODS_COLUMNS + " FROM goods WHERE status = 1 AND show_in_home = 1 AND stock > 0 AND (name LIKE CONCAT('%', #{keyword}, '%') OR keywords LIKE CONCAT('%', #{keyword}, '%')) ORDER BY sales_volume DESC, home_sort ASC, create_time DESC LIMIT #{limit}")
    List<Goods> selectRecommendGoodsByKeyword(@Param("keyword") String keyword, @Param("limit") Integer limit);
}
