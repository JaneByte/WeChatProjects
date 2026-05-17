SELECT COUNT(*) AS missing_detail FROM `goods` WHERE `status` = 1 AND (`detail` IS NULL OR CHAR_LENGTH(TRIM(`detail`)) < 18);
SELECT COUNT(*) AS missing_keywords FROM `goods` WHERE `status` = 1 AND (`keywords` IS NULL OR CHAR_LENGTH(TRIM(`keywords`)) = 0);
SELECT COUNT(*) AS bad_original_price FROM `goods` WHERE `status` = 1 AND (`original_price` IS NULL OR `original_price` < `price` OR `original_price` > `price` * 1.6);
SELECT COUNT(*) AS zero_sales FROM `goods` WHERE `status` = 1 AND (`sales_volume` IS NULL OR `sales_volume` <= 0);
SELECT COUNT(*) AS bad_home_sort FROM `goods` WHERE `status` = 1 AND (`home_sort` IS NULL OR `home_sort` <= 0 OR `home_sort` > 500);
SELECT COUNT(*) AS invalid_flash FROM `goods`
WHERE `status` = 1 AND `is_flash` = 1 AND (`flash_price` IS NULL OR `flash_price` <= 0 OR `flash_price` >= `price` OR `flash_start_time` IS NULL OR `flash_end_time` IS NULL OR `flash_end_time` <= `flash_start_time`);