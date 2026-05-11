-- 数据库收敛预检查（先执行本文件）
-- 目标：检查是否存在会影响加外键的孤儿数据

USE `freshtime`;

-- 1) 孤儿数据检查
SELECT 'cart.user_id -> user.id' AS check_item, COUNT(*) AS orphan_count
FROM `cart` c
LEFT JOIN `user` u ON u.id = c.user_id
WHERE u.id IS NULL;

SELECT 'cart.goods_id -> goods.id' AS check_item, COUNT(*) AS orphan_count
FROM `cart` c
LEFT JOIN `goods` g ON g.id = c.goods_id
WHERE g.id IS NULL;

SELECT 'address.user_id -> user.id' AS check_item, COUNT(*) AS orphan_count
FROM `address` a
LEFT JOIN `user` u ON u.id = a.user_id
WHERE u.id IS NULL;

SELECT 'goods.category_id -> category.id' AS check_item, COUNT(*) AS orphan_count
FROM `goods` g
LEFT JOIN `category` c ON c.id = g.category_id
WHERE c.id IS NULL;

SELECT 'order.user_id -> user.id' AS check_item, COUNT(*) AS orphan_count
FROM `order` o
LEFT JOIN `user` u ON u.id = o.user_id
WHERE u.id IS NULL;

SELECT 'order.coupon_id -> coupon.id' AS check_item, COUNT(*) AS orphan_count
FROM `order` o
LEFT JOIN `coupon` c ON c.id = o.coupon_id
WHERE o.coupon_id IS NOT NULL AND c.id IS NULL;

SELECT 'order_item.order_id -> order.id' AS check_item, COUNT(*) AS orphan_count
FROM `order_item` oi
LEFT JOIN `order` o ON o.id = oi.order_id
WHERE o.id IS NULL;

SELECT 'order_item.goods_id -> goods.id' AS check_item, COUNT(*) AS orphan_count
FROM `order_item` oi
LEFT JOIN `goods` g ON g.id = oi.goods_id
WHERE g.id IS NULL;

SELECT 'user_coupon.user_id -> user.id' AS check_item, COUNT(*) AS orphan_count
FROM `user_coupon` uc
LEFT JOIN `user` u ON u.id = uc.user_id
WHERE u.id IS NULL;

SELECT 'user_setting.user_id -> user.id' AS check_item, COUNT(*) AS orphan_count
FROM `user_setting` us
LEFT JOIN `user` u ON u.id = us.user_id
WHERE u.id IS NULL;

SELECT 'goods_tag.goods_id -> goods.id' AS check_item, COUNT(*) AS orphan_count
FROM `goods_tag` gt
LEFT JOIN `goods` g ON g.id = gt.goods_id
WHERE g.id IS NULL;

SELECT 'goods_tag.tag_id -> tag.id' AS check_item, COUNT(*) AS orphan_count
FROM `goods_tag` gt
LEFT JOIN `tag` t ON t.id = gt.tag_id
WHERE t.id IS NULL;

-- 2) 重复映射检查（建议为0）
SELECT 'goods_tag duplicate(goods_id,tag_id)' AS check_item, COUNT(*) AS duplicate_count
FROM (
  SELECT goods_id, tag_id
  FROM `goods_tag`
  GROUP BY goods_id, tag_id
  HAVING COUNT(*) > 1
) d;

-- 3) 待删除表存在性确认
SELECT table_name
FROM information_schema.tables
WHERE table_schema = DATABASE()
  AND table_name IN (
    'track_event_log',
    'trace_record',
    'home_origin_card',
    'knowledge_article',
    'goods_sku',
    'admin',
    'service_faq'
  )
ORDER BY table_name;

