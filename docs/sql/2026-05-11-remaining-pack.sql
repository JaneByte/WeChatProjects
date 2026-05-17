-- 2026-05-11-remaining-pack.sql
-- 作用：一次性完成剩余 P1/P2 数据规范（券、订单、首页运营、评论种子）
-- 特点：最小改动、可重复执行、按当前 freshtime.sql 字段对齐
USE `freshtime`;

-- =====================================================
-- A) 券体系规范（coupon / user_coupon）
-- =====================================================

-- A1. coupon 模板兜底（缺则补）
INSERT INTO `coupon` (`id`,`name`,`description`,`threshold_amount`,`discount_amount`,`expire_date`,`status`,`create_time`)
SELECT 9001,'满50减8','全场可用',50.00,8.00,'2026-12-31',1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `coupon` WHERE `id`=9001);

INSERT INTO `coupon` (`id`,`name`,`description`,`threshold_amount`,`discount_amount`,`expire_date`,`status`,`create_time`)
SELECT 9002,'满99减15','生鲜专区',99.00,15.00,'2026-12-31',1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `coupon` WHERE `id`=9002);

INSERT INTO `coupon` (`id`,`name`,`description`,`threshold_amount`,`discount_amount`,`expire_date`,`status`,`create_time`)
SELECT 9003,'满39减5','新人专享',39.00,5.00,'2026-12-31',1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `coupon` WHERE `id`=9003);

-- A2. user_coupon 基础质量修复
UPDATE `user_coupon`
SET `status` = 0
WHERE `expire_date` < CURDATE() AND `status` = 1;

UPDATE `user_coupon`
SET `status` = 1
WHERE `status` NOT IN (0,1,2);

-- A3. 对每个用户兜底一张可用券（避免“领券页空”）
INSERT INTO `user_coupon`
(`user_id`,`title`,`condition_text`,`threshold_amount`,`discount_amount`,`expire_date`,`status`,`create_time`)
SELECT u.`id`, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, NOW()
FROM `user` u
WHERE NOT EXISTS (
  SELECT 1 FROM `user_coupon` uc
  WHERE uc.`user_id` = u.`id`
    AND uc.`title` = '满50减8'
    AND uc.`status` = 1
    AND uc.`expire_date` >= CURDATE()
);

-- =====================================================
-- B) 订单链路规范（order / order_item）
-- =====================================================

-- B1. order_item 小计兜底
UPDATE `order_item`
SET `total_price` = ROUND(`price` * `quantity`, 2)
WHERE `total_price` IS NULL
   OR `total_price` <= 0
   OR ABS(`total_price` - ROUND(`price` * `quantity`, 2)) > 0.01;

-- B2. order 总额回写（按明细聚合）
UPDATE `order` o
JOIN (
  SELECT `order_id`, ROUND(SUM(`total_price`), 2) AS item_total
  FROM `order_item`
  GROUP BY `order_id`
) s ON s.`order_id` = o.`id`
SET o.`total_amount` = s.`item_total`
WHERE o.`total_amount` IS NULL
   OR o.`total_amount` <= 0
   OR ABS(o.`total_amount` - s.`item_total`) > 0.01;

-- B3. 优惠金额/实付金额规范
UPDATE `order`
SET `discount_amount` = 0.00
WHERE `discount_amount` IS NULL OR `discount_amount` < 0;

UPDATE `order`
SET `actual_amount` = GREATEST(ROUND(`total_amount` - `discount_amount`, 2), 0.00)
WHERE `actual_amount` IS NULL
   OR `actual_amount` < 0
   OR ABS(`actual_amount` - GREATEST(ROUND(`total_amount` - `discount_amount`, 2),0.00)) > 0.01;

-- B4. 支付字段与订单状态一致性
UPDATE `order`
SET
  `pay_status` = CASE
    WHEN `status` IN (1,2,3,5,6) THEN 2
    WHEN `status` = 0 THEN 1
    ELSE 0
  END,
  `pay_time` = CASE
    WHEN `status` IN (1,2,3,5,6) AND `pay_time` IS NULL THEN `create_time`
    WHEN `status` IN (0,4) THEN NULL
    ELSE `pay_time`
  END
WHERE 1=1;

-- =====================================================
-- C) 首页运营内容（banner / home_notice / home_nav）
-- =====================================================

-- C1. 公告兜底（缺则补）
INSERT INTO `home_notice` (`notice_text`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT '今日上新优先发货，最快次日达','none','',1,1,NOW() FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `home_notice` WHERE `notice_text`='今日上新优先发货，最快次日达' AND `status`=1
);

INSERT INTO `home_notice` (`notice_text`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT '限时秒杀库存有限，先到先得','goods','flash',2,1,NOW() FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `home_notice` WHERE `notice_text`='限时秒杀库存有限，先到先得' AND `status`=1
);

-- C2. 快捷入口文案统一（当前方案）
UPDATE `home_nav` SET `nav_text`='领券专区' WHERE `nav_type`='couponZone';
UPDATE `home_nav` SET `nav_text`='时令蔬果' WHERE `nav_type`='seasonalFresh';
UPDATE `home_nav` SET `nav_text`='小份量专区' WHERE `nav_type`='smallPortion';
UPDATE `home_nav` SET `nav_text`='蔬果搭配' WHERE `nav_type`='comboMix';

-- C3. 如缺入口则补（按当前字段）
INSERT INTO `home_nav` (`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT 'couponZone','领券专区','券','goods','coupon',1,1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `nav_type`='couponZone');

INSERT INTO `home_nav` (`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT 'seasonalFresh','时令蔬果','时','search','时令',2,1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `nav_type`='seasonalFresh');

INSERT INTO `home_nav` (`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT 'smallPortion','小份量专区','小','scene','小份量',3,1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `nav_type`='smallPortion');

INSERT INTO `home_nav` (`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`,`create_time`)
SELECT 'comboMix','蔬果搭配','搭','scene','搭配',4,1,NOW() FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `nav_type`='comboMix');

-- =====================================================
-- D) 评论种子（comment）- 仅在无评论时补少量样例
-- =====================================================

INSERT INTO `comment`
(`order_id`,`user_id`,`goods_id`,`merchant_id`,`rating`,`content`,`images`,`create_time`)
SELECT oi.`order_id`, o.`user_id`, oi.`goods_id`, o.`merchant_id`, 5,
       CONCAT(oi.`goods_name`, ' 很新鲜，配送也快，会回购。'),
       NULL, NOW()
FROM `order_item` oi
JOIN `order` o ON o.`id` = oi.`order_id`
WHERE o.`status` IN (2,3)
  AND NOT EXISTS (
    SELECT 1 FROM `comment` c
    WHERE c.`order_id` = oi.`order_id` AND c.`goods_id` = oi.`goods_id`
  )
LIMIT 30;

-- =====================================================
-- E) 执行后校验
-- =====================================================

-- E1 券
SELECT
  COUNT(*) AS coupon_templates,
  SUM(CASE WHEN `status`=1 THEN 1 ELSE 0 END) AS coupon_templates_active
FROM `coupon`;

SELECT
  COUNT(*) AS user_coupon_total,
  SUM(CASE WHEN `status`=1 THEN 1 ELSE 0 END) AS user_coupon_usable,
  SUM(CASE WHEN `expire_date` < CURDATE() AND `status`=1 THEN 1 ELSE 0 END) AS expired_but_usable
FROM `user_coupon`;

-- E2 订单金额一致性
SELECT
  COUNT(*) AS bad_order_amount_count
FROM `order` o
JOIN (
  SELECT `order_id`, ROUND(SUM(`total_price`),2) AS sum_item
  FROM `order_item`
  GROUP BY `order_id`
) s ON s.`order_id`=o.`id`
WHERE ABS(o.`total_amount` - s.`sum_item`) > 0.01
   OR ABS(o.`actual_amount` - GREATEST(ROUND(o.`total_amount` - o.`discount_amount`,2),0.00)) > 0.01;

-- E3 首页入口
SELECT `id`,`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`
FROM `home_nav`
WHERE `status`=1
ORDER BY `sort`,`id`;

-- E4 评论覆盖
SELECT COUNT(*) AS comment_count FROM `comment`;