-- FreshTime 首页快捷入口数据补齐包（最小改动）
-- 执行日期：2026-05-09
-- 目标：补齐 tag / goods_tag / home_nav / coupon 基础数据

USE `freshtime`;

-- 0) coupon 主表（若不存在则创建）
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='优惠券模板表';

-- 1) 标签主数据（可重复执行）
INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 101, '时令', 2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 101 OR `tag_name` = '时令');

INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 102, '小份量', 2 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 102 OR `tag_name` = '小份量');

INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 103, '搭配', 3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 103 OR `tag_name` = '搭配');

INSERT INTO `tag` (`id`, `tag_name`, `type`)
SELECT 104, '领券专区', 3 FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 104 OR `tag_name` = '领券专区');

-- 2) 商品标签映射（按现有商品ID做最小覆盖，可重复执行）
-- 时令
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 1, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 1 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 4, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 4 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 10, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 10 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 13, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 13 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 19, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 19 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 21, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 21 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 28, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 28 AND `tag_id` = 101);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 34, 101 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 34 AND `tag_id` = 101);

-- 小份量
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 2, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 2 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 6, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 6 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 12, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 12 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 18, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 18 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 23, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 23 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 29, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 29 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 31, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 31 AND `tag_id` = 102);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 37, 102 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 37 AND `tag_id` = 102);

-- 搭配
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 3, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 3 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 5, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 5 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 9, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 9 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 11, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 11 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 14, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 14 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 16, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 16 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 24, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 24 AND `tag_id` = 103);
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 30, 103 FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM `goods_tag` WHERE `goods_id` = 30 AND `tag_id` = 103);

-- 3) 首页快捷入口配置（同步为最终版本）
DELETE FROM `home_nav` WHERE `nav_type` IN ('salad', 'quickMeal', 'fruitPlate', 'stockUp');

INSERT INTO `home_nav` (`id`, `nav_type`, `nav_text`, `icon_text`, `link_type`, `link_value`, `sort`, `status`, `create_time`)
SELECT 1, 'couponZone', '领券福利', '券', 'goods', 'coupon', 1, 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `id` = 1 OR `nav_type` = 'couponZone');

INSERT INTO `home_nav` (`id`, `nav_type`, `nav_text`, `icon_text`, `link_type`, `link_value`, `sort`, `status`, `create_time`)
SELECT 2, 'seasonalFresh', '当季鲜选', '时', 'search', '时令', 2, 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `id` = 2 OR `nav_type` = 'seasonalFresh');

INSERT INTO `home_nav` (`id`, `nav_type`, `nav_text`, `icon_text`, `link_type`, `link_value`, `sort`, `status`, `create_time`)
SELECT 3, 'smallPortion', '一人食小份', '小', 'scene', '小份量', 3, 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `id` = 3 OR `nav_type` = 'smallPortion');

INSERT INTO `home_nav` (`id`, `nav_type`, `nav_text`, `icon_text`, `link_type`, `link_value`, `sort`, `status`, `create_time`)
SELECT 4, 'comboMix', '蔬果搭配', '搭', 'scene', '搭配', 4, 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `home_nav` WHERE `id` = 4 OR `nav_type` = 'comboMix');

-- 4) coupon 主表种子（可领券池，供“领券福利”逻辑读取）
INSERT INTO `coupon` (`id`, `name`, `description`, `threshold_amount`, `discount_amount`, `expire_date`, `status`, `create_time`)
SELECT 9001, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `coupon` WHERE `id` = 9001);

INSERT INTO `coupon` (`id`, `name`, `description`, `threshold_amount`, `discount_amount`, `expire_date`, `status`, `create_time`)
SELECT 9002, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `coupon` WHERE `id` = 9002);

INSERT INTO `coupon` (`id`, `name`, `description`, `threshold_amount`, `discount_amount`, `expire_date`, `status`, `create_time`)
SELECT 9003, '满39减5', '新人专享', 39.00, 5.00, '2026-12-31', 1, NOW()
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `coupon` WHERE `id` = 9003);
