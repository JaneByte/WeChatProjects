SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `goods`
  ADD COLUMN `season_start_month` tinyint(4) NULL DEFAULT NULL COMMENT '供应起始月 1-12' AFTER `keywords`,
  ADD COLUMN `season_end_month` tinyint(4) NULL DEFAULT NULL COMMENT '供应结束月 1-12' AFTER `season_start_month`,
  ADD COLUMN `season_late_threshold_days` int(11) NOT NULL DEFAULT 20 COMMENT '季末提示阈值天数' AFTER `season_end_month`,
  ADD COLUMN `season_early_hint` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '季初提示' AFTER `season_late_threshold_days`,
  ADD COLUMN `season_peak_hint` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '应季提示' AFTER `season_early_hint`,
  ADD COLUMN `season_late_hint` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '季末提示' AFTER `season_peak_hint`;

SET FOREIGN_KEY_CHECKS = 1;
