-- 2026-05-11-final-audit-v2.sql
-- 作用：最终可用性体检（只读，无数据修改）
USE `freshtime`;

-- A1. Banner 可用性
SELECT
  COUNT(*) AS banner_total,
  SUM(CASE WHEN `status` = 1 THEN 1 ELSE 0 END) AS banner_active,
  SUM(CASE WHEN `status` = 1 AND (`image` IS NULL OR TRIM(`image`) = '') THEN 1 ELSE 0 END) AS banner_active_no_image
FROM `banner`;

SELECT `id`,`title`,`link_type`,`link_value`,`sort`,`status`
FROM `banner`
ORDER BY `sort`,`id`;

-- A2. 快捷入口可用性
SELECT
  COUNT(*) AS nav_total,
  SUM(CASE WHEN `status` = 1 THEN 1 ELSE 0 END) AS nav_active
FROM `home_nav`;

SELECT `id`,`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`
FROM `home_nav`
WHERE `status` = 1
ORDER BY `sort`,`id`;

-- A3. 首页公告可用性
SELECT
  COUNT(*) AS notice_total,
  SUM(CASE WHEN `status` = 1 THEN 1 ELSE 0 END) AS notice_active
FROM `home_notice`;

-- B1. 商品基础质量（上架商品）
SELECT
  COUNT(*) AS goods_online,
  SUM(CASE WHEN `main_image` IS NULL OR TRIM(`main_image`) = '' THEN 1 ELSE 0 END) AS empty_main_image,
  SUM(CASE WHEN `images` IS NULL OR TRIM(`images`) = '' THEN 1 ELSE 0 END) AS empty_images,
  SUM(CASE WHEN `detail` IS NULL OR TRIM(`detail`) = '' THEN 1 ELSE 0 END) AS empty_detail,
  SUM(CASE WHEN `price` IS NULL OR `price` <= 0 THEN 1 ELSE 0 END) AS bad_price,
  SUM(CASE WHEN `stock` IS NULL OR `stock` < 0 THEN 1 ELSE 0 END) AS bad_stock
FROM `goods`
WHERE `status` = 1;

-- B2. 秒杀可用性
SELECT
  SUM(CASE WHEN `is_flash` = 1 THEN 1 ELSE 0 END) AS flash_goods,
  SUM(CASE WHEN `is_flash` = 1 AND (`flash_price` IS NULL OR `flash_price` <= 0) THEN 1 ELSE 0 END) AS flash_no_price,
  SUM(CASE WHEN `is_flash` = 1 AND `flash_start_time` IS NULL THEN 1 ELSE 0 END) AS flash_no_start,
  SUM(CASE WHEN `is_flash` = 1 AND `flash_end_time` IS NULL THEN 1 ELSE 0 END) AS flash_no_end,
  SUM(CASE WHEN `is_flash` = 1 AND (`flash_stock` IS NULL OR `flash_stock` <= 0) THEN 1 ELSE 0 END) AS flash_no_stock
FROM `goods`
WHERE `status` = 1;

-- B3. 本周热销候选（销量）
SELECT `id`,`name`,`sales_volume`,`price`,`stock`,`status`
FROM `goods`
WHERE `status` = 1
ORDER BY `sales_volume` DESC, `id` ASC
LIMIT 20;

-- B4. 场景标签覆盖
SELECT t.`id`, t.`tag_name`, COUNT(gt.`goods_id`) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.`tag_id` = t.`id`
WHERE t.`id` IN (101,102,103,104)
GROUP BY t.`id`, t.`tag_name`
ORDER BY t.`id`;

-- C1. 领券可用性
SELECT
  COUNT(*) AS coupon_templates,
  SUM(CASE WHEN `status` = 1 THEN 1 ELSE 0 END) AS coupon_templates_active
FROM `coupon`;

SELECT
  COUNT(*) AS user_coupon_total,
  SUM(CASE WHEN `status` = 1 THEN 1 ELSE 0 END) AS user_coupon_usable,
  SUM(CASE WHEN `expire_date` < CURDATE() AND `status` = 1 THEN 1 ELSE 0 END) AS expired_but_usable
FROM `user_coupon`;

-- C2. 订单金额一致性
SELECT
  COUNT(*) AS bad_order_amount_count
FROM `order` o
JOIN (
  SELECT `order_id`, ROUND(SUM(`total_price`), 2) AS sum_item
  FROM `order_item`
  GROUP BY `order_id`
) s ON s.`order_id` = o.`id`
WHERE ABS(o.`total_amount` - s.`sum_item`) > 0.01
   OR ABS(o.`actual_amount` - GREATEST(ROUND(o.`total_amount` - o.`discount_amount`,2),0.00)) > 0.01;

-- C3. 订单状态分布
SELECT `status`, COUNT(*) AS cnt
FROM `order`
GROUP BY `status`
ORDER BY `status`;