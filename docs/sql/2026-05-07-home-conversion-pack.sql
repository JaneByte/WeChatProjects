-- 场景入口配置化 + 埋点表初始化
-- 建议执行顺序：在 2026-05-07-home-seed-batch-1.sql 后执行

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

DELETE FROM `home_nav` WHERE `id` IN (1,2,3,4);
INSERT INTO `home_nav` (`id`,`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`)
VALUES
(1,'salad','轻食沙拉','轻','search','生菜',1,1),
(2,'quickMeal','快手菜','快','search','番茄',2,1),
(3,'fruitPlate','果盘搭配','果','search','草莓',3,1),
(4,'stockUp','家庭囤货','囤','search','苹果',4,1)
ON DUPLICATE KEY UPDATE
`nav_type`=VALUES(`nav_type`),`nav_text`=VALUES(`nav_text`),`icon_text`=VALUES(`icon_text`),`link_type`=VALUES(`link_type`),`link_value`=VALUES(`link_value`),`sort`=VALUES(`sort`),`status`=VALUES(`status`);
