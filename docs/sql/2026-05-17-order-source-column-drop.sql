SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP PROCEDURE IF EXISTS `sp_drop_order_source_columns`;
DELIMITER ;;
CREATE PROCEDURE `sp_drop_order_source_columns`()
BEGIN
  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'source_scene'
  ) THEN
    ALTER TABLE `cart` DROP COLUMN `source_scene`;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'source_plan_id'
  ) THEN
    ALTER TABLE `cart` DROP COLUMN `source_plan_id`;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'source_type'
  ) THEN
    ALTER TABLE `cart` DROP COLUMN `source_type`;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order_item'
      AND COLUMN_NAME = 'source_scene'
  ) THEN
    ALTER TABLE `order_item` DROP COLUMN `source_scene`;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order_item'
      AND COLUMN_NAME = 'source_plan_id'
  ) THEN
    ALTER TABLE `order_item` DROP COLUMN `source_plan_id`;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order_item'
      AND COLUMN_NAME = 'source_type'
  ) THEN
    ALTER TABLE `order_item` DROP COLUMN `source_type`;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order'
      AND COLUMN_NAME = 'order_source'
  ) THEN
    ALTER TABLE `order` DROP COLUMN `order_source`;
  END IF;
END;;
DELIMITER ;

CALL `sp_drop_order_source_columns`();
DROP PROCEDURE IF EXISTS `sp_drop_order_source_columns`;

SET FOREIGN_KEY_CHECKS = 1;
