SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `plan_rule_config` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `rule_key` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规则键',
  `rule_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '规则值，逗号分隔',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `uk_rule_key` (`rule_key`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci COMMENT='方案规则配置表';

INSERT INTO `plan_rule_config` (`rule_key`, `rule_value`) VALUES
('plan.strong_flavor_keywords', '洋葱,大葱,蒜,韭菜,蒜苗,苦瓜'),
('plan.juice_blacklist_keywords', '蒜,洋葱,大葱,香葱,韭菜,辣椒'),
('plan.salad_blacklist_keywords', '榴莲,菠萝蜜,蒜苗,大葱,洋葱'),
('plan.hotpot_blacklist_keywords', '鲜切即食,果切杯,即食水果杯'),
('plan.starchy_keywords', '土豆,南瓜,玉米,红薯,芋头,山药,香蕉'),
('plan.watery_fruit_keywords', '西瓜,哈密瓜,香瓜,椰青,柚子'),
('plan.juice_conflict_pairs', '黄瓜|香蕉,番茄|香蕉'),
('plan.salad_conflict_pairs', '土豆|西瓜,洋葱|草莓'),
('plan.general_conflict_pairs', '榴莲|柠檬')
ON DUPLICATE KEY UPDATE `rule_value` = VALUES(`rule_value`);

SET FOREIGN_KEY_CHECKS = 1;
