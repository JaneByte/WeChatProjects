-- FreshTime SKU baseline migration (idempotent)
-- Date: 2026-05-17
-- Goal: each active goods has at least 2 SKUs (standard + single)

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;
SET @db := DATABASE();

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

UPDATE `goods_sku`
SET `spec_type` = IFNULL(`spec_type`, 'standard'),
    `spec_value` = IFNULL(`spec_value`, '标准装')
WHERE `spec_type` IS NULL OR `spec_value` IS NULL;

INSERT INTO `goods_sku`(`goods_id`, `sku_name`, `sku_weight_g`, `sku_price`, `sku_stock`, `status`, `sort`, `spec_type`, `spec_value`)
SELECT
  g.id AS goods_id,
  '一人食装' AS sku_name,
  GREATEST(200, FLOOR(COALESCE(s.sku_weight_g, 500) * 0.6)) AS sku_weight_g,
  ROUND(COALESCE(s.sku_price, g.price, 0) * 0.68, 2) AS sku_price,
  GREATEST(10, FLOOR(COALESCE(s.sku_stock, g.stock, 0) * 0.5)) AS sku_stock,
  1 AS status,
  50 AS sort,
  'single' AS spec_type,
  '一人食' AS spec_value
FROM `goods` g
LEFT JOIN (
  SELECT x.goods_id, x.sku_weight_g, x.sku_price, x.sku_stock
  FROM `goods_sku` x
  INNER JOIN (
    SELECT goods_id, MIN(id) AS min_id
    FROM `goods_sku`
    WHERE status = 1
    GROUP BY goods_id
  ) y ON y.min_id = x.id
) s ON s.goods_id = g.id
WHERE g.status = 1
  AND NOT EXISTS (
    SELECT 1 FROM `goods_sku` k
    WHERE k.goods_id = g.id
      AND (k.spec_type = 'single' OR k.spec_value = '一人食')
  );

SELECT 'active_goods_count' AS item, COUNT(1) AS value
FROM `goods` WHERE status = 1;

SELECT 'goods_with_at_least_two_skus' AS item, COUNT(1) AS value
FROM (
  SELECT goods_id
  FROM `goods_sku`
  WHERE status = 1
  GROUP BY goods_id
  HAVING COUNT(1) >= 2
) t;

SET FOREIGN_KEY_CHECKS = 1;
