-- Structured tag bootstrap (name-based + category-based)
-- Date: 2026-05-17
-- Scope:
-- 1) Upgrade tag dictionary to support structured dimensions
-- 2) Seed structured tags
-- 3) Auto-label goods by category/name/business fields
-- 4) Keep existing marketing tags untouched

START TRANSACTION;

-- 0) Make tag table structured-compatible (backward compatible)
ALTER TABLE `tag`
  ADD COLUMN IF NOT EXISTS `tag_code` varchar(64) NULL COMMENT '结构化标签编码',
  ADD COLUMN IF NOT EXISTS `tag_type` varchar(32) NULL COMMENT '结构化标签类型',
  ADD COLUMN IF NOT EXISTS `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  ADD COLUMN IF NOT EXISTS `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序值',
  ADD COLUMN IF NOT EXISTS `description` varchar(255) NULL COMMENT '标签说明';

-- tag_code unique index (idempotent-safe by name check)
SET @idx_exists = (
  SELECT COUNT(1)
  FROM information_schema.statistics
  WHERE table_schema = DATABASE()
    AND table_name = 'tag'
    AND index_name = 'uk_tag_code'
);
SET @sql_idx = IF(@idx_exists = 0,
  'ALTER TABLE `tag` ADD UNIQUE INDEX `uk_tag_code`(`tag_code`);',
  'SELECT 1;'
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

-- 3.1 role tags
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
JOIN `tag` t ON t.tag_code = 'role_side'
WHERE p.name = '蔬菜';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'role_main'
WHERE p.name = '蔬菜'
  AND c.name IN ('菌菇类', '根茎类', '豆类', '茄果类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'role_base'
WHERE p.name = '蔬菜'
  AND c.name IN ('叶菜类', '瓜类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'role_veg'
WHERE p.name = '蔬菜';

-- 3.2 scene tags
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id FROM `goods` g
JOIN `tag` t ON t.tag_code = 'scene_meal_single'
WHERE g.status = 1;

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id FROM `goods` g
JOIN `tag` t ON t.tag_code = 'scene_combo_mix'
WHERE g.status = 1;

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_combo_salad'
WHERE c.name IN ('叶菜类', '茄果类', '瓜类', '浆果类', '仁果类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_combo_juice'
WHERE c.name IN ('柑橘类', '浆果类', '仁果类', '瓜类', '根茎类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_combo_hotpot'
WHERE c.name IN ('叶菜类', '菌菇类', '豆类', '根茎类', '花菜类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'scene_combo_bento_side'
WHERE c.name IN ('花菜类', '豆类', '叶菜类', '茄果类', '根茎类');

-- 3.3 diet tags
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'diet_high_fiber'
WHERE c.name IN ('叶菜类', '豆类', '菌菇类', '花菜类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'diet_light'
WHERE c.name IN ('叶菜类', '瓜类', '茄果类', '浆果类', '柑橘类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'diet_balanced'
WHERE g.status = 1;

-- 3.4 exclude tags (name-based conservative heuristics)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'exclude_sweet'
WHERE g.name REGEXP '葡萄|香蕉|荔枝|龙眼|榴莲|哈密瓜|西瓜|蜜|枣|菠萝|芒果';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'exclude_cold_food'
WHERE g.name REGEXP '西瓜|黄瓜|苦瓜|冬瓜|雪莲果|梨';

-- note: 农产品几乎不含天然“辣”命名，留给人工补标

-- 3.5 cook tags
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'cook_no_cook'
WHERE p.name = '水果';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `category` p ON p.id = c.parent_id
JOIN `tag` t ON t.tag_code = 'cook_quick_cook'
WHERE p.name = '蔬菜';

-- 3.6 portion tags (fallback by unit; SKU级更准确，后续建议迁移到 sku_tag)
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'portion_small'
WHERE g.unit IN ('盒', '个', '份')
   OR g.name REGEXP '小';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'portion_regular'
WHERE g.id NOT IN (
  SELECT gt.goods_id
  FROM `goods_tag` gt
  JOIN `tag` tt ON tt.id = gt.tag_id AND tt.tag_code = 'portion_small'
);

-- 3.7 nutrition tags
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'nutrition_vitamin_c'
WHERE c.name IN ('柑橘类', '浆果类', '仁果类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'nutrition_fiber'
WHERE c.name IN ('叶菜类', '豆类', '菌菇类', '花菜类');

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `category` c ON c.id = g.category_id
JOIN `tag` t ON t.tag_code = 'nutrition_satiety'
WHERE c.name IN ('根茎类', '豆类', '菌菇类', '瓜类');

-- 3.8 storage / selling tags
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'storage_cold'
WHERE COALESCE(g.keywords, '') LIKE '%冷藏%';

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'selling_recommend'
WHERE g.is_recommend = 1;

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.id, t.id
FROM `goods` g
JOIN `tag` t ON t.tag_code = 'selling_hot'
WHERE g.sales_volume >= 500;

COMMIT;

-- 4) Manual review queries (run after migration)
-- 4.1 Goods without scene tags
-- SELECT g.id, g.name FROM goods g
-- LEFT JOIN goods_tag gt ON gt.goods_id = g.id
-- LEFT JOIN tag t ON t.id = gt.tag_id AND t.tag_type = 'scene'
-- WHERE t.id IS NULL;

-- 4.2 Goods without role tags
-- SELECT g.id, g.name FROM goods g
-- LEFT JOIN goods_tag gt ON gt.goods_id = g.id
-- LEFT JOIN tag t ON t.id = gt.tag_id AND t.tag_type = 'role'
-- WHERE t.id IS NULL;

-- 4.3 Suggested manual correction set (high ambiguity)
-- SELECT id, name, category_id, unit FROM goods
-- WHERE name REGEXP '瓜|豆|果|菌|菜|梨|桃|薯|蒜|椒';
