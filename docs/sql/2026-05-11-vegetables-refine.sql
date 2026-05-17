-- 蔬菜商品精细信息更新包（只更新，不插入）
-- 执行日期：2026-05-11
USE `freshtime`;

-- 0) 目标范围预览
SELECT COUNT(*) AS target_rows
FROM `goods`
WHERE `category_id` IN (3,4,5,6,7,8,9,10);

-- 1) 图片与详情精修（所有蔬菜都补齐）
UPDATE `goods`
SET
  `images` = CONCAT('[', CHAR(34), `main_image`, CHAR(34), ']'),
  `detail` = CONCAT(
    `name`,
    '｜鲜时刻严选当季蔬菜，产地直采，48小时内发货。适合家常快手烹饪，建议冷藏保存并尽快食用。'
  ),
  `show_in_home` = 1,
  `status` = 1
WHERE `category_id` IN (3,4,5,6,7,8,9,10);

-- 2) 关键词与产地兜底（仅空值回填）
UPDATE `goods`
SET `keywords` = CONCAT(`name`, ',新鲜蔬菜,当季直采,鲜时刻')
WHERE `category_id` IN (3,4,5,6,7,8,9,10)
  AND (`keywords` IS NULL OR TRIM(`keywords`) = '');

UPDATE `goods`
SET `origin` = CASE
  WHEN `category_id` = 3 THEN '山东'
  WHEN `category_id` = 4 THEN '河南'
  WHEN `category_id` = 5 THEN '云南'
  WHEN `category_id` = 6 THEN '福建'
  WHEN `category_id` = 7 THEN '海南'
  WHEN `category_id` = 8 THEN '广西'
  WHEN `category_id` = 9 THEN '云南'
  ELSE '山东'
END
WHERE `category_id` IN (3,4,5,6,7,8,9,10)
  AND (`origin` IS NULL OR TRIM(`origin`) = '');

-- 3) 价格与库存区间校正（仅异常值回填，不覆盖已有正常值）
UPDATE `goods`
SET
  `price` = CASE
    WHEN `category_id` = 3 THEN 5.80
    WHEN `category_id` = 4 THEN 6.80
    WHEN `category_id` = 5 THEN 7.80
    WHEN `category_id` = 6 THEN 9.80
    WHEN `category_id` = 7 THEN 6.20
    WHEN `category_id` = 8 THEN 8.60
    WHEN `category_id` = 9 THEN 7.20
    ELSE 6.60
  END,
  `original_price` = ROUND(CASE
    WHEN `category_id` = 3 THEN 5.80
    WHEN `category_id` = 4 THEN 6.80
    WHEN `category_id` = 5 THEN 7.80
    WHEN `category_id` = 6 THEN 9.80
    WHEN `category_id` = 7 THEN 6.20
    WHEN `category_id` = 8 THEN 8.60
    WHEN `category_id` = 9 THEN 7.20
    ELSE 6.60
  END * 1.22, 2),
  `stock` = CASE
    WHEN `category_id` = 3 THEN 180
    WHEN `category_id` = 4 THEN 220
    WHEN `category_id` = 5 THEN 200
    WHEN `category_id` = 6 THEN 160
    WHEN `category_id` = 7 THEN 210
    WHEN `category_id` = 8 THEN 170
    WHEN `category_id` = 9 THEN 190
    ELSE 150
  END,
  `unit` = '斤'
WHERE `category_id` IN (3,4,5,6,7,8,9,10)
  AND (
    `price` IS NULL OR `price` <= 0 OR
    `original_price` IS NULL OR `original_price` <= 0 OR
    `stock` IS NULL OR `stock` <= 0 OR
    `unit` IS NULL OR TRIM(`unit`) = ''
  );

-- 4) 推荐位和首页排序微调（不改爆款和秒杀字段）
UPDATE `goods`
SET
  `is_recommend` = CASE WHEN `category_id` IN (3,4,5,6,8,9) THEN 1 ELSE 0 END,
  `home_sort` = CASE
    WHEN `category_id` = 3 THEN 100 + MOD(`id`, 30)
    WHEN `category_id` = 4 THEN 200 + MOD(`id`, 30)
    WHEN `category_id` = 5 THEN 300 + MOD(`id`, 30)
    WHEN `category_id` = 6 THEN 400 + MOD(`id`, 30)
    WHEN `category_id` = 7 THEN 500 + MOD(`id`, 30)
    WHEN `category_id` = 8 THEN 600 + MOD(`id`, 30)
    WHEN `category_id` = 9 THEN 700 + MOD(`id`, 30)
    ELSE 800 + MOD(`id`, 30)
  END
WHERE `category_id` IN (3,4,5,6,7,8,9,10);

-- 5) 执行后校验
SELECT c.`id`, c.`name` AS category_name, COUNT(*) AS goods_count
FROM `goods` g
JOIN `category` c ON c.`id` = g.`category_id`
WHERE g.`category_id` IN (3,4,5,6,7,8,9,10)
GROUP BY c.`id`, c.`name`
ORDER BY c.`id`;

SELECT
  SUM(CASE WHEN `main_image` IS NULL OR TRIM(`main_image`) = '' THEN 1 ELSE 0 END) AS empty_main_image,
  SUM(CASE WHEN `images` IS NULL OR TRIM(`images`) = '' THEN 1 ELSE 0 END) AS empty_images,
  SUM(CASE WHEN `keywords` IS NULL OR TRIM(`keywords`) = '' THEN 1 ELSE 0 END) AS empty_keywords,
  SUM(CASE WHEN `origin` IS NULL OR TRIM(`origin`) = '' THEN 1 ELSE 0 END) AS empty_origin,
  SUM(CASE WHEN `detail` IS NULL OR TRIM(`detail`) = '' THEN 1 ELSE 0 END) AS empty_detail
FROM `goods`
WHERE `category_id` IN (3,4,5,6,7,8,9,10);

SELECT
  SUM(CASE WHEN `is_recommend` = 1 THEN 1 ELSE 0 END) AS recommend_count,
  SUM(CASE WHEN `show_in_home` = 1 THEN 1 ELSE 0 END) AS show_in_home_count,
  SUM(CASE WHEN `status` = 1 THEN 1 ELSE 0 END) AS active_count
FROM `goods`
WHERE `category_id` IN (3,4,5,6,7,8,9,10);