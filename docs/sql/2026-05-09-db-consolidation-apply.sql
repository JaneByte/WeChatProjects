-- 数据库收敛正式执行脚本
-- 执行前请先跑：2026-05-09-db-consolidation-precheck.sql

USE `freshtime`;

SET FOREIGN_KEY_CHECKS = 0;

-- 0) 若 coupon 表不存在则补建（避免外键失败）
CREATE TABLE IF NOT EXISTS `coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL COMMENT '优惠券名称',
  `description` varchar(255) DEFAULT NULL COMMENT '优惠说明',
  `threshold_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '使用门槛',
  `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `expire_date` date DEFAULT NULL COMMENT '过期日期',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COMMENT = '优惠券模板表';

-- 1) 删除将要下线的表（非核心链路）
DROP TABLE IF EXISTS `track_event_log`;
DROP TABLE IF EXISTS `trace_record`;
DROP TABLE IF EXISTS `home_origin_card`;
DROP TABLE IF EXISTS `knowledge_article`;
DROP TABLE IF EXISTS `goods_sku`;
DROP TABLE IF EXISTS `admin`;
DROP TABLE IF EXISTS `service_faq`;

-- 2) 清理孤儿数据（避免外键添加失败）
DELETE c FROM `cart` c
LEFT JOIN `user` u ON u.id = c.user_id
WHERE u.id IS NULL;

DELETE c FROM `cart` c
LEFT JOIN `goods` g ON g.id = c.goods_id
WHERE g.id IS NULL;

DELETE a FROM `address` a
LEFT JOIN `user` u ON u.id = a.user_id
WHERE u.id IS NULL;

DELETE g FROM `goods` g
LEFT JOIN `category` c ON c.id = g.category_id
WHERE c.id IS NULL;

DELETE o FROM `order` o
LEFT JOIN `user` u ON u.id = o.user_id
WHERE u.id IS NULL;

UPDATE `order` o
LEFT JOIN `coupon` c ON c.id = o.coupon_id
SET o.coupon_id = NULL
WHERE o.coupon_id IS NOT NULL AND c.id IS NULL;

DELETE oi FROM `order_item` oi
LEFT JOIN `order` o ON o.id = oi.order_id
WHERE o.id IS NULL;

DELETE oi FROM `order_item` oi
LEFT JOIN `goods` g ON g.id = oi.goods_id
WHERE g.id IS NULL;

DELETE uc FROM `user_coupon` uc
LEFT JOIN `user` u ON u.id = uc.user_id
WHERE u.id IS NULL;

DELETE us FROM `user_setting` us
LEFT JOIN `user` u ON u.id = us.user_id
WHERE u.id IS NULL;

DELETE gt FROM `goods_tag` gt
LEFT JOIN `goods` g ON g.id = gt.goods_id
WHERE g.id IS NULL;

DELETE gt FROM `goods_tag` gt
LEFT JOIN `tag` t ON t.id = gt.tag_id
WHERE t.id IS NULL;

-- 2.1 去重 goods_tag，保留最小 id
DELETE gt1 FROM `goods_tag` gt1
INNER JOIN `goods_tag` gt2
  ON gt1.goods_id = gt2.goods_id
 AND gt1.tag_id = gt2.tag_id
 AND gt1.id > gt2.id;

-- 3) 清理旧外键（如果存在）
SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'goods' AND CONSTRAINT_NAME = 'fk_goods_category'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `goods` DROP FOREIGN KEY `fk_goods_category`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'cart' AND CONSTRAINT_NAME = 'fk_cart_user'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `cart` DROP FOREIGN KEY `fk_cart_user`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'cart' AND CONSTRAINT_NAME = 'fk_cart_goods'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `cart` DROP FOREIGN KEY `fk_cart_goods`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'address' AND CONSTRAINT_NAME = 'fk_address_user'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `address` DROP FOREIGN KEY `fk_address_user`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'order' AND CONSTRAINT_NAME = 'fk_order_user'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `order` DROP FOREIGN KEY `fk_order_user`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'order' AND CONSTRAINT_NAME = 'fk_order_coupon'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `order` DROP FOREIGN KEY `fk_order_coupon`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'order_item' AND CONSTRAINT_NAME = 'fk_order_item_order'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `order_item` DROP FOREIGN KEY `fk_order_item_order`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'order_item' AND CONSTRAINT_NAME = 'fk_order_item_goods'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `order_item` DROP FOREIGN KEY `fk_order_item_goods`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'user_coupon' AND CONSTRAINT_NAME = 'fk_user_coupon_user'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `user_coupon` DROP FOREIGN KEY `fk_user_coupon_user`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'user_setting' AND CONSTRAINT_NAME = 'fk_user_setting_user'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `user_setting` DROP FOREIGN KEY `fk_user_setting_user`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'goods_tag' AND CONSTRAINT_NAME = 'fk_goods_tag_goods'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `goods_tag` DROP FOREIGN KEY `fk_goods_tag_goods`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @fk_cnt = (
  SELECT COUNT(*) FROM information_schema.TABLE_CONSTRAINTS
  WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'goods_tag' AND CONSTRAINT_NAME = 'fk_goods_tag_tag'
);
SET @sql = IF(@fk_cnt > 0, 'ALTER TABLE `goods_tag` DROP FOREIGN KEY `fk_goods_tag_tag`', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- 4) 补唯一索引（用于保障中间表质量）
ALTER TABLE `goods_tag` ADD UNIQUE INDEX `uk_goods_tag_goods_tag` (`goods_id`, `tag_id`);

-- 5) 添加外键约束（核心链路）
ALTER TABLE `goods`
  ADD CONSTRAINT `fk_goods_category`
  FOREIGN KEY (`category_id`) REFERENCES `category` (`id`);

ALTER TABLE `cart`
  ADD CONSTRAINT `fk_cart_user`
  FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `fk_cart_goods`
  FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`);

ALTER TABLE `address`
  ADD CONSTRAINT `fk_address_user`
  FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `order`
  ADD CONSTRAINT `fk_order_user`
  FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
  ADD CONSTRAINT `fk_order_coupon`
  FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`);

ALTER TABLE `order_item`
  ADD CONSTRAINT `fk_order_item_order`
  FOREIGN KEY (`order_id`) REFERENCES `order` (`id`),
  ADD CONSTRAINT `fk_order_item_goods`
  FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`);

ALTER TABLE `user_coupon`
  ADD CONSTRAINT `fk_user_coupon_user`
  FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `user_setting`
  ADD CONSTRAINT `fk_user_setting_user`
  FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE `goods_tag`
  ADD CONSTRAINT `fk_goods_tag_goods`
  FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`),
  ADD CONSTRAINT `fk_goods_tag_tag`
  FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`);

SET FOREIGN_KEY_CHECKS = 1;
