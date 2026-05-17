SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 秒杀活动增强补丁：细化活动场次、筛选条件与库存配比

-- 1) 关闭历史不合理秒杀
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `is_flash` = 1
  AND (
    `status` <> 1
    OR `stock` <= 0
    OR `flash_price` IS NULL
    OR `flash_price` <= 0
    OR `flash_price` >= `price`
    OR `flash_start_time` IS NULL
    OR `flash_end_time` IS NULL
    OR `flash_end_time` <= `flash_start_time`
  );

-- 2) 全量重排当日秒杀池（先清）
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `status` = 1;

-- 3) 规则化开启：仅“可推荐、库存稳、销量稳、价格适中、品类适合”的商品入池
-- 上午场（09:00-12:00）
UPDATE `goods`
SET `is_flash` = 1,
    `flash_price` = ROUND(`price` * (
      CASE
        WHEN `price` <= 10 THEN 0.92
        WHEN `price` <= 20 THEN 0.89
        WHEN `price` <= 35 THEN 0.86
        ELSE 0.84
      END
    ), 2),
    `flash_start_time` = CONCAT(CURDATE(), ' 09:00:00'),
    `flash_end_time` = CONCAT(CURDATE(), ' 12:00:00'),
    `flash_stock` = LEAST(GREATEST(FLOOR(`stock` * 0.22), 10), `stock`)
WHERE `status` = 1
  AND `is_recommend` = 1
  AND `stock` BETWEEN 90 AND 380
  AND `sales_volume` BETWEEN 180 AND 1800
  AND `price` BETWEEN 6 AND 32
  AND `category_id` IN (3,4,5,6,7,8,9,11,12,13,14,15)
  AND MOD(`id`, 7) = 1;

-- 晚间场（19:00-22:00）
UPDATE `goods`
SET `is_flash` = 1,
    `flash_price` = ROUND(`price` * (
      CASE
        WHEN `price` <= 10 THEN 0.90
        WHEN `price` <= 20 THEN 0.87
        WHEN `price` <= 35 THEN 0.85
        ELSE 0.83
      END
    ), 2),
    `flash_start_time` = CONCAT(CURDATE(), ' 19:00:00'),
    `flash_end_time` = CONCAT(CURDATE(), ' 22:00:00'),
    `flash_stock` = LEAST(GREATEST(FLOOR(`stock` * 0.28), 12), `stock`)
WHERE `status` = 1
  AND `is_recommend` = 1
  AND `stock` BETWEEN 80 AND 360
  AND `sales_volume` BETWEEN 220 AND 2200
  AND `price` BETWEEN 6 AND 36
  AND `category_id` IN (3,4,5,6,7,8,9,11,12,13,14,15)
  AND MOD(`id`, 7) = 3;

-- 4) 秒杀价安全兜底
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `is_flash` = 1 AND (
  `flash_price` IS NULL
  OR `flash_price` <= 0
  OR `flash_price` >= `price`
  OR `flash_stock` IS NULL
  OR `flash_stock` <= 0
  OR `flash_stock` > `stock`
  OR `flash_end_time` <= `flash_start_time`
);

SET FOREIGN_KEY_CHECKS = 1;