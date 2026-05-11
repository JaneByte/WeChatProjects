-- 首页科普内容与轮播跳转初始化
-- 执行顺序：在 home-seed-batch-1 之后执行

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS `knowledge_article` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `title` varchar(128) NOT NULL COMMENT '标题',
  `summary` varchar(255) DEFAULT NULL COMMENT '摘要',
  `tags` varchar(255) DEFAULT NULL COMMENT '标签，|分隔',
  `pick_guide` text COMMENT '选购指南，|分隔',
  `nutrition` text COMMENT '营养重点，|分隔',
  `pairing` text COMMENT '搭配建议，|分隔',
  `cautions` text COMMENT '注意事项，|分隔',
  `content` text COMMENT '正文',
  `search_keyword` varchar(64) DEFAULT NULL COMMENT '相关推荐搜索词',
  `status` tinyint(4) DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `sort` int(11) DEFAULT 0 COMMENT '排序',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`),
  KEY `idx_status_sort` (`status`,`sort`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='首页科普文章';

INSERT INTO `knowledge_article`
(`id`,`title`,`summary`,`tags`,`pick_guide`,`nutrition`,`pairing`,`cautions`,`content`,`search_keyword`,`status`,`sort`)
VALUES
(1,'草莓怎么挑：甜度、果蒂、硬度三步法','学会三步挑出香甜草莓，减少踩坑。','当季|选购|草莓','看果蒂是否鲜绿紧贴|看果面是否均匀有光泽|轻捏果身有弹性不发软','富含维生素C与花青素|建议现买现吃风味最佳','草莓+酸奶适合作早餐|草莓+燕麦适合轻食','避免长时间浸泡|清洗后尽快食用','草莓属于易损鲜果，运输与存储温度对口感影响较大。购买时优先选择果蒂鲜绿、果面完整且无明显压痕的果实。','草莓',1,1),
(2,'当季维C补给：橙子、柠檬、番茄怎么吃更好','不同维C食材的口感和搭配建议一文看懂。','营养|维C|搭配','橙子选手感沉的多汁款|柠檬选表皮细腻香气足的|番茄优先自然成熟','橙子补水与维C兼顾|柠檬适合调味提鲜|番茄兼顾维C与番茄红素','橙子+坚果适合加餐|柠檬+气泡水适合夏季|番茄+鸡蛋是经典家常搭配','胃部敏感人群避免空腹大量摄入酸性水果','维C并非越多越好，关键在于稳定摄入和合理搭配。建议在一日三餐中分散摄入，提高利用效率。','橙子',1,2),
(3,'一周轻食搭配：高纤蔬果组合清单','给你可执行的一周蔬果轻搭配思路。','轻食|高纤|搭配','优先选择颜色丰富蔬果|同类食材轮换避免单一|根据饱腹感调整份量','深色果蔬通常抗氧化成分更丰富|高纤组合更利于饱腹感管理','生菜+玉米+番茄适合午餐沙拉|苹果+酸奶适合作下午加餐','轻食不是低热量极端节食|注意蛋白质和主食搭配','轻食核心是结构优化而非一味减少。建议按蔬菜、优质蛋白、主食的比例搭配，并结合个人活动量调整。','生菜',1,3)
ON DUPLICATE KEY UPDATE
`title`=VALUES(`title`),`summary`=VALUES(`summary`),`tags`=VALUES(`tags`),`pick_guide`=VALUES(`pick_guide`),`nutrition`=VALUES(`nutrition`),`pairing`=VALUES(`pairing`),`cautions`=VALUES(`cautions`),`content`=VALUES(`content`),`search_keyword`=VALUES(`search_keyword`),`status`=VALUES(`status`),`sort`=VALUES(`sort`);

-- 将首页三张轮播切换为科普入口
UPDATE `banner` SET `title`='草莓选购指南', `link_type`=4, `link_value`='1', `sort`=1, `status`=1 WHERE `id`=1;
UPDATE `banner` SET `title`='当季维C补给', `link_type`=4, `link_value`='2', `sort`=2, `status`=1 WHERE `id`=2;
UPDATE `banner` SET `title`='一周轻食搭配', `link_type`=4, `link_value`='3', `sort`=3, `status`=1 WHERE `id`=3;
