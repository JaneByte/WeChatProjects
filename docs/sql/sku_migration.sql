-- SKU 多规格改造迁移脚本（执行前请先备份数据库）
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1) 新增 goods_sku 表
CREATE TABLE IF NOT EXISTS `goods_sku` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `goods_id` bigint(20) NOT NULL,
  `sku_name` varchar(64) NOT NULL COMMENT '规格名称，如250g/盒',
  `sku_weight_g` int(11) DEFAULT NULL COMMENT '规格重量(g)',
  `sku_price` decimal(10,2) NOT NULL,
  `sku_stock` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  `sort` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_goods_id` (`goods_id`),
  CONSTRAINT `fk_goods_sku_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品SKU规格表';

-- 2) cart 增加 sku_id 字段并重建唯一索引
ALTER TABLE `cart`
  ADD COLUMN IF NOT EXISTS `sku_id` bigint(20) NULL COMMENT '商品规格ID' AFTER `goods_id`;

-- 兼容旧数据：暂时把 sku_id 留空，初始化后再回填
ALTER TABLE `cart` DROP INDEX `uk_user_goods`;
ALTER TABLE `cart` ADD UNIQUE INDEX `uk_user_goods_sku`(`user_id`, `goods_id`, `sku_id`);

-- 3) order_item 增加 SKU 快照字段
ALTER TABLE `order_item`
  ADD COLUMN IF NOT EXISTS `sku_id` bigint(20) NULL AFTER `goods_id`,
  ADD COLUMN IF NOT EXISTS `sku_name` varchar(64) NULL AFTER `goods_image`,
  ADD COLUMN IF NOT EXISTS `sku_weight_g` int(11) NULL AFTER `sku_name`;

-- 4) 为现有 goods 初始化“标准装”SKU（幂等）
INSERT INTO `goods_sku` (`goods_id`, `sku_name`, `sku_weight_g`, `sku_price`, `sku_stock`, `status`, `sort`)
SELECT g.id, '标准装', 500, g.price, g.stock, 1, 0
FROM `goods` g
LEFT JOIN `goods_sku` s ON s.goods_id = g.id
WHERE s.id IS NULL;

-- 5) 回填旧 cart 数据的 sku_id -> 对应标准装
UPDATE `cart` c
JOIN `goods_sku` s ON s.goods_id = c.goods_id AND s.sku_name = '标准装'
SET c.sku_id = s.id
WHERE c.sku_id IS NULL;

-- 6) 回填旧 order_item 数据的 SKU 快照 -> 对应标准装
UPDATE `order_item` oi
JOIN `goods_sku` s ON s.goods_id = oi.goods_id AND s.sku_name = '标准装'
SET oi.sku_id = s.id,
    oi.sku_name = s.sku_name,
    oi.sku_weight_g = s.sku_weight_g
WHERE oi.sku_id IS NULL;

-- 7) 为一人食/搭配示例追加 250g 子规格（避免重复）
INSERT INTO `goods_sku` (`goods_id`, `sku_name`, `sku_weight_g`, `sku_price`, `sku_stock`, `status`, `sort`)
SELECT g.id, '250g/盒', 250, ROUND(g.price * 0.55, 2), GREATEST(1, FLOOR(g.stock * 0.6)), 1, 1
FROM `goods` g
LEFT JOIN `goods_sku` s ON s.goods_id = g.id AND s.sku_name = '250g/盒'
WHERE s.id IS NULL
  AND (
    g.keywords LIKE '%小份%'
    OR g.keywords LIKE '%搭配%'
    OR g.name LIKE '%番茄%'
    OR g.name LIKE '%黄瓜%'
    OR g.name LIKE '%草莓%'
    OR g.name LIKE '%蓝莓%'
  );

SET FOREIGN_KEY_CHECKS = 1;
