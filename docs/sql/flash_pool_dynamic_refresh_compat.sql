SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 兼容版动态秒杀池刷新（不创建存储过程，直接执行）
-- 可调整目标数量
SET @target_count := 18;

UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `status` = 1;

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

DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pick`;
CREATE TEMPORARY TABLE `tmp_flash_pick` AS
SELECT t.* FROM (
  SELECT c.*, (@rn := @rn + 1) AS rn
  FROM `tmp_flash_candidates` c, (SELECT @rn := 0) r
  ORDER BY c.`score` DESC, RAND()
) t
WHERE t.rn <= @target_count;

SET @picked_count := (SELECT COUNT(1) FROM `tmp_flash_pick`);
SET @need_count := GREATEST(@target_count - @picked_count, 0);

DROP TEMPORARY TABLE IF EXISTS `tmp_flash_fill`;
CREATE TEMPORARY TABLE `tmp_flash_fill` AS
SELECT z.* FROM (
  SELECT
    g.`id`, g.`price`, g.`stock`, g.`sales_volume`, 5 AS `score`,
    (@rn2 := @rn2 + 1) AS rn
  FROM `goods` g, (SELECT @rn2 := 0) r2
  WHERE g.`status` = 1
    AND g.`stock` > 0
    AND g.`price` BETWEEN 4 AND 48
    AND g.`id` NOT IN (SELECT `id` FROM `tmp_flash_pick`)
  ORDER BY g.`sales_volume` DESC, RAND()
) z
WHERE z.rn <= @need_count;

INSERT INTO `tmp_flash_pick` (`id`,`price`,`stock`,`sales_volume`,`score`,`rn`)
SELECT `id`,`price`,`stock`,`sales_volume`,`score`, 99999
FROM `tmp_flash_fill`;

DROP TEMPORARY TABLE IF EXISTS `tmp_flash_rank`;
CREATE TEMPORARY TABLE `tmp_flash_rank` AS
SELECT q.`id`, (@rnk := @rnk + 1) AS rn
FROM (SELECT `id` FROM `tmp_flash_pick` ORDER BY `score` DESC, RAND()) q, (SELECT @rnk := 0) x;

UPDATE `goods` g
JOIN `tmp_flash_rank` t ON t.`id` = g.`id`
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
    WHEN t.`rn` <= CEIL(@target_count / 2) THEN CONCAT(CURDATE(), ' 09:00:00')
    ELSE CONCAT(CURDATE(), ' 19:00:00')
  END,
  g.`flash_end_time` = CASE
    WHEN t.`rn` <= CEIL(@target_count / 2) THEN CONCAT(CURDATE(), ' 12:00:00')
    ELSE CONCAT(CURDATE(), ' 22:00:00')
  END;

UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `is_flash` = 1
  AND (
    `flash_price` IS NULL OR `flash_price` <= 0 OR `flash_price` >= `price`
    OR `flash_stock` IS NULL OR `flash_stock` <= 0 OR `flash_stock` > `stock`
    OR `flash_start_time` IS NULL OR `flash_end_time` IS NULL OR `flash_end_time` <= `flash_start_time`
  );

DROP TEMPORARY TABLE IF EXISTS `tmp_flash_candidates`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pick`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_fill`;
DROP TEMPORARY TABLE IF EXISTS `tmp_flash_rank`;

SET FOREIGN_KEY_CHECKS = 1;