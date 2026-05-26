-- 补充方案规则配置缺失键：小份优选 / 火锅 / 便当冲突对
-- 执行前请确认当前库为 freshtime

INSERT INTO `plan_rule_config` (`rule_key`, `rule_value`)
VALUES ('plan.meal_conflict_pairs', '')
ON DUPLICATE KEY UPDATE
`rule_value` = VALUES(`rule_value`),
`update_time` = NOW();

INSERT INTO `plan_rule_config` (`rule_key`, `rule_value`)
VALUES ('plan.hotpot_conflict_pairs', '')
ON DUPLICATE KEY UPDATE
`rule_value` = VALUES(`rule_value`),
`update_time` = NOW();

INSERT INTO `plan_rule_config` (`rule_key`, `rule_value`)
VALUES ('plan.bento_conflict_pairs', '')
ON DUPLICATE KEY UPDATE
`rule_value` = VALUES(`rule_value`),
`update_time` = NOW();
