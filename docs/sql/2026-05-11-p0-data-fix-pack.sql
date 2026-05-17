-- FreshTime P0 数据完善包（最小改动，可重复执行）
-- 执行日期：2026-05-11
USE `freshtime`;

-- =========================
-- 0) 基础保障：标签存在性
-- =========================
INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 101, '时令', 2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 101 OR `tag_name` = '时令');

INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 102, '小份量', 2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 102 OR `tag_name` = '小份量');

INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 103, '搭配', 3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 103 OR `tag_name` = '搭配');

INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 104, '领券专区', 3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 104 OR `tag_name` = '领券专区');

-- =========================
-- 1) goods 主数据补齐（只修缺口）
-- =========================
UPDATE `goods`
SET `images` = CONCAT('[', CHAR(34), `main_image`, CHAR(34), ']')
WHERE (`images` IS NULL OR TRIM(`images`) = '')
  AND `main_image` IS NOT NULL
  AND TRIM(`main_image`) <> '';

UPDATE `goods`
SET `detail` = CONCAT(`name`, '｜鲜时刻严选，产地直采，冷链配送，建议尽快食用以保证最佳口感。')
WHERE `detail` IS NULL OR TRIM(`detail`) = '';

UPDATE `goods`
SET `keywords` = CONCAT(`name`, ',鲜时刻,新鲜直达')
WHERE `keywords` IS NULL OR TRIM(`keywords`) = '';

UPDATE `goods`
SET `origin` = '国产优选产区'
WHERE `origin` IS NULL OR TRIM(`origin`) = '';

UPDATE `goods`
SET `price` = 9.90
WHERE `price` IS NULL OR `price` <= 0;

UPDATE `goods`
SET `original_price` = ROUND(`price` * 1.2, 2)
WHERE `original_price` IS NULL OR `original_price` <= 0;

UPDATE `goods`
SET `stock` = 120
WHERE `stock` IS NULL OR `stock` < 0;

UPDATE `goods`
SET `unit` = '斤'
WHERE `unit` IS NULL OR TRIM(`unit`) = '';

UPDATE `goods`
SET `show_in_home` = 1
WHERE `show_in_home` IS NULL;

UPDATE `goods`
SET `status` = 1
WHERE `status` IS NULL;

-- =========================
-- 2) 秒杀字段规范
-- 规则：
-- is_flash=1 -> 必须有 flash_price/start/end/stock
-- is_flash=0 -> 清空秒杀字段
-- =========================
UPDATE `goods`
SET `is_flash` = 0
WHERE `is_flash` IS NULL;

UPDATE `goods`
SET `flash_price` = ROUND(`price` * 0.9, 2)
WHERE `is_flash` = 1 AND (`flash_price` IS NULL OR `flash_price` <= 0);

UPDATE `goods`
SET `flash_start_time` = '2026-05-11 00:00:00'
WHERE `is_flash` = 1 AND `flash_start_time` IS NULL;

UPDATE `goods`
SET `flash_end_time` = '2026-12-31 23:59:59'
WHERE `is_flash` = 1 AND `flash_end_time` IS NULL;

UPDATE `goods`
SET `flash_stock` = LEAST(`stock`, 50)
WHERE `is_flash` = 1 AND (`flash_stock` IS NULL OR `flash_stock` <= 0);

UPDATE `goods`
SET
  `flash_price` = NULL,
  `flash_start_time` = NULL,
  `flash_end_time` = NULL,
  `flash_stock` = 0
WHERE `is_flash` = 0;

-- =========================
-- 3) 商品标签映射补齐（按分类兜底）
-- =========================
-- 时令：蔬菜(3~10) + 水果(11~16)
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, 101
FROM `goods` g
WHERE g.`category_id` IN (3,4,5,6,7,8,9,10,11,12,13,14,15,16)
  AND NOT EXISTS (
    SELECT 1 FROM `goods_tag` x WHERE x.`goods_id` = g.`id` AND x.`tag_id` = 101
  );

-- 小份量：叶菜、菌菇、豆类、其他、浆果
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, 102
FROM `goods` g
WHERE g.`category_id` IN (3,6,8,10,11)
  AND NOT EXISTS (
    SELECT 1 FROM `goods_tag` x WHERE x.`goods_id` = g.`id` AND x.`tag_id` = 102
  );

-- 搭配：根茎、茄果、瓜类、豆类、花菜、仁果
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, 103
FROM `goods` g
WHERE g.`category_id` IN (4,5,7,8,9,15)
  AND NOT EXISTS (
    SELECT 1 FROM `goods_tag` x WHERE x.`goods_id` = g.`id` AND x.`tag_id` = 103
  );

-- =========================
-- 4) 快捷入口可用性（home_nav）
-- =========================
-- 领券专区
INSERT INTO `home_nav` (`title`,`icon`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT '领券专区', '', 'path', '/pages/coupon/coupon', 1, 1, NOW() FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `home_nav` WHERE `title` = '领券专区' AND `status` = 1
);

-- 时令蔬果
INSERT INTO `home_nav` (`title`,`icon`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT '时令蔬果', '', 'path', '/pages/goods/goods?scene=seasonal', 2, 1, NOW() FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `home_nav` WHERE `title` = '时令蔬果' AND `status` = 1
);

-- 小份量专区
INSERT INTO `home_nav` (`title`,`icon`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT '小份量专区', '', 'path', '/pages/goods/goods?scene=small', 3, 1, NOW() FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `home_nav` WHERE `title` = '小份量专区' AND `status` = 1
);

-- 蔬果搭配
INSERT INTO `home_nav` (`title`,`icon`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT '蔬果搭配', '', 'path', '/pages/goods/goods?scene=combo', 4, 1, NOW() FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `home_nav` WHERE `title` = '蔬果搭配' AND `status` = 1
);

-- =========================
-- 5) 执行后校验
-- =========================
-- Q1: 商品基础缺口
SELECT
  SUM(CASE WHEN `main_image` IS NULL OR TRIM(`main_image`) = '' THEN 1 ELSE 0 END) AS empty_main_image,
  SUM(CASE WHEN `images` IS NULL OR TRIM(`images`) = '' THEN 1 ELSE 0 END) AS empty_images,
  SUM(CASE WHEN `detail` IS NULL OR TRIM(`detail`) = '' THEN 1 ELSE 0 END) AS empty_detail,
  SUM(CASE WHEN `keywords` IS NULL OR TRIM(`keywords`) = '' THEN 1 ELSE 0 END) AS empty_keywords,
  SUM(CASE WHEN `origin` IS NULL OR TRIM(`origin`) = '' THEN 1 ELSE 0 END) AS empty_origin,
  SUM(CASE WHEN `price` IS NULL OR `price` <= 0 THEN 1 ELSE 0 END) AS bad_price,
  SUM(CASE WHEN `original_price` IS NULL OR `original_price` <= 0 THEN 1 ELSE 0 END) AS bad_original_price,
  SUM(CASE WHEN `stock` IS NULL OR `stock` < 0 THEN 1 ELSE 0 END) AS bad_stock,
  SUM(CASE WHEN `unit` IS NULL OR TRIM(`unit`) = '' THEN 1 ELSE 0 END) AS empty_unit
FROM `goods`
WHERE `status` = 1;

-- Q2: 秒杀可用性
SELECT
  SUM(CASE WHEN `is_flash` = 1 THEN 1 ELSE 0 END) AS flash_goods,
  SUM(CASE WHEN `is_flash` = 1 AND (`flash_price` IS NULL OR `flash_price` <= 0) THEN 1 ELSE 0 END) AS flash_no_price,
  SUM(CASE WHEN `is_flash` = 1 AND `flash_start_time` IS NULL THEN 1 ELSE 0 END) AS flash_no_start,
  SUM(CASE WHEN `is_flash` = 1 AND `flash_end_time` IS NULL THEN 1 ELSE 0 END) AS flash_no_end,
  SUM(CASE WHEN `is_flash` = 1 AND (`flash_stock` IS NULL OR `flash_stock` <= 0) THEN 1 ELSE 0 END) AS flash_no_stock
FROM `goods`
WHERE `status` = 1;

-- Q3: 快捷入口可用性
SELECT `id`, `title`, `link_type`, `link_value`, `sort`, `status`
FROM `home_nav`
WHERE `status` = 1
ORDER BY `sort`, `id`;

-- Q4: 场景标签覆盖
SELECT t.`tag_name`, COUNT(*) AS goods_count
FROM `goods_tag` gt
JOIN `tag` t ON t.`id` = gt.`tag_id`
WHERE t.`id` IN (101,102,103,104)
GROUP BY t.`tag_name`
ORDER BY t.`id`;