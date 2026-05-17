SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 当季精选运营配置表（增量脚本，不依赖修改主SQL）
DROP TABLE IF EXISTS `seasonal_config`;
CREATE TABLE `seasonal_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '配置值',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '当季精选运营配置表' ROW_FORMAT = Dynamic;

INSERT INTO `seasonal_config` (`id`, `config_key`, `config_value`, `update_time`) VALUES
(1, 'weight.season', '0.26', CURRENT_TIMESTAMP),
(2, 'weight.freshness', '0.18', CURRENT_TIMESTAMP),
(3, 'weight.sales', '0.18', CURRENT_TIMESTAMP),
(4, 'weight.margin', '0.14', CURRENT_TIMESTAMP),
(5, 'weight.stock', '0.14', CURRENT_TIMESTAMP),
(6, 'weight.budget', '0.10', CURRENT_TIMESTAMP),
(7, 'title.template', '{seasonText}当季精选', CURRENT_TIMESTAMP),
(8, 'subtitle.template', '优先新鲜度、当季适配和库存稳定性', CURRENT_TIMESTAMP),
(9, 'keywords.spring', '春,草莓,香椿,豌豆,春笋', CURRENT_TIMESTAMP),
(10, 'keywords.summer', '夏,西瓜,黄瓜,番茄,苦瓜', CURRENT_TIMESTAMP),
(11, 'keywords.autumn', '秋,南瓜,梨,柿子,莲藕', CURRENT_TIMESTAMP),
(12, 'keywords.winter', '冬,白菜,萝卜,橙,柚,菌菇', CURRENT_TIMESTAMP);

SET FOREIGN_KEY_CHECKS = 1;