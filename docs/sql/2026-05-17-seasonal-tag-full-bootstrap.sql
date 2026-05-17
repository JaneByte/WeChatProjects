-- 2026-05-17
-- 当季精选标签体系一次性收口脚本（幂等）
-- 目标：
-- 1) 补齐 produce 标签（水果/蔬菜）
-- 2) 补齐 season 标签（春夏秋冬）
-- 3) 按 category + 商品名称自动打标
-- 4) 输出覆盖率审计

START TRANSACTION;

-- A. 确保结构化标签存在
INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '品类-水果', 2, 'produce:fruits', 'produce', 1, 100, '当季筛选：水果'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `tag_code` = 'produce:fruits');

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '品类-蔬菜', 2, 'produce:vegetables', 'produce', 1, 101, '当季筛选：蔬菜'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `tag_code` = 'produce:vegetables');

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '季节-春', 2, 'season:spring', 'season', 1, 110, '当季筛选：春季'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `tag_code` = 'season:spring');

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '季节-夏', 2, 'season:summer', 'season', 1, 111, '当季筛选：夏季'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `tag_code` = 'season:summer');

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '季节-秋', 2, 'season:autumn', 'season', 1, 112, '当季筛选：秋季'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `tag_code` = 'season:autumn');

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '季节-冬', 2, 'season:winter', 'season', 1, 113, '当季筛选：冬季'
FROM DUAL
WHERE NOT EXISTS (SELECT 1 FROM `tag` WHERE `tag_code` = 'season:winter');

-- B. 按分类补齐 produce 标签
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'produce:fruits'
WHERE g.status = 1
  AND (
    c.id = 2 OR c.parent_id = 2
  );

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'produce:vegetables'
WHERE g.status = 1
  AND (
    c.id = 1 OR c.parent_id = 1
  );

-- C. 按商品名称补齐 season 标签（可多季）
-- 春
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'season:spring'
WHERE g.status = 1
  AND (
    g.name LIKE '%草莓%' OR g.name LIKE '%香椿%' OR g.name LIKE '%春笋%' OR g.name LIKE '%豌豆%' OR
    g.name LIKE '%蚕豆%' OR g.name LIKE '%菠菜%' OR g.name LIKE '%芦笋%' OR g.name LIKE '%枇杷%'
  );

-- 夏
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'season:summer'
WHERE g.status = 1
  AND (
    g.name LIKE '%西瓜%' OR g.name LIKE '%哈密瓜%' OR g.name LIKE '%香瓜%' OR g.name LIKE '%葡萄%' OR
    g.name LIKE '%桃%' OR g.name LIKE '%李%' OR g.name LIKE '%黄瓜%' OR g.name LIKE '%番茄%' OR
    g.name LIKE '%苦瓜%' OR g.name LIKE '%丝瓜%' OR g.name LIKE '%空心菜%'
  );

-- 秋
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'season:autumn'
WHERE g.status = 1
  AND (
    g.name LIKE '%苹果%' OR g.name LIKE '%梨%' OR g.name LIKE '%柚%' OR g.name LIKE '%橙%' OR
    g.name LIKE '%石榴%' OR g.name LIKE '%南瓜%' OR g.name LIKE '%莲藕%' OR g.name LIKE '%山药%' OR
    g.name LIKE '%芋头%'
  );

-- 冬
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'season:winter'
WHERE g.status = 1
  AND (
    g.name LIKE '%白菜%' OR g.name LIKE '%萝卜%' OR g.name LIKE '%胡萝卜%' OR g.name LIKE '%甘蓝%' OR
    g.name LIKE '%花菜%' OR g.name LIKE '%西兰花%' OR g.name LIKE '%柑%' OR g.name LIKE '%橙%' OR
    g.name LIKE '%柚%' OR g.name LIKE '%菌%' OR g.name LIKE '%香菇%' OR g.name LIKE '%平菇%'
  );

-- D. 兜底：仍未季节打标的在售商品，按大类给“当前季节基础标签”
-- 统一给一档基础季节：春（可后续人工校正）
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'season:spring'
WHERE g.status = 1
  AND NOT EXISTS (
    SELECT 1
    FROM `goods_tag` gt
    JOIN `tag` st ON st.id = gt.tag_id
    WHERE gt.goods_id = g.id
      AND st.tag_type = 'season'
  );

-- E. 覆盖率审计（查看打标结果）
SELECT 
    'produce:fruits' AS tag_code,
    COUNT(DISTINCT gt.goods_id) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_code = 'produce:fruits'

UNION ALL

SELECT 
    'produce:vegetables' AS tag_code,
    COUNT(DISTINCT gt.goods_id) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_code = 'produce:vegetables'

UNION ALL

SELECT 
    'season:spring' AS tag_code,
    COUNT(DISTINCT gt.goods_id) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_code = 'season:spring'

UNION ALL

SELECT 
    'season:summer' AS tag_code,
    COUNT(DISTINCT gt.goods_id) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_code = 'season:summer'

UNION ALL

SELECT 
    'season:autumn' AS tag_code,
    COUNT(DISTINCT gt.goods_id) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_code = 'season:autumn'

UNION ALL

SELECT 
    'season:winter' AS tag_code,
    COUNT(DISTINCT gt.goods_id) AS goods_count
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_code = 'season:winter'

UNION ALL

SELECT 
    '总在售商品数' AS tag_code,
    COUNT(*) AS goods_count
FROM `goods`
WHERE `status` = 1;

COMMIT;