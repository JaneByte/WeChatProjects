SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- MySQL兼容安全版：动态秒杀池刷新（无存储过程）
-- 适配点：不使用过程变量LIMIT表达式、不在DELETE中重开同一临时表

SET @target_count := 18;

-- 1) 清空在售商品秒杀状态
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `status` = 1;

-- 2) 候选池（强条件）
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_candidates`;
CREATE TEMPORARY TABLE `tmp_flash_candidates` AS
SELECT
  g.`id`, g.`price`, g.`stock`, g.`sales_volume`,
  (
    (CASE WHEN g.`is_recommend` = 1 THEN 18 ELSE 0 END) +
    (CASE WHEN g.`price` BETWEEN 6 AND 36 THEN 20 ELSE 0 END) +
    (CASE WHEN g.`stock` BETWEEN 70 AND 360 THEN 24 ELSE 0 END) +
    (CASE WHEN g.`sales_volume` BETWEEN 180 AND 2200 THEN 22 ELSE 0 END) +
    (CASE WHEN g.`keywords` LIKE '%时令%' OR g.`keywords` LIKE '%夏季%' OR g.`keywords` LIKE '%清甜%' THEN 10 ELSE 0 END)
  ) AS `score`
FROM `goods` g
WHERE g.`status` = 1
  AND g.`stock` > 0
  AND g.`price` BETWEEN 5 AND 42
  AND g.`sales_volume` >= 80
  AND g.`category_id` IN (3,4,5,6,7,8,9,11,12,13,14,15);

-- 3) 兜底池（弱条件）
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_fallback`;
CREATE TEMPORARY TABLE `tmp_flash_fallback` AS
SELECT
  g.`id`, g.`price`, g.`stock`, g.`sales_volume`, 5 AS `score`
FROM `goods` g
WHERE g.`status` = 1
  AND g.`stock` > 0
  AND g.`price` BETWEEN 4 AND 48;

-- 4) 合并池并去重（同一商品取更高分）
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pool_union`;
CREATE TEMPORARY TABLE `tmp_flash_pool_union` AS
SELECT u.`id`, MAX(u.`score`) AS `score`, MAX(u.`price`) AS `price`, MAX(u.`stock`) AS `stock`, MAX(u.`sales_volume`) AS `sales_volume`
FROM (
  SELECT `id`,`price`,`stock`,`sales_volume`,`score` FROM `tmp_flash_candidates`
  UNION ALL
  SELECT `id`,`price`,`stock`,`sales_volume`,`score` FROM `tmp_flash_fallback`
) u
GROUP BY u.`id`;

-- 5) 排名并选前N（避免DELETE同表）
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_rank`;
CREATE TEMPORARY TABLE `tmp_flash_rank` AS
SELECT r.`id`, r.`price`, r.`stock`, r.`sales_volume`, r.`score`, (@rn := @rn + 1) AS rn
FROM (
  SELECT `id`,`price`,`stock`,`sales_volume`,`score`
  FROM `tmp_flash_pool_union`
  ORDER BY `score` DESC, `sales_volume` DESC, RAND()
) r, (SELECT @rn := 0) t;

DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pick`;
CREATE TEMPORARY TABLE `tmp_flash_pick` AS
SELECT `id`,`price`,`stock`,`sales_volume`,`score`,`rn`
FROM `tmp_flash_rank`
WHERE `rn` <= @target_count;

-- 6) 写入秒杀字段（分上午场/晚间场）
UPDATE `goods` g
JOIN `tmp_flash_pick` p ON p.`id` = g.`id`
SET
  g.`is_flash` = 1,
  g.`flash_price` = ROUND(g.`price` * (
    CASE
      WHEN g.`price` <= 10 THEN 0.92
      WHEN g.`price` <= 20 THEN 0.89
      WHEN g.`price` <= 35 THEN 0.86
      ELSE 0.84
    END
  ), 2),
  g.`flash_stock` = LEAST(GREATEST(FLOOR(g.`stock` * 0.25), 10), g.`stock`),
  g.`flash_start_time` = CASE
    WHEN p.`rn` <= CEIL(@target_count / 2) THEN CONCAT(CURDATE(), ' 09:00:00')
    ELSE CONCAT(CURDATE(), ' 19:00:00')
  END,
  g.`flash_end_time` = CASE
    WHEN p.`rn` <= CEIL(@target_count / 2) THEN CONCAT(CURDATE(), ' 12:00:00')
    ELSE CONCAT(CURDATE(), ' 22:00:00')
  END;

-- 7) 安全兜底
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `is_flash` = 1 AND (
  `flash_price` IS NULL OR `flash_price` <= 0 OR `flash_price` >= `price`
  OR `flash_stock` IS NULL OR `flash_stock` <= 0 OR `flash_stock` > `stock`
  OR `flash_start_time` IS NULL OR `flash_end_time` IS NULL OR `flash_end_time` <= `flash_start_time`
);

DROP TEMPORARY TABLE IF EXISTS `tmp_flash_candidates`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_fallback`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pool_union`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_rank`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pick`;

SET FOREIGN_KEY_CHECKS = 1;