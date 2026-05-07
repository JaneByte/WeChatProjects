SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `home_notice` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_text` varchar(128) NOT NULL COMMENT '公告文案',
  `link_type` varchar(32) NOT NULL DEFAULT 'none' COMMENT '跳转类型：none/goods/search/category/url/goodsDetail',
  `link_value` varchar(256) DEFAULT NULL COMMENT '跳转值',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `status` tinyint(4) DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页公告表';

CREATE TABLE IF NOT EXISTS `home_nav` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '快捷入口ID',
  `nav_type` varchar(32) NOT NULL COMMENT '入口标识',
  `nav_text` varchar(32) NOT NULL COMMENT '入口文案',
  `icon_text` varchar(8) NOT NULL COMMENT '入口图标文字',
  `link_type` varchar(32) NOT NULL DEFAULT 'goods' COMMENT '跳转类型：goods/search/category/url/goodsDetail',
  `link_value` varchar(256) DEFAULT NULL COMMENT '跳转值',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `status` tinyint(4) DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页快捷入口表';

DELETE FROM `home_notice`;
INSERT INTO `home_notice` (`id`, `notice_text`, `link_type`, `link_value`, `sort`, `status`) VALUES
(1, '今日上新优先发货，最快次日达', 'none', '', 1, 1),
(2, '限时秒杀库存有限，先到先得', 'goods', 'flash', 2, 1);

DELETE FROM `home_nav`;
INSERT INTO `home_nav` (`id`, `nav_type`, `nav_text`, `icon_text`, `link_type`, `link_value`, `sort`, `status`) VALUES
(1, 'seasonal', '时令优选', '时', 'goods', 'seasonal', 1, 1),
(2, 'hot', '热销爆款', '热', 'goods', 'hot', 2, 1),
(3, 'flash', '限时秒杀', '秒', 'goods', 'flash', 3, 1),
(4, 'category', '全部分类', '类', 'category', 'category', 4, 1);

SET FOREIGN_KEY_CHECKS = 1;
