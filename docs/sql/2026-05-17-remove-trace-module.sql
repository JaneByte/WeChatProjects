-- 2026-05-17
-- 下线“产地溯源”模块数据库清理脚本
-- 仅删除溯源相关表，不影响商品主链路

START TRANSACTION;

DROP TABLE IF EXISTS `trace_record`;

COMMIT;

-- 审计：确认表已删除
SELECT TABLE_NAME
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN ('trace_record');
