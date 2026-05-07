-- 交易链路联调数据初始化（幂等）
-- 执行顺序：2/3

SET NAMES utf8mb4;

-- 统一联调用测试用户（不影响你已有大量用户）
INSERT INTO `user` (`id`,`openid`,`nickname`,`avatar`,`phone`,`status`)
VALUES (999001,'wxcode_codex_home_seed_999001','联调用户A',NULL,'13800000001',1)
ON DUPLICATE KEY UPDATE
`nickname`=VALUES(`nickname`),`phone`=VALUES(`phone`),`status`=1;

-- 地址
INSERT INTO `address` (`id`,`user_id`,`receiver_name`,`receiver_phone`,`province`,`city`,`district`,`detail`,`is_default`)
VALUES
(99001,999001,'联调收货人','13800000001','湖南省','长沙市','天心区','芙蓉南路 88 号',1),
(99002,999001,'联调备选地址','13800000002','湖南省','长沙市','岳麓区','麓谷大道 66 号',0)
ON DUPLICATE KEY UPDATE
`receiver_name`=VALUES(`receiver_name`),`receiver_phone`=VALUES(`receiver_phone`),`province`=VALUES(`province`),`city`=VALUES(`city`),`district`=VALUES(`district`),`detail`=VALUES(`detail`),`is_default`=VALUES(`is_default`);

-- 购物车（确保商品存在）
INSERT INTO `cart` (`id`,`user_id`,`goods_id`,`merchant_id`,`quantity`,`selected`)
VALUES
(99001,999001,1,1,2,1),
(99002,999001,4,1,1,1),
(99003,999001,13,1,3,1)
ON DUPLICATE KEY UPDATE
`quantity`=VALUES(`quantity`),`selected`=VALUES(`selected`),`merchant_id`=VALUES(`merchant_id`);

-- 订单主表
INSERT INTO `order` (
`id`,`order_no`,`user_id`,`merchant_id`,`total_amount`,`discount_amount`,`actual_amount`,
`receiver_name`,`receiver_phone`,`receiver_address`,`remark`,`coupon_id`,`status`,`pay_channel`,`pay_trade_no`,`pay_status`,`pay_time`,`deliver_time`,`finish_time`,`cancel_time`
)
VALUES
(99001,'FT202605070001',999001,1,69.40,8.00,61.40,'联调收货人','13800000001','湖南省长沙市天心区芙蓉南路88号','联调样例订单',1,3,'mock_wechat','MOCK_TRADE_99001',2,'2026-05-07 10:30:00','2026-05-07 11:00:00','2026-05-07 18:00:00',NULL),
(99002,'FT202605070002',999001,1,28.60,0.00,28.60,'联调收货人','13800000001','湖南省长沙市天心区芙蓉南路88号','待发货样例',NULL,1,'mock_wechat','MOCK_TRADE_99002',2,'2026-05-07 12:00:00',NULL,NULL,NULL)
ON DUPLICATE KEY UPDATE
`total_amount`=VALUES(`total_amount`),`discount_amount`=VALUES(`discount_amount`),`actual_amount`=VALUES(`actual_amount`),`receiver_name`=VALUES(`receiver_name`),`receiver_phone`=VALUES(`receiver_phone`),`receiver_address`=VALUES(`receiver_address`),`status`=VALUES(`status`),`pay_status`=VALUES(`pay_status`),`pay_time`=VALUES(`pay_time`),`deliver_time`=VALUES(`deliver_time`),`finish_time`=VALUES(`finish_time`),`cancel_time`=VALUES(`cancel_time`);

-- 订单明细
INSERT INTO `order_item` (`id`,`order_id`,`goods_id`,`goods_name`,`goods_image`,`price`,`quantity`,`total_price`)
VALUES
(99001,99001,1,'草莓','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg',25.80,1,25.80),
(99002,99001,4,'橙子','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg',8.80,2,17.60),
(99003,99001,13,'红富士苹果','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg',9.80,1,9.80),
(99004,99002,10,'水蜜桃','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/水蜜桃.jpg',18.80,1,18.80),
(99005,99002,5,'丑橘','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg',7.90,1,7.90)
ON DUPLICATE KEY UPDATE
`goods_name`=VALUES(`goods_name`),`goods_image`=VALUES(`goods_image`),`price`=VALUES(`price`),`quantity`=VALUES(`quantity`),`total_price`=VALUES(`total_price`);