SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `order`
  MODIFY COLUMN `status` tinyint(4) NOT NULL COMMENT '状态 0待付款 1待发货 2待收货 3已完成 4已取消 5已退款 6退款中',
  ADD COLUMN `coupon_id` bigint(20) NULL DEFAULT NULL COMMENT '使用优惠券ID' AFTER `remark`;

ALTER TABLE `user_coupon`
  ADD COLUMN `threshold_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '使用门槛金额' AFTER `condition_text`,
  ADD COLUMN `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额' AFTER `threshold_amount`;

UPDATE `user_coupon`
SET `threshold_amount` = CASE
    WHEN `title` LIKE '%满99%' THEN 99.00
    WHEN `title` LIKE '%满50%' THEN 50.00
    WHEN `title` LIKE '%满39%' THEN 39.00
    ELSE 0.00
  END,
  `discount_amount` = CASE
    WHEN `title` LIKE '%减15%' THEN 15.00
    WHEN `title` LIKE '%减8%' THEN 8.00
    WHEN `title` LIKE '%减5%' THEN 5.00
    ELSE 0.00
  END;

SET FOREIGN_KEY_CHECKS = 1;
