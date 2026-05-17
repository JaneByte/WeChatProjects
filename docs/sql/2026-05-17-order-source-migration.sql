SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP PROCEDURE IF EXISTS `sp_apply_order_source_migration`;
DELIMITER ;;
CREATE PROCEDURE `sp_apply_order_source_migration`()
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'source_type'
  ) THEN
    ALTER TABLE `cart`
      ADD COLUMN `source_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'NORMAL' COMMENT '来源类型 NORMAL/MEAL/COMBO/SEASONAL/MIXED' AFTER `selected`;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'source_plan_id'
  ) THEN
    ALTER TABLE `cart`
      ADD COLUMN `source_plan_id` bigint(20) NULL DEFAULT NULL COMMENT '来源方案ID' AFTER `source_type`;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'source_scene'
  ) THEN
    ALTER TABLE `cart`
      ADD COLUMN `source_scene` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源场景' AFTER `source_plan_id`;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order'
      AND COLUMN_NAME = 'order_source'
  ) THEN
    ALTER TABLE `order`
      ADD COLUMN `order_source` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'NORMAL' COMMENT '订单来源 NORMAL/MEAL/COMBO/SEASONAL/MIXED' AFTER `coupon_id`;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order_item'
      AND COLUMN_NAME = 'source_type'
  ) THEN
    ALTER TABLE `order_item`
      ADD COLUMN `source_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'NORMAL' COMMENT '来源类型 NORMAL/MEAL/COMBO/SEASONAL/MIXED' AFTER `total_price`;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order_item'
      AND COLUMN_NAME = 'source_plan_id'
  ) THEN
    ALTER TABLE `order_item`
      ADD COLUMN `source_plan_id` bigint(20) NULL DEFAULT NULL COMMENT '来源方案ID' AFTER `source_type`;
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order_item'
      AND COLUMN_NAME = 'source_scene'
  ) THEN
    ALTER TABLE `order_item`
      ADD COLUMN `source_scene` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '来源场景' AFTER `source_plan_id`;
  END IF;

  UPDATE `cart`
  SET `source_type` = 'NORMAL'
  WHERE (`source_type` IS NULL OR TRIM(`source_type`) = '');

  UPDATE `order`
  SET `order_source` = 'NORMAL'
  WHERE (`order_source` IS NULL OR TRIM(`order_source`) = '');

  UPDATE `order_item`
  SET `source_type` = 'NORMAL'
  WHERE (`source_type` IS NULL OR TRIM(`source_type`) = '');
END;;
DELIMITER ;

CALL `sp_apply_order_source_migration`();
DROP PROCEDURE IF EXISTS `sp_apply_order_source_migration`;

SET FOREIGN_KEY_CHECKS = 1;
