SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 增量演示数据脚本：order / order_item / comment / user_coupon
-- 不修改表结构，仅补业务演示所需数据

-- 1) 用户优惠券（确保领券链路有可见数据）
INSERT INTO `user_coupon` (`id`, `user_id`, `title`, `condition_text`, `threshold_amount`, `discount_amount`, `expire_date`, `status`, `create_time`) VALUES
(1001, 1, '满50减8', '满50元可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-16 10:00:00'),
(1002, 1, '满99减15', '生鲜专区可用', 99.00, 15.00, '2026-12-31', 1, '2026-05-16 10:05:00')
ON DUPLICATE KEY UPDATE
`title` = VALUES(`title`),
`condition_text` = VALUES(`condition_text`),
`threshold_amount` = VALUES(`threshold_amount`),
`discount_amount` = VALUES(`discount_amount`),
`expire_date` = VALUES(`expire_date`),
`status` = VALUES(`status`);

-- 2) 订单主表（含待发货/待收货/已完成三种状态）
INSERT INTO `order`
(`id`, `order_no`, `user_id`, `total_amount`, `discount_amount`, `actual_amount`, `receiver_name`, `receiver_phone`, `receiver_address`, `remark`, `coupon_id`, `status`, `pay_channel`, `pay_trade_no`, `pay_status`, `pay_time`, `deliver_time`, `finish_time`, `cancel_time`, `create_time`)
VALUES
(1001, 'FT202605160001', 1, 58.60, 8.00, 50.60, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '少辣', 1, 1, 'mock_wechat', 'MOCK_TRADE_1001', 2, '2026-05-16 09:05:00', NULL, NULL, NULL, '2026-05-16 09:00:00'),
(1002, 'FT202605160002', 1, 42.80, 0.00, 42.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '尽快送达', NULL, 2, 'mock_wechat', 'MOCK_TRADE_1002', 2, '2026-05-16 11:03:00', '2026-05-16 12:00:00', NULL, NULL, '2026-05-16 11:00:00'),
(1003, 'FT202605160003', 1, 76.40, 5.00, 71.40, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '放门口', 3, 3, 'mock_wechat', 'MOCK_TRADE_1003', 2, '2026-05-15 18:02:00', '2026-05-15 19:00:00', '2026-05-16 08:30:00', NULL, '2026-05-15 18:00:00')
ON DUPLICATE KEY UPDATE
`total_amount` = VALUES(`total_amount`),
`discount_amount` = VALUES(`discount_amount`),
`actual_amount` = VALUES(`actual_amount`),
`status` = VALUES(`status`),
`pay_status` = VALUES(`pay_status`),
`pay_time` = VALUES(`pay_time`),
`deliver_time` = VALUES(`deliver_time`),
`finish_time` = VALUES(`finish_time`);

-- 3) 订单明细（与上面订单、现有goods强关联）
INSERT INTO `order_item`
(`id`, `order_id`, `goods_id`, `sku_id`, `goods_name`, `goods_image`, `sku_name`, `sku_weight_g`, `price`, `quantity`, `total_price`)
VALUES
(2001, 1001, 4, 4, '橙子', NULL, '标准装', 500, 8.80, 2, 17.60),
(2002, 1001, 13, 13, '红富士苹果', NULL, '标准装', 500, 9.80, 2, 19.60),
(2003, 1001, 19, 19, '豆芽', NULL, '标准装', 500, 8.60, 1, 8.60),
(2004, 1002, 1, 1, '草莓', NULL, '标准装', 500, 25.80, 1, 25.80),
(2005, 1002, 6, 6, '柠檬', NULL, '标准装', 500, 6.80, 1, 6.80),
(2006, 1002, 29, 29, '胡萝卜', NULL, '标准装', 500, 6.80, 1, 6.80),
(2007, 1003, 10, 10, '水蜜桃', NULL, '标准装', 500, 18.80, 2, 37.60),
(2008, 1003, 24, 24, '长豆角', NULL, '标准装', 500, 8.60, 1, 8.60),
(2009, 1003, 25, 25, '白萝卜', NULL, '标准装', 500, 6.80, 1, 6.80)
ON DUPLICATE KEY UPDATE
`price` = VALUES(`price`),
`quantity` = VALUES(`quantity`),
`total_price` = VALUES(`total_price`);

-- 4) 评价数据（商品详情评价区可见）
INSERT INTO `comment`
(`id`, `order_id`, `user_id`, `goods_id`, `rating`, `content`, `images`, `create_time`)
VALUES
(3001, 1003, 1, 10, 5, '水蜜桃很新鲜，口感甜，复购。', '[]', '2026-05-16 09:20:00'),
(3002, 1003, 1, 24, 4, '长豆角挺嫩，分量可以。', '[]', '2026-05-16 09:25:00'),
(3003, 1002, 1, 1, 5, '草莓品质不错，酸甜平衡。', '[]', '2026-05-16 12:40:00')
ON DUPLICATE KEY UPDATE
`rating` = VALUES(`rating`),
`content` = VALUES(`content`),
`images` = VALUES(`images`),
`create_time` = VALUES(`create_time`);

SET FOREIGN_KEY_CHECKS = 1;