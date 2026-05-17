-- =====================================================
-- FreshTime 展示数据增量脚本（幂等/安全版）
-- 适用：现有 freshtime 库（非空库）
-- 说明：不重置自增，不硬编码主键，可重复执行
-- =====================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================
-- 1) 用户数据（按 openid 幂等插入）
-- =====================================================
INSERT INTO `user` (`openid`, `nickname`, `avatar`, `phone`, `status`, `create_time`)
SELECT v.openid, v.nickname, v.avatar, v.phone, 1, v.create_time
FROM (
  SELECT 'demo_openid_u01' AS openid, '林小厨' AS nickname, 'https://randomuser.me/api/portraits/women/1.jpg' AS avatar, '13800001001' AS phone, '2026-04-01 10:00:00' AS create_time
  UNION ALL SELECT 'demo_openid_u02', '果果妈', 'https://randomuser.me/api/portraits/women/2.jpg', '13800001002', '2026-04-02 10:00:00'
  UNION ALL SELECT 'demo_openid_u03', '健身达人', 'https://randomuser.me/api/portraits/men/3.jpg', '13800001003', '2026-04-03 10:00:00'
  UNION ALL SELECT 'demo_openid_u04', '轻食主义', 'https://randomuser.me/api/portraits/women/6.jpg', '13800001004', '2026-04-04 10:00:00'
  UNION ALL SELECT 'demo_openid_u05', '周末大厨', 'https://randomuser.me/api/portraits/men/16.jpg', '13800001005', '2026-04-05 10:00:00'
  UNION ALL SELECT 'demo_openid_u06', '深夜食堂', 'https://randomuser.me/api/portraits/men/30.jpg', '13800001006', '2026-04-06 10:00:00'
) v
WHERE NOT EXISTS (
  SELECT 1 FROM `user` u WHERE u.openid = v.openid
);

-- =====================================================
-- 2) 地址数据（按 user_id + detail 幂等插入）
-- =====================================================
INSERT INTO `address` (`user_id`, `receiver_name`, `receiver_phone`, `province`, `city`, `district`, `detail`, `is_default`, `create_time`)
SELECT u.id, u.nickname, u.phone, '湖南省', '长沙市', '岳麓区', CONCAT('演示地址-', u.nickname), 1, NOW()
FROM `user` u
WHERE u.openid LIKE 'demo_openid_%'
  AND NOT EXISTS (
    SELECT 1 FROM `address` a WHERE a.user_id = u.id AND a.detail = CONCAT('演示地址-', u.nickname)
  );

-- =====================================================
-- 3) 购物车数据（按 user_id + goods_id + sku_id 幂等）
-- =====================================================
INSERT INTO `cart` (`user_id`, `goods_id`, `sku_id`, `quantity`, `selected`, `create_time`)
SELECT u.id, g.id, s.id, 1, 1, NOW()
FROM `user` u
JOIN `goods` g ON g.status = 1
JOIN `goods_sku` s ON s.goods_id = g.id AND s.status = 1
WHERE u.openid LIKE 'demo_openid_%'
  AND g.id IN (1, 4, 13, 49, 77)
  AND s.id = (
    SELECT s2.id FROM `goods_sku` s2
    WHERE s2.goods_id = g.id AND s2.status = 1
    ORDER BY s2.sort ASC, s2.id ASC
    LIMIT 1
  )
  AND NOT EXISTS (
    SELECT 1 FROM `cart` c
    WHERE c.user_id = u.id AND c.goods_id = g.id AND c.sku_id = s.id
  )
LIMIT 60;

-- =====================================================
-- 4) 演示订单（轻量）
-- 状态分布：待付款2、待发货2、待收货2、已完成6、已取消1、已退款1、退款中1
-- =====================================================
DROP PROCEDURE IF EXISTS `seed_demo_orders`;
DELIMITER ;;
CREATE PROCEDURE `seed_demo_orders`()
BEGIN
  DECLARE done INT DEFAULT FALSE;
  DECLARE v_uid BIGINT;
  DECLARE v_name VARCHAR(64);
  DECLARE v_phone VARCHAR(20);
  DECLARE v_addr VARCHAR(256);
  DECLARE v_no VARCHAR(32);
  DECLARE i INT DEFAULT 0;

  DECLARE cur CURSOR FOR
    SELECT u.id, IFNULL(a.receiver_name, u.nickname), IFNULL(a.receiver_phone, u.phone),
           IFNULL(CONCAT(IFNULL(a.province,''), IFNULL(a.city,''), IFNULL(a.district,''), IFNULL(a.detail,'')), '演示地址')
    FROM `user` u
    LEFT JOIN `address` a ON a.user_id = u.id AND a.is_default = 1
    WHERE u.openid LIKE 'demo_openid_%'
    ORDER BY u.id;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  OPEN cur;
  read_loop: LOOP
    FETCH cur INTO v_uid, v_name, v_phone, v_addr;
    IF done THEN LEAVE read_loop; END IF;

    -- 每个演示用户最多生成2单
    SET i = 0;
    WHILE i < 2 DO
      SET v_no = CONCAT('DEMO', DATE_FORMAT(NOW(), '%y%m%d%H%i%s'), LPAD(v_uid, 4, '0'), i);

      INSERT INTO `order`(
        `order_no`, `user_id`, `total_amount`, `discount_amount`, `actual_amount`,
        `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `coupon_id`,
        `status`, `pay_channel`, `pay_trade_no`, `pay_status`, `pay_time`, `deliver_time`, `finish_time`, `cancel_time`, `create_time`
      )
      SELECT
        v_no, v_uid,
        CASE WHEN i = 0 THEN 39.60 ELSE 68.80 END,
        0,
        CASE WHEN i = 0 THEN 39.60 ELSE 68.80 END,
        v_name, v_phone, v_addr,
        '演示订单', NULL,
        CASE
          WHEN v_uid % 7 = 0 THEN 0
          WHEN v_uid % 7 = 1 THEN 1
          WHEN v_uid % 7 = 2 THEN 2
          WHEN v_uid % 7 = 3 THEN 3
          WHEN v_uid % 7 = 4 THEN 4
          WHEN v_uid % 7 = 5 THEN 5
          ELSE 6
        END,
        CASE WHEN v_uid % 7 IN (1,2,3,5,6) THEN 'mock_wechat' ELSE NULL END,
        CASE WHEN v_uid % 7 IN (1,2,3,5,6) THEN CONCAT('DEMO_PAY_', v_uid, '_', i) ELSE NULL END,
        CASE WHEN v_uid % 7 IN (1,2,3,5,6) THEN 2 ELSE 0 END,
        CASE WHEN v_uid % 7 IN (1,2,3,5,6) THEN DATE_SUB(NOW(), INTERVAL (v_uid % 5 + 1) DAY) ELSE NULL END,
        CASE WHEN v_uid % 7 IN (2,3,5,6) THEN DATE_SUB(NOW(), INTERVAL (v_uid % 4 + 1) DAY) ELSE NULL END,
        CASE WHEN v_uid % 7 = 3 THEN DATE_SUB(NOW(), INTERVAL (v_uid % 3 + 1) DAY) ELSE NULL END,
        CASE WHEN v_uid % 7 = 4 THEN DATE_SUB(NOW(), INTERVAL 2 DAY) ELSE NULL END,
        DATE_SUB(NOW(), INTERVAL (v_uid % 10 + i) DAY)
      FROM DUAL
      WHERE NOT EXISTS (SELECT 1 FROM `order` o WHERE o.order_no = v_no);

      SET i = i + 1;
    END WHILE;
  END LOOP;
  CLOSE cur;
END ;;
DELIMITER ;

CALL `seed_demo_orders`();
DROP PROCEDURE IF EXISTS `seed_demo_orders`;

-- =====================================================
-- 5) 订单明细（仅补演示订单且未有明细的）
-- =====================================================
INSERT INTO `order_item` (`order_id`, `goods_id`, `sku_id`, `goods_name`, `goods_image`, `sku_name`, `sku_weight_g`, `price`, `quantity`, `total_price`)
SELECT o.id, g.id, s.id, g.name, g.main_image, s.sku_name, s.sku_weight_g, s.sku_price, 1, s.sku_price
FROM `order` o
JOIN `user` u ON u.id = o.user_id AND u.openid LIKE 'demo_openid_%'
JOIN `goods` g ON g.id IN (13, 49)
JOIN `goods_sku` s ON s.goods_id = g.id AND s.status = 1
WHERE s.id = (
    SELECT s2.id FROM `goods_sku` s2
    WHERE s2.goods_id = g.id AND s2.status = 1
    ORDER BY s2.sort ASC, s2.id ASC
    LIMIT 1
  )
  AND NOT EXISTS (SELECT 1 FROM `order_item` oi WHERE oi.order_id = o.id)
LIMIT 120;

-- =====================================================
-- 6) 评价数据（仅已完成演示订单，且同单同商品未评价）
-- =====================================================
INSERT INTO `comment` (`order_id`, `user_id`, `goods_id`, `rating`, `content`, `images`, `create_time`)
SELECT
  o.id,
  o.user_id,
  oi.goods_id,
  4,
  '演示评价：商品新鲜，配送及时。',
  NULL,
  DATE_ADD(IFNULL(o.finish_time, NOW()), INTERVAL 2 HOUR)
FROM `order` o
JOIN `user` u ON u.id = o.user_id AND u.openid LIKE 'demo_openid_%'
JOIN `order_item` oi ON oi.order_id = o.id
WHERE o.status = 3
  AND NOT EXISTS (
    SELECT 1 FROM `comment` c
    WHERE c.order_id = o.id AND c.user_id = o.user_id AND c.goods_id = oi.goods_id
  )
LIMIT 60;

-- =====================================================
-- 7) 用户优惠券（演示用户领取模板券，幂等）
-- =====================================================
INSERT INTO `user_coupon` (`user_id`, `title`, `condition_text`, `threshold_amount`, `discount_amount`, `expire_date`, `status`, `create_time`)
SELECT
  u.id,
  c.name,
  IFNULL(c.description, '演示优惠券'),
  c.threshold_amount,
  c.discount_amount,
  c.expire_date,
  1,
  NOW()
FROM `user` u
JOIN `coupon` c ON c.status = 1
WHERE u.openid LIKE 'demo_openid_%'
  AND NOT EXISTS (
    SELECT 1 FROM `user_coupon` uc
    WHERE uc.user_id = u.id AND uc.title = c.name AND uc.expire_date = c.expire_date
  )
LIMIT 120;

-- =====================================================
-- 8) 补充营销标签（按名称幂等）
-- =====================================================
INSERT INTO `tag` (`tag_name`, `type`)
SELECT t.tag_name, t.type
FROM (
  SELECT '热销榜' AS tag_name, 3 AS type
  UNION ALL SELECT '新品上市', 3
  UNION ALL SELECT '低脂轻食', 2
  UNION ALL SELECT '产地直发', 1
  UNION ALL SELECT '进口水果', 1
  UNION ALL SELECT '限时特惠', 3
  UNION ALL SELECT '爆款推荐', 3
  UNION ALL SELECT '回购王', 3
) t
WHERE NOT EXISTS (SELECT 1 FROM `tag` x WHERE x.tag_name = t.tag_name);

-- 给部分商品打新标签（按 goods_id + tag_id 幂等）
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_name IN ('热销榜', '新品上市', '低脂轻食', '产地直发', '进口水果', '限时特惠', '爆款推荐', '回购王')
WHERE g.status = 1
  AND RAND() < 0.2
  AND NOT EXISTS (
    SELECT 1 FROM `goods_tag` gt WHERE gt.goods_id = g.id AND gt.tag_id = t.id
  )
LIMIT 200;

-- =====================================================
-- 9) 可选刷新秒杀池（保留但不强制）
-- =====================================================
-- CALL refresh_flash_pool(12);

-- =====================================================
-- 10) 验证统计
-- =====================================================
SELECT 'demo_users' AS item, COUNT(1) AS cnt FROM `user` WHERE `openid` LIKE 'demo_openid_%';
SELECT 'demo_orders' AS item, COUNT(1) AS cnt FROM `order` o JOIN `user` u ON u.id = o.user_id WHERE u.openid LIKE 'demo_openid_%';
SELECT 'demo_order_items' AS item, COUNT(1) AS cnt FROM `order_item` oi JOIN `order` o ON o.id = oi.order_id JOIN `user` u ON u.id = o.user_id WHERE u.openid LIKE 'demo_openid_%';
SELECT 'demo_comments' AS item, COUNT(1) AS cnt FROM `comment` c JOIN `user` u ON u.id = c.user_id WHERE u.openid LIKE 'demo_openid_%';
SELECT 'platter_sku' AS item, COUNT(1) AS cnt FROM `goods_sku` WHERE `spec_type` = 'platter';

SET FOREIGN_KEY_CHECKS = 1;
