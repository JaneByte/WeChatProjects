-- 清理 FreshTime 业务测试数据（不改表结构）
-- 执行前请先备份

START TRANSACTION;

-- 清空高频测试数据
DELETE FROM `order_item`;
DELETE FROM `order`;
DELETE FROM `cart`;
DELETE FROM `track_event_log`;
DELETE FROM `user_coupon`;

-- 可选：若需要保留已运营订单，请改为按测试用户清理
-- DELETE oi FROM `order_item` oi JOIN `order` o ON oi.order_id = o.id WHERE o.user_id IN (1);
-- DELETE FROM `order` WHERE user_id IN (1);
-- DELETE FROM `cart` WHERE user_id IN (1);
-- DELETE FROM `user_coupon` WHERE user_id IN (1);

COMMIT;
