SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

ALTER TABLE `order`
  ADD COLUMN `pay_channel` varchar(32) NULL DEFAULT NULL COMMENT '支付渠道（mock_wechat）' AFTER `status`,
  ADD COLUMN `pay_trade_no` varchar(64) NULL DEFAULT NULL COMMENT '模拟支付交易号' AFTER `pay_channel`,
  ADD COLUMN `pay_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '支付状态 0未发起 1待确认 2已支付' AFTER `pay_trade_no`;

UPDATE `order`
SET `pay_status` = CASE WHEN `status` IN (1, 2, 3) THEN 2 ELSE 0 END,
    `pay_channel` = CASE WHEN `status` IN (1, 2, 3) THEN 'mock_wechat' ELSE `pay_channel` END,
    `pay_trade_no` = CASE WHEN `status` IN (1, 2, 3) AND (`pay_trade_no` IS NULL OR `pay_trade_no` = '')
      THEN CONCAT('MOCK', UNIX_TIMESTAMP(`create_time`), `id`)
      ELSE `pay_trade_no` END;

SET FOREIGN_KEY_CHECKS = 1;
