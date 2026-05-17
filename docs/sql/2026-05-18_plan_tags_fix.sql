INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'role_fruit'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '草莓|蓝莓|葡萄|橙|丑橘|柠檬|西瓜|哈密瓜|香瓜|水蜜桃|黑布李|樱桃|苹果|梨|枇杷|菠萝|无花果|桑葚|香蕉|桃|莓|果';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'role_main'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '番茄|土豆|南瓜|玉米|山药|红薯|芋头|胡萝卜|彩椒|豆腐|茄子|菌|菇';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'role_side'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '生菜|菠菜|油麦|空心菜|西兰花|花菜|黄瓜|秋葵|荷兰豆|豌豆|毛豆|四季豆|豆角|笋|西葫芦|苦瓜|菜';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'role_base'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '番茄|黄瓜|胡萝卜|玉米|土豆|南瓜|山药|红薯|芋头|西兰花|菌|菇|苹果|橙|柠檬';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'role_veg'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '生菜|菠菜|油麦|空心菜|西兰花|花菜|黄瓜|秋葵|荷兰豆|豌豆|毛豆|四季豆|豆角|笋|西葫芦|苦瓜|番茄|菜';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT gt.goods_id, t.id
FROM goods_tag gt
JOIN tag role_tag ON role_tag.id = gt.tag_id
JOIN tag t ON t.tag_code = 'scene_combo_mix'
WHERE role_tag.tag_code IN ('role_fruit', 'role_base', 'role_veg');

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'scene_combo_salad'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '生菜|黄瓜|番茄|蓝莓|草莓|苹果|牛油果|西兰花|橙';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'scene_combo_juice'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '柠檬|橙|苹果|胡萝卜|番茄|黄瓜|草莓|蓝莓|梨';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'scene_combo_hotpot'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '番茄|土豆|玉米|菌|菇|西兰花|花菜|豆腐|荷兰豆|豆角|菜';

INSERT IGNORE INTO goods_tag(goods_id, tag_id)
SELECT g.id, t.id
FROM goods g
JOIN tag t ON t.tag_code = 'scene_combo_bento_side'
WHERE CONCAT(IFNULL(g.name, ''), ',', IFNULL(g.keywords, '')) REGEXP '西兰花|胡萝卜|玉米|秋葵|花菜|菌|菇|荷兰豆|豌豆|毛豆';
