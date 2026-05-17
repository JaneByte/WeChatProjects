package com.example.freshtime.mapper;

import com.example.freshtime.entity.ScenePack;
import com.example.freshtime.entity.ScenePackItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface ScenePackMapper {

    @Select("SELECT id, name, scene_type, pack_mode, cover_image, summary, price, original_price, stock, " +
            "coupon_threshold_hint, status, sort " +
            "FROM scene_pack WHERE status = 1 AND scene_type = #{sceneType} ORDER BY sort ASC, id DESC LIMIT #{limit}")
    List<ScenePack> selectActiveBySceneType(@Param("sceneType") String sceneType, @Param("limit") Integer limit);

    @Select("SELECT spi.id, spi.pack_id, spi.goods_id, spi.sku_id, spi.quantity, spi.item_role, spi.sort, " +
            "g.name AS goods_name, g.main_image AS goods_image, s.sku_name, s.sku_weight_g " +
            "FROM scene_pack_item spi " +
            "LEFT JOIN goods g ON g.id = spi.goods_id " +
            "LEFT JOIN goods_sku s ON s.id = spi.sku_id " +
            "WHERE spi.pack_id = #{packId} ORDER BY spi.sort ASC, spi.id ASC")
    List<ScenePackItem> selectItemsByPackId(@Param("packId") Long packId);
}

