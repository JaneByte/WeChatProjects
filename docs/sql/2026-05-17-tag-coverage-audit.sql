-- Tag coverage audit for structured recommendation
-- Date: 2026-05-17

-- 1) total goods
SELECT COUNT(1) AS total_goods FROM goods WHERE status = 1;

-- 2) coverage by tag_type
SELECT
  t.tag_type,
  COUNT(DISTINCT gt.goods_id) AS covered_goods,
  ROUND(COUNT(DISTINCT gt.goods_id) / NULLIF((SELECT COUNT(1) FROM goods WHERE status = 1), 0) * 100, 2) AS coverage_pct
FROM tag t
LEFT JOIN goods_tag gt ON gt.tag_id = t.id
WHERE t.tag_type IS NOT NULL AND t.tag_type <> '' AND t.status = 1
GROUP BY t.tag_type
ORDER BY t.tag_type;

-- 3) missing core dimensions (role / scene / diet)
SELECT g.id, g.name
FROM goods g
LEFT JOIN goods_tag gt_role ON gt_role.goods_id = g.id
LEFT JOIN tag t_role ON t_role.id = gt_role.tag_id AND t_role.tag_type = 'role'
WHERE g.status = 1
GROUP BY g.id, g.name
HAVING COUNT(t_role.id) = 0
ORDER BY g.id;

SELECT g.id, g.name
FROM goods g
LEFT JOIN goods_tag gt_scene ON gt_scene.goods_id = g.id
LEFT JOIN tag t_scene ON t_scene.id = gt_scene.tag_id AND t_scene.tag_type = 'scene'
WHERE g.status = 1
GROUP BY g.id, g.name
HAVING COUNT(t_scene.id) = 0
ORDER BY g.id;

SELECT g.id, g.name
FROM goods g
LEFT JOIN goods_tag gt_diet ON gt_diet.goods_id = g.id
LEFT JOIN tag t_diet ON t_diet.id = gt_diet.tag_id AND t_diet.tag_type = 'diet'
WHERE g.status = 1
GROUP BY g.id, g.name
HAVING COUNT(t_diet.id) = 0
ORDER BY g.id;

-- 4) ambiguity review shortlist
SELECT g.id, g.name, g.category_id, g.unit
FROM goods g
WHERE g.status = 1
  AND g.name REGEXP '瓜|豆|果|菌|菜|梨|桃|薯|蒜|椒'
ORDER BY g.id;
