-- FreshTime DB migration (idempotent)
-- Date: 2026-05-16
-- Purpose: comment query capability, sku multi-spec extension, index optimization.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET @db := DATABASE();

-- goods_tag unique index
SET @sql := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = @db
        AND table_name = 'goods_tag'
        AND index_name = 'uk_goods_tag_goods_tag'
    ),
    'SELECT ''skip uk_goods_tag_goods_tag''',
    'ALTER TABLE `goods_tag` ADD UNIQUE INDEX `uk_goods_tag_goods_tag`(`goods_id`,`tag_id`)'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- tag unique index
SET @sql := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = @db
        AND table_name = 'tag'
        AND index_name = 'uk_tag_name'
    ),
    'SELECT ''skip uk_tag_name''',
    'ALTER TABLE `tag` ADD UNIQUE INDEX `uk_tag_name`(`tag_name`)'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- user_coupon index
SET @sql := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = @db
        AND table_name = 'user_coupon'
        AND index_name = 'idx_user_coupon_user_status_expire'
    ),
    'SELECT ''skip idx_user_coupon_user_status_expire''',
    'ALTER TABLE `user_coupon` ADD INDEX `idx_user_coupon_user_status_expire`(`user_id`,`status`,`expire_date`)'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- track_event_log index
SET @sql := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = @db
        AND table_name = 'track_event_log'
        AND index_name = 'idx_track_user_time'
    ),
    'SELECT ''skip idx_track_user_time''',
    'ALTER TABLE `track_event_log` ADD INDEX `idx_track_user_time`(`user_id`,`create_time`)'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

ALTER TABLE `seasonal_config`
  COMMENT = '当季精选运营配置表（用于权重/文案模板/季节关键词配置）';

-- goods_sku.spec_type
SET @sql := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = @db
        AND table_name = 'goods_sku'
        AND column_name = 'spec_type'
    ),
    'SELECT ''skip goods_sku.spec_type''',
    'ALTER TABLE `goods_sku` ADD COLUMN `spec_type` varchar(32) NULL DEFAULT NULL COMMENT ''规格类型：standard/single/family/platter'' AFTER `sort`'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- goods_sku.spec_value
SET @sql := (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.columns
      WHERE table_schema = @db
        AND table_name = 'goods_sku'
        AND column_name = 'spec_value'
    ),
    'SELECT ''skip goods_sku.spec_value''',
    'ALTER TABLE `goods_sku` ADD COLUMN `spec_value` varchar(64) NULL DEFAULT NULL COMMENT ''规格值：如一人食/双人装/三拼盘'' AFTER `spec_type`'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE TABLE IF NOT EXISTS `sku_component`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `sku_id` bigint(20) NOT NULL COMMENT 'SKU ID',
  `component_goods_id` bigint(20) NOT NULL COMMENT '组成商品ID',
  `component_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '组成项名称',
  `component_weight_g` int(11) NULL DEFAULT 0 COMMENT '组成项克重',
  `quantity` int(11) NOT NULL DEFAULT 1 COMMENT '数量',
  `component_price` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '组成项单价',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sku_component_sku_id`(`sku_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '组合SKU组成项表' ROW_FORMAT = DYNAMIC;

UPDATE `goods_sku` SET `spec_type` = 'standard', `spec_value` = '标准装' WHERE `spec_type` IS NULL;

INSERT INTO `goods_sku`(`id`, `goods_id`, `sku_name`, `sku_weight_g`, `sku_price`, `sku_stock`, `status`, `sort`, `spec_type`, `spec_value`)
SELECT 10001, 13, '一人食装', 300, 6.90, 120, 1, 10, 'single', '一人食'
WHERE NOT EXISTS (SELECT 1 FROM `goods_sku` WHERE `id` = 10001);

INSERT INTO `goods_sku`(`id`, `goods_id`, `sku_name`, `sku_weight_g`, `sku_price`, `sku_stock`, `status`, `sort`, `spec_type`, `spec_value`)
SELECT 10002, 13, '双人分享装', 700, 15.80, 80, 1, 20, 'family', '双人装'
WHERE NOT EXISTS (SELECT 1 FROM `goods_sku` WHERE `id` = 10002);

INSERT INTO `goods_sku`(`id`, `goods_id`, `sku_name`, `sku_weight_g`, `sku_price`, `sku_stock`, `status`, `sort`, `spec_type`, `spec_value`)
SELECT 10003, 13, '果蔬三拼盘', 900, 19.90, 60, 1, 30, 'platter', '三拼盘'
WHERE NOT EXISTS (SELECT 1 FROM `goods_sku` WHERE `id` = 10003);

INSERT INTO `sku_component`(`sku_id`, `component_goods_id`, `component_name`, `component_weight_g`, `quantity`, `component_price`, `sort`)
SELECT 10003, 13, '红富士苹果', 300, 1, 9.80, 1
WHERE NOT EXISTS (SELECT 1 FROM `sku_component` WHERE `sku_id` = 10003 AND `component_goods_id` = 13 AND `sort` = 1);

INSERT INTO `sku_component`(`sku_id`, `component_goods_id`, `component_name`, `component_weight_g`, `quantity`, `component_price`, `sort`)
SELECT 10003, 4, '黄瓜', 300, 1, 8.80, 2
WHERE NOT EXISTS (SELECT 1 FROM `sku_component` WHERE `sku_id` = 10003 AND `component_goods_id` = 4 AND `sort` = 2);

INSERT INTO `sku_component`(`sku_id`, `component_goods_id`, `component_name`, `component_weight_g`, `quantity`, `component_price`, `sort`)
SELECT 10003, 7, '西红柿', 300, 1, 3.80, 3
WHERE NOT EXISTS (SELECT 1 FROM `sku_component` WHERE `sku_id` = 10003 AND `component_goods_id` = 7 AND `sort` = 3);

-- check results
SELECT 'goods_tag.uk_goods_tag_goods_tag' AS item, COUNT(1) AS ok_count
FROM information_schema.statistics
WHERE table_schema = @db AND table_name = 'goods_tag' AND index_name = 'uk_goods_tag_goods_tag';

SELECT 'tag.uk_tag_name' AS item, COUNT(1) AS ok_count
FROM information_schema.statistics
WHERE table_schema = @db AND table_name = 'tag' AND index_name = 'uk_tag_name';

SELECT 'user_coupon.idx_user_coupon_user_status_expire' AS item, COUNT(1) AS ok_count
FROM information_schema.statistics
WHERE table_schema = @db AND table_name = 'user_coupon' AND index_name = 'idx_user_coupon_user_status_expire';

SELECT 'track_event_log.idx_track_user_time' AS item, COUNT(1) AS ok_count
FROM information_schema.statistics
WHERE table_schema = @db AND table_name = 'track_event_log' AND index_name = 'idx_track_user_time';

SELECT 'goods_sku.spec_type' AS item, COUNT(1) AS ok_count
FROM information_schema.columns
WHERE table_schema = @db AND table_name = 'goods_sku' AND column_name = 'spec_type';

SELECT 'goods_sku.spec_value' AS item, COUNT(1) AS ok_count
FROM information_schema.columns
WHERE table_schema = @db AND table_name = 'goods_sku' AND column_name = 'spec_value';

SELECT 'sku_component.exists' AS item, COUNT(1) AS ok_count
FROM information_schema.tables
WHERE table_schema = @db AND table_name = 'sku_component';

SET FOREIGN_KEY_CHECKS = 1;
