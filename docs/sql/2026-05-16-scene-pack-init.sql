-- 一人食/蔬果搭配 组合商品初始化
-- 适用：MySQL 5.7+

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `scene_pack` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `scene_type` varchar(32) NOT NULL COMMENT 'small_portion/combo_bundle',
  `pack_mode` varchar(32) NOT NULL COMMENT 'single_portion/platter/fixed_bundle/random_bundle',
  `cover_image` varchar(500) DEFAULT NULL,
  `summary` varchar(255) DEFAULT NULL,
  `price` decimal(10,2) NOT NULL,
  `original_price` decimal(10,2) DEFAULT NULL,
  `stock` int(11) NOT NULL DEFAULT 0,
  `coupon_threshold_hint` varchar(100) DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1,
  `sort` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `scene_pack_item` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `pack_id` bigint(20) NOT NULL,
  `goods_id` bigint(20) NOT NULL,
  `sku_id` bigint(20) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `item_role` varchar(32) DEFAULT NULL COMMENT 'vegetable/fruit',
  `sort` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `idx_pack_id` (`pack_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 示例：一人食小份组合
INSERT INTO `scene_pack` (`name`,`scene_type`,`pack_mode`,`cover_image`,`summary`,`price`,`original_price`,`stock`,`coupon_threshold_hint`,`status`,`sort`)
SELECT '一人食轻享盒A','small_portion','platter',g.main_image,'2种水果小份拼盘，适合单人当天食用',19.90,26.80,80,'建议凑单到满39更划算',1,1
FROM `goods` g
WHERE g.id = 1
  AND NOT EXISTS (SELECT 1 FROM `scene_pack` WHERE `name`='一人食轻享盒A');

-- 示例：蔬果搭配组合
INSERT INTO `scene_pack` (`name`,`scene_type`,`pack_mode`,`cover_image`,`summary`,`price`,`original_price`,`stock`,`coupon_threshold_hint`,`status`,`sort`)
SELECT '两蔬一果搭配A','combo_bundle','fixed_bundle',g.main_image,'2份蔬菜+1份水果，家庭日常搭配',49.90,58.80,60,'满50可用满减券',1,1
FROM `goods` g
WHERE g.id = 49
  AND NOT EXISTS (SELECT 1 FROM `scene_pack` WHERE `name`='两蔬一果搭配A');

-- 绑定明细（按标准装SKU）
INSERT INTO `scene_pack_item` (`pack_id`,`goods_id`,`sku_id`,`quantity`,`item_role`,`sort`)
SELECT p.id, 1, s.id, 1, 'fruit', 1
FROM `scene_pack` p
JOIN `goods_sku` s ON s.goods_id = 1 AND s.sku_name = '标准装'
WHERE p.name='一人食轻享盒A'
  AND NOT EXISTS (
    SELECT 1 FROM `scene_pack_item` x
    WHERE x.pack_id = p.id AND x.goods_id = 1
  );

INSERT INTO `scene_pack_item` (`pack_id`,`goods_id`,`sku_id`,`quantity`,`item_role`,`sort`)
SELECT p.id, 2, s.id, 1, 'fruit', 2
FROM `scene_pack` p
JOIN `goods_sku` s ON s.goods_id = 2 AND s.sku_name = '标准装'
WHERE p.name='一人食轻享盒A'
  AND NOT EXISTS (
    SELECT 1 FROM `scene_pack_item` x
    WHERE x.pack_id = p.id AND x.goods_id = 2
  );

INSERT INTO `scene_pack_item` (`pack_id`,`goods_id`,`sku_id`,`quantity`,`item_role`,`sort`)
SELECT p.id, 49, s.id, 1, 'vegetable', 1
FROM `scene_pack` p
JOIN `goods_sku` s ON s.goods_id = 49 AND s.sku_name = '标准装'
WHERE p.name='两蔬一果搭配A'
  AND NOT EXISTS (
    SELECT 1 FROM `scene_pack_item` x
    WHERE x.pack_id = p.id AND x.goods_id = 49
  );

INSERT INTO `scene_pack_item` (`pack_id`,`goods_id`,`sku_id`,`quantity`,`item_role`,`sort`)
SELECT p.id, 57, s.id, 1, 'vegetable', 2
FROM `scene_pack` p
JOIN `goods_sku` s ON s.goods_id = 57 AND s.sku_name = '标准装'
WHERE p.name='两蔬一果搭配A'
  AND NOT EXISTS (
    SELECT 1 FROM `scene_pack_item` x
    WHERE x.pack_id = p.id AND x.goods_id = 57
  );

INSERT INTO `scene_pack_item` (`pack_id`,`goods_id`,`sku_id`,`quantity`,`item_role`,`sort`)
SELECT p.id, 13, s.id, 1, 'fruit', 3
FROM `scene_pack` p
JOIN `goods_sku` s ON s.goods_id = 13 AND s.sku_name = '标准装'
WHERE p.name='两蔬一果搭配A'
  AND NOT EXISTS (
    SELECT 1 FROM `scene_pack_item` x
    WHERE x.pack_id = p.id AND x.goods_id = 13
  );

SET FOREIGN_KEY_CHECKS = 1;

