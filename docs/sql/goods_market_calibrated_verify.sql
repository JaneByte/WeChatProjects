-- 校验推荐与秒杀是否在合理区间
SELECT COUNT(*) AS total_on_sale FROM `goods` WHERE `status` = 1;
SELECT COUNT(*) AS recommend_count FROM `goods` WHERE `status` = 1 AND `is_recommend` = 1;
SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM `goods` WHERE `status` = 1), 0), 2) AS recommend_ratio_pct
FROM `goods` WHERE `status` = 1 AND `is_recommend` = 1;

SELECT COUNT(*) AS flash_count FROM `goods` WHERE `status` = 1 AND `is_flash` = 1;
SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM `goods` WHERE `status` = 1), 0), 2) AS flash_ratio_pct
FROM `goods` WHERE `status` = 1 AND `is_flash` = 1;

SELECT COUNT(*) AS invalid_flash_count
FROM `goods`
WHERE `status` = 1 AND `is_flash` = 1 AND (
  `flash_price` IS NULL OR `flash_price` <= 0 OR `flash_price` >= `price`
  OR `flash_start_time` IS NULL OR `flash_end_time` IS NULL OR `flash_end_time` <= `flash_start_time`
  OR `flash_stock` IS NULL OR `flash_stock` <= 0
);

SELECT COUNT(*) AS recommend_but_low_stock
FROM `goods`
WHERE `status` = 1 AND `is_recommend` = 1 AND `stock` < 20;