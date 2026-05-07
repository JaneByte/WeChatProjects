-- 首页与基础数据初始化（幂等）
-- 执行顺序：1/3

SET NAMES utf8mb4;

-- 1) 商家基础数据
INSERT INTO `merchant` (`id`,`username`,`password`,`shop_name`,`contact_name`,`phone`,`address`,`description`,`status`)
VALUES (1,'admin','123456','鲜果时光旗舰店','张三','075157183889','湖南省长沙市天心区文源街道','首页联调基线商家',1)
ON DUPLICATE KEY UPDATE
`shop_name`=VALUES(`shop_name`),`contact_name`=VALUES(`contact_name`),`phone`=VALUES(`phone`),`address`=VALUES(`address`),`status`=1;

-- 2) 首页轮播（原表缺数据）
INSERT INTO `banner` (`id`,`title`,`image`,`link_type`,`link_value`,`sort`,`status`)
VALUES
(1,'春季鲜果专场','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/home/banner-01.jpg',2,'category',1,1),
(2,'爆款草莓直降','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/home/banner-02.jpg',1,'1',2,1),
(3,'新人满减活动','cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/home/banner-03.jpg',0,'',3,1)
ON DUPLICATE KEY UPDATE
`title`=VALUES(`title`),`image`=VALUES(`image`),`link_type`=VALUES(`link_type`),`link_value`=VALUES(`link_value`),`sort`=VALUES(`sort`),`status`=VALUES(`status`);

-- 3) 首页公告
INSERT INTO `home_notice` (`id`,`notice_text`,`link_type`,`link_value`,`sort`,`status`)
VALUES
(1,'今日上新优先发货，最快次日达','none','',1,1),
(2,'限时秒杀库存有限，先到先得','goods','flash',2,1)
ON DUPLICATE KEY UPDATE
`notice_text`=VALUES(`notice_text`),`link_type`=VALUES(`link_type`),`link_value`=VALUES(`link_value`),`sort`=VALUES(`sort`),`status`=VALUES(`status`);

-- 4) 首页快捷入口
INSERT INTO `home_nav` (`id`,`nav_type`,`nav_text`,`icon_text`,`link_type`,`link_value`,`sort`,`status`)
VALUES
(1,'seasonal','时令优选','时','goods','seasonal',1,1),
(2,'hot','热销爆款','热','goods','hot',2,1),
(3,'flash','限时秒杀','秒','goods','flash',3,1),
(4,'category','全部分类','类','category','category',4,1)
ON DUPLICATE KEY UPDATE
`nav_type`=VALUES(`nav_type`),`nav_text`=VALUES(`nav_text`),`icon_text`=VALUES(`icon_text`),`link_type`=VALUES(`link_type`),`link_value`=VALUES(`link_value`),`sort`=VALUES(`sort`),`status`=VALUES(`status`);

-- 5) 首页溯源卡
INSERT INTO `home_origin_card` (`id`,`origin_name`,`card_desc`,`card_meta`,`status`,`sort`)
VALUES
(1,'山东寿光','当日采收，次日发货','蔬菜基地直采',1,1),
(2,'云南高原','高海拔慢生长，更香甜','水果产区直供',1,2),
(3,'海南乐东','热带日照足，口感更稳定','产地溯源可查',1,3)
ON DUPLICATE KEY UPDATE
`origin_name`=VALUES(`origin_name`),`card_desc`=VALUES(`card_desc`),`card_meta`=VALUES(`card_meta`),`status`=VALUES(`status`),`sort`=VALUES(`sort`);

-- 6) 首页主推与秒杀基线（修复过期秒杀）
UPDATE `goods`
SET `is_recommend`=1, `home_sort`=1, `show_in_home`=1, `status`=1
WHERE `id`=13;

UPDATE `goods`
SET
  `is_flash`=1,
  `flash_price`=IFNULL(`flash_price`, ROUND(`price` * 0.90, 2)),
  `flash_start_time`='2026-05-07 00:00:00',
  `flash_end_time`='2026-12-31 23:59:59',
  `flash_stock`=CASE WHEN `flash_stock` IS NULL OR `flash_stock`<=0 THEN 50 ELSE `flash_stock` END,
  `show_in_home`=1,
  `status`=1
WHERE `id` IN (1,4,10,13);