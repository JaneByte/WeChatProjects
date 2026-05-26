-- 商品关键词补全
-- 作用：
-- 1. 为商品 keywords 补充一级分类词（如：蔬菜、水果）
-- 2. 为商品 keywords 补充二级分类词（如：叶菜类、根茎类、菌菇类）
-- 3. 便于管理端 / 小程序端搜索“蔬菜”“水果”“叶菜”“根茎”等词时命中更完整

UPDATE `goods` g
LEFT JOIN `category` c ON c.`id` = g.`category_id`
LEFT JOIN `category` p ON p.`id` = c.`parent_id`
SET g.`keywords` = TRIM(BOTH ',' FROM CONCAT_WS(',',
  NULLIF(g.`keywords`, ''),
  CASE
    WHEN p.`name` IS NOT NULL AND p.`name` <> '' AND g.`keywords` NOT LIKE CONCAT('%', p.`name`, '%') THEN p.`name`
    ELSE NULL
  END,
  CASE
    WHEN c.`name` IS NOT NULL AND c.`name` <> '' AND g.`keywords` NOT LIKE CONCAT('%', c.`name`, '%') THEN c.`name`
    ELSE NULL
  END,
  CASE
    WHEN p.`name` = '蔬菜' AND g.`keywords` NOT LIKE '%蔬菜%' THEN '蔬菜'
    WHEN p.`name` = '水果' AND g.`keywords` NOT LIKE '%水果%' THEN '水果'
    ELSE NULL
  END,
  CASE
    WHEN c.`name` = '叶菜类' AND g.`keywords` NOT LIKE '%叶菜%' THEN '叶菜'
    WHEN c.`name` = '根茎类' AND g.`keywords` NOT LIKE '%根茎%' THEN '根茎'
    WHEN c.`name` = '茄果类' AND g.`keywords` NOT LIKE '%茄果%' THEN '茄果'
    WHEN c.`name` = '菌菇类' AND g.`keywords` NOT LIKE '%菌菇%' THEN '菌菇'
    WHEN c.`name` = '瓜类' AND g.`keywords` NOT LIKE '%瓜类%' THEN '瓜类'
    WHEN c.`name` = '豆类' AND g.`keywords` NOT LIKE '%豆类%' THEN '豆类'
    WHEN c.`name` = '浆果类' AND g.`keywords` NOT LIKE '%浆果%' THEN '浆果'
    WHEN c.`name` = '柑橘类' AND g.`keywords` NOT LIKE '%柑橘%' THEN '柑橘'
    WHEN c.`name` = '核果类' AND g.`keywords` NOT LIKE '%核果%' THEN '核果'
    WHEN c.`name` = '仁果类' AND g.`keywords` NOT LIKE '%仁果%' THEN '仁果'
    ELSE NULL
  END
))
WHERE g.`status` = 1;

-- 可选检查：
-- SELECT g.id, g.name, g.keywords, c.name AS child_category, p.name AS parent_category
-- FROM goods g
-- LEFT JOIN category c ON c.id = g.category_id
-- LEFT JOIN category p ON p.id = c.parent_id
-- WHERE g.status = 1
-- ORDER BY g.id;
