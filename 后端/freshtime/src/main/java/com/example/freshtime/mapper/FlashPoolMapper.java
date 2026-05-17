package com.example.freshtime.mapper;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface FlashPoolMapper {

    @Select("CALL refresh_flash_pool(#{targetCount})")
    void refreshFlashPool(Integer targetCount);

    @Select("SELECT COUNT(1) FROM goods WHERE status = 1 AND is_flash = 1 AND (" +
            "flash_price IS NULL OR flash_price <= 0 OR flash_price >= price " +
            "OR flash_stock IS NULL OR flash_stock <= 0 OR flash_stock > stock " +
            "OR flash_start_time IS NULL OR flash_end_time IS NULL OR flash_end_time <= flash_start_time)")
    Integer countInvalidFlashGoods();
}

