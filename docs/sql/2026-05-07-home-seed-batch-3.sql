-- 营销与溯源联调数据初始化（幂等）
-- 执行顺序：3/3

SET NAMES utf8mb4;

-- 你当前数据库基线没有 coupon 表，本批次不写 coupon 模板，直接写 user_coupon 联调数据

-- 用户券（联调用户）
INSERT INTO `user_coupon` (`id`,`user_id`,`title`,`condition_text`,`threshold_amount`,`discount_amount`,`expire_date`,`status`)
VALUES
(99001,999001,'满50减8','全场可用',50.00,8.00,'2026-12-31',1),
(99002,999001,'满99减15','生鲜专区',99.00,15.00,'2026-12-31',1),
(99003,999001,'满39减5','新人专享',39.00,5.00,'2026-12-31',1)
ON DUPLICATE KEY UPDATE
`title`=VALUES(`title`),`condition_text`=VALUES(`condition_text`),`threshold_amount`=VALUES(`threshold_amount`),`discount_amount`=VALUES(`discount_amount`),`expire_date`=VALUES(`expire_date`),`status`=VALUES(`status`);

-- 溯源记录补充（首页与详情联调）
INSERT INTO `trace_record` (`id`,`goods_id`,`origin_card_id`,`location`,`harvest_date`,`batch_no`,`cold_chain_status`,`status`)
VALUES
(99001,1,2,'山东烟台','2026-05-06','FT-TRACE-260506-001','全程冷链在途',1),
(99002,4,1,'江西赣州','2026-05-05','FT-TRACE-260505-004','冷库待配货',1),
(99003,13,1,'陕西延安','2026-05-04','FT-TRACE-260504-013','冷链已签收',1)
ON DUPLICATE KEY UPDATE
`goods_id`=VALUES(`goods_id`),`origin_card_id`=VALUES(`origin_card_id`),`location`=VALUES(`location`),`harvest_date`=VALUES(`harvest_date`),`batch_no`=VALUES(`batch_no`),`cold_chain_status`=VALUES(`cold_chain_status`),`status`=VALUES(`status`);
