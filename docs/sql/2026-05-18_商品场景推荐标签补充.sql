SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

/*
  用途：
  1. 补充蔬果搭配细分场景标签
  2. 按当前商品名称/关键词，为适合的商品补充 goods_tag 关联

  说明：
  1. 不修改 goods 表本身
  2. 不删除旧标签
  3. 使用 INSERT IGNORE，重复执行不会报错
  4. 适配当前项目 MySQL 5.5
*/

START TRANSACTION;

-- --------------------------------------------------
-- 1. 新增场景标签（如不存在则插入）
-- --------------------------------------------------

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '场景-沙拉', 2, 'scene_combo_salad', 'scene', 1, 22, '适配沙拉搭配方案'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `tag` WHERE `tag_code` = 'scene_combo_salad'
);

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '场景-榨汁', 2, 'scene_combo_juice', 'scene', 1, 23, '适配榨汁搭配方案'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `tag` WHERE `tag_code` = 'scene_combo_juice'
);

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '场景-火锅', 2, 'scene_combo_hotpot', 'scene', 1, 24, '适配火锅搭配方案'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `tag` WHERE `tag_code` = 'scene_combo_hotpot'
);

INSERT INTO `tag` (`tag_name`, `type`, `tag_code`, `tag_type`, `status`, `sort`, `description`)
SELECT '场景-便当配菜', 2, 'scene_combo_bento_side', 'scene', 1, 25, '适配便当配菜搭配方案'
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `tag` WHERE `tag_code` = 'scene_combo_bento_side'
);

-- --------------------------------------------------
-- 2. 补充场景标签关联
-- --------------------------------------------------

-- 2.1 沙拉场景
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, t.`id`
FROM `goods` g
JOIN `tag` t ON t.`tag_code` = 'scene_combo_salad'
WHERE g.`status` = 1
  AND (
    g.`name` IN (
      '生菜', '油麦菜', '苦菊', '紫甘蓝', '黄瓜', '圣女果', '小番茄',
      '玉米', '牛油果', '苹果', '蓝莓', '草莓', '梨', '橙子'
    )
    OR g.`keywords` LIKE '%沙拉%'
    OR g.`keywords` LIKE '%轻食%'
    OR g.`keywords` LIKE '%鲜食%'
    OR g.`keywords` LIKE '%即食%'
    OR g.`keywords` LIKE '%凉拌%'
  );

-- 2.2 榨汁场景
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, t.`id`
FROM `goods` g
JOIN `tag` t ON t.`tag_code` = 'scene_combo_juice'
WHERE g.`status` = 1
  AND (
    g.`name` IN (
      '橙子', '苹果', '梨', '胡萝卜', '黄瓜', '西芹', '柠檬',
      '番茄', '草莓', '蓝莓', '葡萄', '菠萝'
    )
    OR g.`keywords` LIKE '%榨汁%'
    OR g.`keywords` LIKE '%果汁%'
    OR g.`keywords` LIKE '%果饮%'
    OR g.`keywords` LIKE '%奶昔%'
    OR g.`keywords` LIKE '%冰沙%'
  );

-- 2.3 火锅场景
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, t.`id`
FROM `goods` g
JOIN `tag` t ON t.`tag_code` = 'scene_combo_hotpot'
WHERE g.`status` = 1
  AND (
    g.`name` IN (
      '白菜', '娃娃菜', '茼蒿', '菠菜', '生菜', '油麦菜',
      '土豆', '白萝卜', '冬瓜', '玉米', '山药',
      '金针菇', '香菇', '平菇', '杏鲍菇'
    )
    OR g.`keywords` LIKE '%火锅%'
    OR g.`keywords` LIKE '%煮食%'
    OR g.`keywords` LIKE '%炖汤%'
    OR g.`keywords` LIKE '%涮锅%'
  );

-- 2.4 便当配菜场景
INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT g.`id`, t.`id`
FROM `goods` g
JOIN `tag` t ON t.`tag_code` = 'scene_combo_bento_side'
WHERE g.`status` = 1
  AND (
    g.`name` IN (
      '西兰花', '玉米', '胡萝卜', '圣女果', '小番茄',
      '黄瓜', '生菜', '紫甘蓝', '南瓜', '秋葵', '芦笋'
    )
    OR g.`keywords` LIKE '%便当%'
    OR g.`keywords` LIKE '%配菜%'
    OR g.`keywords` LIKE '%轻食%'
    OR g.`keywords` LIKE '%鲜食%'
  );

-- --------------------------------------------------
-- 3. 给细分场景商品补一个通用搭配标签（如项目仍保留通用搭配池）
-- --------------------------------------------------

INSERT IGNORE INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT DISTINCT gt.`goods_id`, t_mix.`id`
FROM `goods_tag` gt
JOIN `tag` t_scene ON t_scene.`id` = gt.`tag_id`
JOIN `tag` t_mix ON t_mix.`tag_code` = 'scene_combo_mix'
WHERE t_scene.`tag_code` IN (
  'scene_combo_salad',
  'scene_combo_juice',
  'scene_combo_hotpot',
  'scene_combo_bento_side'
);

COMMIT;

-- --------------------------------------------------
-- 4. 执行后可用以下语句检查结果
-- --------------------------------------------------

-- 查看新增的场景标签
-- SELECT id, tag_name, tag_code, tag_type FROM tag
-- WHERE tag_code IN (
--   'scene_combo_salad',
--   'scene_combo_juice',
--   'scene_combo_hotpot',
--   'scene_combo_bento_side',
--   'scene_combo_mix'
-- )
-- ORDER BY id;

-- 查看已打上场景标签的商品
-- SELECT g.id, g.name, t.tag_name, t.tag_code
-- FROM goods_tag gt
-- JOIN goods g ON g.id = gt.goods_id
-- JOIN tag t ON t.id = gt.tag_id
-- WHERE t.tag_code IN (
--   'scene_combo_salad',
--   'scene_combo_juice',
--   'scene_combo_hotpot',
--   'scene_combo_bento_side',
--   'scene_combo_mix'
-- )
-- ORDER BY t.tag_code, g.id;

SET FOREIGN_KEY_CHECKS = 1;
