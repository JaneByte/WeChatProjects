-- 推荐先执行（兼容版，不依赖存储过程）：
-- docs/sql/flash_pool_dynamic_refresh_mysql_safe.sql

-- 后端接口联调：
-- POST /api/admin/flash/refresh?targetCount=18
-- GET  /api/admin/flash/overview?previewLimit=20

-- 如果你已经成功创建过存储过程，才可执行：
-- CALL refresh_flash_pool(18);
-- 否则请直接执行：
-- docs/sql/flash_pool_dynamic_refresh_mysql_safe.sql

-- 刷新后核验：
SELECT COUNT(*) AS flash_count FROM goods WHERE status=1 AND is_flash=1;
SELECT id,name,price,flash_price,stock,flash_stock,flash_start_time,flash_end_time
FROM goods WHERE status=1 AND is_flash=1 ORDER BY flash_start_time,id LIMIT 30;
