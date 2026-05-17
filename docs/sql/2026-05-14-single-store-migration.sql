-- 2026-05-14-single-store-migration.sql
-- 作用：将项目结构从多商户预留模式收口为单商户模式
USE `freshtime`;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'admin'
      AND COLUMN_NAME = 'shop_name'
  ),
  'SELECT 1',
  'ALTER TABLE `admin` ADD COLUMN `shop_name` varchar(64) NOT NULL DEFAULT '''' COMMENT ''店铺名称'' AFTER `nickname`'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'admin'
      AND COLUMN_NAME = 'contact_name'
  ),
  'SELECT 1',
  'ALTER TABLE `admin` ADD COLUMN `contact_name` varchar(32) NULL DEFAULT NULL COMMENT ''联系人姓名'' AFTER `shop_name`'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'admin'
      AND COLUMN_NAME = 'phone'
  ),
  'SELECT 1',
  'ALTER TABLE `admin` ADD COLUMN `phone` varchar(20) NULL DEFAULT NULL COMMENT ''联系电话'' AFTER `contact_name`'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'admin'
      AND COLUMN_NAME = 'address'
  ),
  'SELECT 1',
  'ALTER TABLE `admin` ADD COLUMN `address` varchar(256) NULL DEFAULT NULL COMMENT ''店铺地址'' AFTER `phone`'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'admin'
      AND COLUMN_NAME = 'description'
  ),
  'SELECT 1',
  'ALTER TABLE `admin` ADD COLUMN `description` text NULL COMMENT ''店铺简介'' AFTER `address`'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

UPDATE `admin`
SET `shop_name` = '鲜果时光旗舰店',
    `contact_name` = '张三',
    `phone` = '075157183889',
    `address` = '湖南省长沙市天心区文源街道',
    `description` = NULL
WHERE `username` = 'admin'
  AND (`shop_name` = '' OR `shop_name` IS NULL);

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'goods'
      AND INDEX_NAME = 'idx_merchant_id'
  ),
  'ALTER TABLE `goods` DROP INDEX `idx_merchant_id`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'goods'
      AND COLUMN_NAME = 'merchant_id'
  ),
  'ALTER TABLE `goods` DROP COLUMN `merchant_id`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'cart'
      AND COLUMN_NAME = 'merchant_id'
  ),
  'ALTER TABLE `cart` DROP COLUMN `merchant_id`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'comment'
      AND COLUMN_NAME = 'merchant_id'
  ),
  'ALTER TABLE `comment` DROP COLUMN `merchant_id`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order'
      AND INDEX_NAME = 'idx_merchant_id'
  ),
  'ALTER TABLE `order` DROP INDEX `idx_merchant_id`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'order'
      AND COLUMN_NAME = 'merchant_id'
  ),
  'ALTER TABLE `order` DROP COLUMN `merchant_id`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'merchant'
  ),
  'DROP TABLE `merchant`',
  'SELECT 1'
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
