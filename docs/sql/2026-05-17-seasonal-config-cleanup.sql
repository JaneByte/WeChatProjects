-- 2026-05-17
-- 清理 seasonal_config 中旧关键词配置项
-- 说明：当季推荐已切为纯标签，不再依赖 keywords.spring/summer/autumn/winter

DELETE FROM `seasonal_config`
WHERE `config_key` IN ('keywords.spring', 'keywords.summer', 'keywords.autumn', 'keywords.winter');

-- 审计
SELECT `id`, `config_key`, `config_value`, `update_time`
FROM `seasonal_config`
ORDER BY `id` ASC;
