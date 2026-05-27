-- 为 user_coupon 补充 coupon_id，并建立到 coupon.id 的关联
-- 执行前请确认当前库为 freshtime

ALTER TABLE `user_coupon`
ADD COLUMN `coupon_id` bigint(20) NULL COMMENT '来源优惠券模板ID' AFTER `id`;

UPDATE `user_coupon` uc
LEFT JOIN `coupon` c
  ON c.`name` = uc.`title`
 AND IFNULL(c.`description`, '') = IFNULL(uc.`condition_text`, '')
 AND c.`threshold_amount` = uc.`threshold_amount`
 AND c.`discount_amount` = uc.`discount_amount`
SET uc.`coupon_id` = c.`id`
WHERE uc.`coupon_id` IS NULL;

ALTER TABLE `user_coupon`
ADD INDEX `idx_user_coupon_coupon_id`(`coupon_id`) USING BTREE;

ALTER TABLE `user_coupon`
ADD CONSTRAINT `fk_user_coupon_coupon`
FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`)
ON DELETE RESTRICT
ON UPDATE RESTRICT;
