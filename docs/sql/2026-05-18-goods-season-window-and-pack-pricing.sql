SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `goods_season_window` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `season_code` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '季节编码 spring/summer/autumn/winter',
  `start_month` tinyint(4) NOT NULL COMMENT '开始月份 1-12',
  `end_month` tinyint(4) NOT NULL COMMENT '结束月份 1-12',
  `early_hint` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '季初提示',
  `peak_hint` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '应季提示',
  `late_hint` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '季末提示',
  `late_threshold_days` int(11) NOT NULL DEFAULT 20 COMMENT '季末提示阈值天数',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 1启用 0停用',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_goods_season_window` (`goods_id`, `season_code`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='商品时令供应期窗口表';

CREATE TABLE IF NOT EXISTS `pack_pricing_rule` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规则键',
  `rule_value` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规则值',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '规则说明',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_pack_pricing_rule_key` (`rule_key`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='套餐优惠规则表';

INSERT INTO `pack_pricing_rule` (`rule_key`, `rule_value`, `description`) VALUES
('pack.combo.discount_rate', '0.05', '蔬果搭配默认折扣率'),
('pack.combo.min_discount', '2.00', '蔬果搭配最低优惠额'),
('pack.combo.max_discount', '12.00', '蔬果搭配最高优惠额'),
('pack.meal.discount_rate', '0.03', '一人食默认折扣率'),
('pack.meal.min_discount', '1.00', '一人食最低优惠额'),
('pack.meal.max_discount', '8.00', '一人食最高优惠额')
ON DUPLICATE KEY UPDATE
`rule_value` = VALUES(`rule_value`),
`description` = VALUES(`description`);

SET FOREIGN_KEY_CHECKS = 1;
