SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `track_event_log` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) DEFAULT 0 COMMENT '用户ID（未登录记0）',
  `event_name` varchar(64) NOT NULL COMMENT '事件名',
  `payload` text COMMENT '事件参数',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_event_name` (`event_name`),
  KEY `idx_create_time` (`create_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='前端埋点事件日志';
