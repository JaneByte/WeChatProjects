SELECT COUNT(*) AS flash_count FROM `goods` WHERE `status`=1 AND `is_flash`=1;
SELECT ROUND(COUNT(*) * 100.0 / NULLIF((SELECT COUNT(*) FROM `goods` WHERE `status`=1), 0), 2) AS flash_ratio_pct
FROM `goods` WHERE `status`=1 AND `is_flash`=1;

SELECT `id`,`name`,`price`,`flash_price`,`stock`,`flash_stock`,`flash_start_time`,`flash_end_time`
FROM `goods`
WHERE `status`=1 AND `is_flash`=1
ORDER BY `flash_start_time`,`id`
LIMIT 50;

SELECT COUNT(*) AS invalid_flash
FROM `goods`
WHERE `status`=1 AND `is_flash`=1 AND (
  `flash_price` IS NULL OR `flash_price`<=0 OR `flash_price`>=`price`
  OR `flash_stock` IS NULL OR `flash_stock`<=0 OR `flash_stock`>`stock`
  OR `flash_start_time` IS NULL OR `flash_end_time` IS NULL OR `flash_end_time`<=`flash_start_time`
);