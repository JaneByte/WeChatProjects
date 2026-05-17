-- 2026-05-17
-- 当季标签健康检查（只读）

-- 1) 在售商品总量
SELECT COUNT(*) AS on_sale_goods_total
FROM `goods`
WHERE `status` = 1;

-- 2) 缺 produce 标签的在售商品
SELECT g.id, g.name, c.name AS category_name
FROM `goods` g
LEFT JOIN `category` c ON c.id = g.category_id
WHERE g.status = 1
  AND NOT EXISTS (
    SELECT 1
    FROM `goods_tag` gt
    JOIN `tag` t ON t.id = gt.tag_id
    WHERE gt.goods_id = g.id
      AND t.status = 1
      AND t.tag_type = 'produce'
  )
ORDER BY g.id ASC;

-- 3) 缺 season 标签的在售商品
SELECT g.id, g.name, c.name AS category_name
FROM `goods` g
LEFT JOIN `category` c ON c.id = g.category_id
WHERE g.status = 1
  AND NOT EXISTS (
    SELECT 1
    FROM `goods_tag` gt
    JOIN `tag` t ON t.id = gt.tag_id
    WHERE gt.goods_id = g.id
      AND t.status = 1
      AND t.tag_type = 'season'
  )
ORDER BY g.id ASC;

-- 4) 冲突：同一商品同时打了 fruits + vegetables
SELECT
  g.id,
  g.name,
  SUM(CASE WHEN t.tag_code = 'produce:fruits' THEN 1 ELSE 0 END) AS fruits_tag_count,
  SUM(CASE WHEN t.tag_code = 'produce:vegetables' THEN 1 ELSE 0 END) AS vegetables_tag_count
FROM `goods` g
JOIN `goods_tag` gt ON gt.goods_id = g.id
JOIN `tag` t ON t.id = gt.tag_id
WHERE g.status = 1
  AND t.status = 1
  AND t.tag_code IN ('produce:fruits', 'produce:vegetables')
GROUP BY g.id, g.name
HAVING fruits_tag_count > 0 AND vegetables_tag_count > 0
ORDER BY g.id ASC;

-- 5) 覆盖率汇总
SELECT
  (SELECT COUNT(*) FROM `goods` g WHERE g.status = 1) AS total_on_sale,
  (SELECT COUNT(DISTINCT g.id)
   FROM `goods` g
   JOIN `goods_tag` gt ON gt.goods_id = g.id
   JOIN `tag` t ON t.id = gt.tag_id
   WHERE g.status = 1 AND t.status = 1 AND t.tag_type = 'produce') AS produce_covered,
  (SELECT COUNT(DISTINCT g.id)
   FROM `goods` g
   JOIN `goods_tag` gt ON gt.goods_id = g.id
   JOIN `tag` t ON t.id = gt.tag_id
   WHERE g.status = 1 AND t.status = 1 AND t.tag_type = 'season') AS season_covered;
