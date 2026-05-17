SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 市场校准补丁：重点优化推荐与秒杀策略
-- 说明：仅UPDATE，不改结构不删数据

-- A. 先清理无效推荐/无效秒杀
UPDATE `goods`
SET `is_recommend` = 0
WHERE `status` <> 1 OR `stock` <= 0;

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

-- B. 推荐策略（先清0再精细打标）
UPDATE `goods`
SET `is_recommend` = 0
WHERE `status` = 1;

-- B1: 基础爆款（销量+库存+价格区间+首页排序）
UPDATE `goods`
SET `is_recommend` = 1
WHERE `status` = 1
  AND `stock` >= 80
  AND `sales_volume` >= 350
  AND `price` BETWEEN 6 AND 38
  AND `home_sort` BETWEEN 1 AND 45;

-- B2: 当季优先（当前按春夏交替场景关键词）
UPDATE `goods`
SET `is_recommend` = 1
WHERE `status` = 1
  AND `stock` >= 60
  AND (
    `name` LIKE '%草莓%'
    OR `name` LIKE '%枇杷%'
    OR `name` LIKE '%樱桃%'
    OR `name` LIKE '%豌豆%'
    OR `name` LIKE '%春笋%'
    OR `keywords` LIKE '%时令%'
    OR `keywords` LIKE '%夏季%'
    OR `keywords` LIKE '%清甜%'
  )
  AND `price` BETWEEN 5 AND 45;

-- B3: 高价低动销不推荐（保留极少数高端高销量）
UPDATE `goods`
SET `is_recommend` = 0
WHERE `status` = 1
  AND `price` >= 55
  AND `sales_volume` < 700;

-- C. 秒杀策略（严格筛选，避免“全是秒杀”）
-- C1: 先关闭历史秒杀，再按规则重建
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `status` = 1;

-- C2: 仅为“中价位+稳定库存+有动销”的商品开启秒杀
UPDATE `goods`
SET `is_flash` = 1,
    `flash_price` = ROUND(`price` * (
      CASE
        WHEN `price` <= 10 THEN 0.90
        WHEN `price` <= 20 THEN 0.88
        WHEN `price` <= 35 THEN 0.86
        ELSE 0.84
      END
    ), 2),
    `flash_start_time` = NOW(),
    `flash_end_time` = DATE_ADD(NOW(), INTERVAL 2 DAY),
    `flash_stock` = LEAST(GREATEST(FLOOR(`stock` * 0.25), 12), `stock`)
WHERE `status` = 1
  AND `stock` BETWEEN 70 AND 320
  AND `sales_volume` BETWEEN 140 AND 1400
  AND `price` BETWEEN 6 AND 36
  AND `is_recommend` = 1
  AND (`category_id` IN (3,4,5,6,7,8,9,11,12,13,14,15))
  AND MOD(`id`, 6) = 0;

-- C3: 推荐与秒杀冲突兜底（避免秒杀折后价反超）
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `is_flash` = 1
  AND (`flash_price` IS NULL OR `flash_price` <= 0 OR `flash_price` >= `price`);

SET FOREIGN_KEY_CHECKS = 1;