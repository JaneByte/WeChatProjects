-- 场景标签回填（小份量 / 搭配）
-- 适用：MySQL 5.7+
-- 执行前请先备份数据库

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 1) 确保存在场景标签
INSERT INTO `tag` (`id`, `tag_name`, `sort`)
SELECT 102, '小份量', 2
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 102 OR `tag_name` = '小份量');

INSERT INTO `tag` (`id`, `tag_name`, `sort`)
SELECT 103, '搭配', 3
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `id` = 103 OR `tag_name` = '搭配');

-- 2) 回填小份量标签（按关键词/名称）
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_name = '小份量'
LEFT JOIN `goods_tag` gt ON gt.goods_id = g.id AND gt.tag_id = t.id
WHERE gt.goods_id IS NULL
  AND g.status = 1
  AND (
    g.name LIKE '%小份%'
    OR g.name LIKE '%拼盘%'
    OR g.name LIKE '%果切%'
    OR g.name LIKE '%净菜%'
    OR g.name LIKE '%组合%'
    OR g.keywords LIKE '%小份%'
    OR g.keywords LIKE '%拼盘%'
    OR g.keywords LIKE '%果切%'
    OR g.keywords LIKE '%净菜%'
    OR g.keywords LIKE '%一人食%'
  );

-- 3) 回填搭配标签（按关键词/名称）
INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_name = '搭配'
LEFT JOIN `goods_tag` gt ON gt.goods_id = g.id AND gt.tag_id = t.id
WHERE gt.goods_id IS NULL
  AND g.status = 1
  AND (
    g.name LIKE '%搭配%'
    OR g.name LIKE '%组合%'
    OR g.name LIKE '%套餐%'
    OR g.name LIKE '%两蔬%'
    OR g.name LIKE '%一果%'
    OR g.keywords LIKE '%搭配%'
    OR g.keywords LIKE '%组合%'
    OR g.keywords LIKE '%套餐%'
    OR g.keywords LIKE '%两蔬%'
    OR g.keywords LIKE '%一果%'
    OR g.keywords LIKE '%随机%'
  );

SET FOREIGN_KEY_CHECKS = 1;

