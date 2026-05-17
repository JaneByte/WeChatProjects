-- Structured tag bootstrap (name-based + category-based)
-- Date: 2026-05-17
-- Scope:
-- 1) Upgrade tag dictionary to support structured dimensions
-- 2) Seed structured tags
-- 3) Auto-label goods by category/name/business fields
-- 4) Keep existing marketing tags untouched

START TRANSACTION;

-- 0) Make tag table structured-compatible (MySQL 8.0 safe, column-by-column check)

-- tag_code
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'tag'
  AND COLUMN_NAME = 'tag_code';
SET @sql_add = IF(@col_exists = 0,
  'ALTER TABLE `tag` ADD COLUMN `tag_code` varchar(64) NULL COMMENT ''结构化标签编码'';',
  'SELECT ''column tag_code already exists'' AS info;'
);
PREPARE stmt FROM @sql_add;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- tag_type
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'tag'
  AND COLUMN_NAME = 'tag_type';
SET @sql_add = IF(@col_exists = 0,
  'ALTER TABLE `tag` ADD COLUMN `tag_type` varchar(32) NULL COMMENT ''结构化标签类型'';',
  'SELECT ''column tag_type already exists'' AS info;'
);
PREPARE stmt FROM @sql_add;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- status
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'tag'
  AND COLUMN_NAME = 'status';
SET @sql_add = IF(@col_exists = 0,
  'ALTER TABLE `tag` ADD COLUMN `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT ''状态 0禁用 1启用'';',
  'SELECT ''column status already exists'' AS info;'
);
PREPARE stmt FROM @sql_add;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- sort
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'tag'
  AND COLUMN_NAME = 'sort';
SET @sql_add = IF(@col_exists = 0,
  'ALTER TABLE `tag` ADD COLUMN `sort` int(11) NOT NULL DEFAULT 0 COMMENT ''排序值'';',
  'SELECT ''column sort already exists'' AS info;'
);
PREPARE stmt FROM @sql_add;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- description
SET @col_exists = 0;
SELECT COUNT(*) INTO @col_exists
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'tag'
  AND COLUMN_NAME = 'description';
SET @sql_add = IF(@col_exists = 0,
  'ALTER TABLE `tag` ADD COLUMN `description` varchar(255) NULL COMMENT ''标签说明'';',
  'SELECT ''column description already exists'' AS info;'
);
PREPARE stmt FROM @sql_add;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- tag_code unique index (idempotent-safe)
SET @idx_exists = (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'tag'
    AND index_name = 'uk_tag_code'
);
SET @sql_idx = IF(@idx_exists = 0,
  'ALTER TABLE `tag` ADD UNIQUE INDEX `uk_tag_code`(`tag_code`);',
  'SELECT ''index uk_tag_code already exists'' AS info;'
);
PREPARE stmt_idx FROM @sql_idx;
EXECUTE stmt_idx;
DEALLOCATE PREPARE stmt_idx;

-- 1) Seed structured tags
-- type convention:
-- role / scene / diet / exclude / cook / portion / nutrition / selling / origin / storage
INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`) VALUES
('角色-水果', 2, 'role_fruit', 'role', 1, 10, '推荐角色：水果'),
('角色-主菜', 2, 'role_main', 'role', 1, 11, '推荐角色：主菜'),
('角色-配菜', 2, 'role_side', 'role', 1, 12, '推荐角色：配菜'),
('角色-基础食材', 2, 'role_base', 'role', 1, 13, '推荐角色：基础食材'),
('角色-蔬菜配料', 2, 'role_veg', 'role', 1, 14, '推荐角色：蔬菜配料'),

('场景-一人食', 2, 'scene_meal_single', 'scene', 1, 20, '适配一人食方案'),
('场景-蔬果搭配', 2, 'scene_combo_mix', 'scene', 1, 21, '适配蔬果搭配方案'),
('场景-沙拉', 2, 'scene_combo_salad', 'scene', 1, 22, '适配沙拉场景'),
('场景-榨汁', 2, 'scene_combo_juice', 'scene', 1, 23, '适配榨汁场景'),
('场景-火锅搭配', 2, 'scene_combo_hotpot', 'scene', 1, 24, '适配火锅搭配场景'),
('场景-便当配菜', 2, 'scene_combo_bento_side', 'scene', 1, 25, '适配便当配菜场景'),

('饮食-轻负担', 2, 'diet_light', 'diet', 1, 30, '轻负担饮食倾向'),
('饮食-高纤', 2, 'diet_high_fiber', 'diet', 1, 31, '高纤饮食倾向'),
('饮食-均衡', 2, 'diet_balanced', 'diet', 1, 32, '均衡日常饮食'),

('忌口-辣', 2, 'exclude_spicy', 'exclude', 1, 40, '忌口维度：辣'),
('忌口-高糖', 2, 'exclude_sweet', 'exclude', 1, 41, '忌口维度：高糖'),
('忌口-生冷', 2, 'exclude_cold_food', 'exclude', 1, 42, '忌口维度：生冷'),

('烹饪-免烹饪', 2, 'cook_no_cook', 'cook', 1, 50, '可直接食用'),
('烹饪-快手烹饪', 2, 'cook_quick_cook', 'cook', 1, 51, '适合快手烹饪'),

('份量-小份', 2, 'portion_small', 'portion', 1, 60, '小规格/小份量'),
('份量-标准份', 2, 'portion_regular', 'portion', 1, 61, '标准规格'),

('营养-维C友好', 2, 'nutrition_vitamin_c', 'nutrition', 1, 70, '维C补充友好'),
('营养-纤维友好', 2, 'nutrition_fiber', 'nutrition', 1, 71, '膳食纤维友好'),
('营养-饱腹友好', 2, 'nutrition_satiety', 'nutrition', 1, 72, '饱腹友好'),

('储存-冷藏', 2, 'storage_cold', 'storage', 1, 80, '建议冷藏保存'),

('销售-热销', 3, 'selling_hot', 'selling', 1, 90, '销量较高'),
('销售-推荐', 3, 'selling_recommend', 'selling', 1, 91, '推荐商品')
ON DUPLICATE KEY UPDATE
  `type` = VALUES(`type`),
  `tag_code` = VALUES(`tag_code`),
  `tag_type` = VALUES(`tag_type`),
  `status` = VALUES(`status`),
  `sort` = VALUES(`sort`),
  `description` = VALUES(`description`);

-- 2) Clear old structured assignments only (do not touch legacy marketing tags)
DELETE gt
FROM `goods_tag` gt
JOIN `tag` t ON t.id = gt.tag_id
WHERE t.tag_type IN ('role', 'scene', 'diet', 'exclude', 'cook', 'portion', 'nutrition', 'selling', 'storage');

-- 3) Auto labeling by category/name/business fields

-- 3.1 role tags (by category)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'role_fruit'
WHERE p.name = '水果';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'role_veg'
WHERE p.name = '蔬菜';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'role_fruit'
WHERE c.name LIKE '%水果%' OR c.name LIKE '%果%';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'role_veg'
WHERE c.name LIKE '%蔬菜%' OR c.name LIKE '%菜%';

-- 3.2 scene tags (by category + name pattern)
-- salad
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'scene_combo_salad'
WHERE (p.name = '蔬菜' OR c.name LIKE '%菜%')
  AND (g.name LIKE '%生菜%' OR g.name LIKE '%沙拉%' OR g.name LIKE '%紫甘蓝%'
       OR g.name LIKE '%芝麻菜%' OR g.name LIKE '%羽衣甘蓝%'
       OR g.name LIKE '%黄瓜%' OR g.name LIKE '%番茄%' OR g.name LIKE '%西红柿%'
       OR g.name LIKE '%樱桃%萝卜%' OR g.name LIKE '%甜椒%');

-- juice
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'scene_combo_juice'
WHERE p.name = '水果'
  OR c.name LIKE '%水果%'
  OR g.name LIKE '%橙%' OR g.name LIKE '%苹果%' OR g.name LIKE '%西瓜%'
  OR g.name LIKE '%梨%' OR g.name LIKE '%葡萄%' OR g.name LIKE '%芒%'
  OR g.name LIKE '%桃%' OR g.name LIKE '%莓%' OR g.name LIKE '%柚%'
  OR g.name LIKE '%柠%' OR g.name LIKE '%百香果%' OR g.name LIKE '%火龙果%'
  OR g.name LIKE '%猕猴桃%' OR g.name LIKE '%奇异果%';

-- hotpot
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_combo_hotpot'
WHERE g.name LIKE '%火锅%'
   OR g.name LIKE '%涮%'
   OR g.name LIKE '%毛肚%'
   OR g.name LIKE '%黄喉%'
   OR g.name LIKE '%鸭血%'
   OR g.name LIKE '%豆皮%'
   OR g.name LIKE '%腐竹%'
   OR g.name LIKE '%宽粉%';

-- bento_side
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_combo_bento_side'
WHERE g.name LIKE '%小菜%'
   OR g.name LIKE '%泡菜%'
   OR g.name LIKE '%腌%'
   OR g.name LIKE '%凉拌%';

-- scene_meal_single (one-person meal base)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_meal_single'
WHERE c.name LIKE '%主食%'
   OR c.name LIKE '%面%'
   OR c.name LIKE '%米%'
   OR c.name LIKE '%粉%'
   OR g.name LIKE '%一人%'
   OR g.name LIKE '%单人%'
   OR g.name LIKE '%小份%';

-- scene_combo_mix (generic fruit/veg combination)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'scene_combo_mix'
WHERE p.name IN ('水果', '蔬菜')
   OR c.name LIKE '%水果%' OR c.name LIKE '%蔬菜%';

-- 3.3 diet tags (by name + category pattern)
-- diet_light (low-calorie tendency)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'diet_light'
WHERE (c.name LIKE '%菜%' OR c.name LIKE '%蔬%')
  AND (g.name LIKE '%黄瓜%' OR g.name LIKE '%番茄%' OR g.name LIKE '%生菜%'
       OR g.name LIKE '%西兰花%' OR g.name LIKE '%芹菜%' OR g.name LIKE '%冬瓜%'
       OR g.name LIKE '%苦瓜%');

-- diet_high_fiber
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'diet_high_fiber'
WHERE g.name LIKE '%粗粮%'
   OR g.name LIKE '%全麦%'
   OR g.name LIKE '%燕麦%'
   OR g.name LIKE '%红薯%'
   OR g.name LIKE '%紫薯%'
   OR g.name LIKE '%玉米%'
   OR g.name LIKE '%芹菜%'
   OR g.name LIKE '%西兰花%'
   OR g.name LIKE '%苹果%'
   OR g.name LIKE '%梨%'
   OR g.name LIKE '%香蕉%';

-- 3.4 cook tags
-- cook_no_cook (ready to eat)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'cook_no_cook'
WHERE p.name = '水果'
   OR c.name LIKE '%水果%'
   OR g.name LIKE '%沙拉%'
   OR g.name LIKE '%即食%'
   OR g.name LIKE '%凉拌%';

-- cook_quick_cook
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'cook_quick_cook'
WHERE c.name LIKE '%菜%'
   OR c.name LIKE '%蔬%'
   OR g.name LIKE '%快%';

-- 3.5 storage tag
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'storage_cold'
WHERE g.name LIKE '%冷藏%'
   OR g.name LIKE '%冷鲜%'
   OR g.name LIKE '%保鲜%'
   OR g.keywords LIKE '%冷藏%'
   OR g.keywords LIKE '%冷鲜%';

-- 3.6 portion tags (default portion_regular for most, small for explicit)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'portion_regular'
WHERE g.id NOT IN (
  SELECT gt.goods_id FROM `goods_tag` gt
  JOIN `tag` t2 ON t2.id = gt.tag_id
  WHERE t2.tag_type = 'portion'
);

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'portion_small'
WHERE g.name LIKE '%小份%'
   OR g.name LIKE '%单人%'
   OR g.name LIKE '%mini%'
   OR g.name LIKE '%一人%';

-- 3.7 nutrition tags
-- nutrition_vitamin_c
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'nutrition_vitamin_c'
WHERE g.name LIKE '%橙%' OR g.name LIKE '%柠檬%' OR g.name LIKE '%柚子%'
   OR g.name LIKE '%猕猴桃%' OR g.name LIKE '%奇异果%' OR g.name LIKE '%草莓%'
   OR g.name LIKE '%番茄%' OR g.name LIKE '%西红柿%' OR g.name LIKE '%青椒%'
   OR g.name LIKE '%西兰花%';

-- nutrition_fiber
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'nutrition_fiber'
WHERE g.name LIKE '%粗粮%' OR g.name LIKE '%燕麦%' OR g.name LIKE '%全麦%'
   OR g.name LIKE '%红薯%' OR g.name LIKE '%紫薯%' OR g.name LIKE '%玉米%'
   OR g.name LIKE '%苹果%' OR g.name LIKE '%梨%' OR g.name LIKE '%香蕉%'
   OR g.name LIKE '%西兰花%' OR g.name LIKE '%芹菜%';

-- 3.8 selling tags (by sales_volume if exists, else default)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'selling_hot'
WHERE g.sales_volume > 50;

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'selling_recommend'
WHERE g.sales_volume <= 50 OR g.sales_volume IS NULL;

COMMIT;

-- Report
SELECT '=== Structured tag bootstrap completed ===' AS result;
SELECT t.tag_type AS `标签类型`, COUNT(DISTINCT gt.goods_id) AS `已打标商品数`
FROM `tag` t
LEFT JOIN `goods_tag` gt ON gt.tag_id = t.id
WHERE t.tag_type IN ('role', 'scene', 'diet', 'exclude', 'cook', 'portion', 'nutrition', 'selling', 'storage')
GROUP BY t.tag_type
ORDER BY t.tag_type;