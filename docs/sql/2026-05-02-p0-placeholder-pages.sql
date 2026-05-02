SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户券ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `title` varchar(64) NOT NULL COMMENT '优惠券标题',
  `condition_text` varchar(128) NOT NULL COMMENT '使用条件文案',
  `expire_date` date NOT NULL COMMENT '到期日期',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0失效 1可用 2已使用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户优惠券表';

INSERT INTO `user_coupon` (`user_id`, `title`, `condition_text`, `expire_date`, `status`) VALUES
(1, '满50减8', '全场可用', '2026-05-31', 1),
(1, '满99减15', '生鲜专区', '2026-06-15', 1),
(2, '满39减5', '全场可用', '2026-05-20', 1);

DROP TABLE IF EXISTS `service_faq`;
CREATE TABLE `service_faq` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'FAQ ID',
  `question` varchar(128) NOT NULL COMMENT '问题',
  `answer` varchar(512) NOT NULL COMMENT '回答',
  `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='客服常见问题表';

INSERT INTO `service_faq` (`question`, `answer`, `sort`, `status`) VALUES
('配送多久可以送达？', '默认当日或次日送达，具体以下单页为准。', 1, 1),
('商品不新鲜怎么办？', '签收后24小时内可在订单页申请售后。', 2, 1),
('如何联系客服？', '你可以拨打 400-888-1024（9:00-21:00）。', 3, 1);

DROP TABLE IF EXISTS `user_setting`;
CREATE TABLE `user_setting` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '设置ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `notify_order` tinyint(4) NOT NULL DEFAULT 1 COMMENT '订单通知',
  `notify_promo` tinyint(4) NOT NULL DEFAULT 0 COMMENT '活动通知',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户设置表';

INSERT INTO `user_setting` (`user_id`, `notify_order`, `notify_promo`) VALUES
(1, 1, 0),
(2, 1, 1);

DROP TABLE IF EXISTS `trace_record`;
CREATE TABLE `trace_record` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '溯源记录ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `origin_card_id` bigint(20) NOT NULL COMMENT '产地卡片ID',
  `location` varchar(128) NOT NULL COMMENT '产地位置',
  `harvest_date` date NOT NULL COMMENT '采收日期',
  `batch_no` varchar(64) NOT NULL COMMENT '质检批次号',
  `cold_chain_status` varchar(64) NOT NULL COMMENT '冷链状态',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_goods_id` (`goods_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='商品溯源记录表';

INSERT INTO `trace_record` (`goods_id`, `origin_card_id`, `location`, `harvest_date`, `batch_no`, `cold_chain_status`, `status`) VALUES
(3, 2, '云南红河', '2026-04-28', 'FT-TRACE-260428-003', '全程冷链在途', 1),
(13, 1, '山东烟台', '2026-04-27', 'FT-TRACE-260427-013', '冷库待配货', 1),
(5, 3, '海南乐东', '2026-04-29', 'FT-TRACE-260429-005', '冷链已签收', 1);

SET FOREIGN_KEY_CHECKS = 1;
