SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- 商品信息真实化补丁（仅UPDATE）
-- 目标：在保留你已筛选商品前提下，补全更真实的商品文案、关键词、原价与运营字段

-- 1) 文案真实化：按水果/蔬菜与典型品种特征补全 detail
UPDATE `goods`
SET `detail` = CASE
  WHEN `name` LIKE '%草莓%' THEN CONCAT(`name`, '｜建议挑选果面有光泽、果蒂鲜绿的批次，口感偏酸甜，适合鲜食、酸奶杯和轻食沙拉。到货后建议冷藏2-4℃保存，24小时内食用风味最佳。')
  WHEN `name` LIKE '%蓝莓%' THEN CONCAT(`name`, '｜果粉完整、手感干爽说明新鲜度更好，适合直接食用、烘焙与奶昔。建议冷藏保鲜，食用前轻冲洗并沥干。')
  WHEN `name` LIKE '%葡萄%' THEN CONCAT(`name`, '｜建议选择果粒饱满、果梗青绿的批次，甜度与汁水表现更稳定。适合鲜食或冷泡果饮，冷藏后口感更佳。')
  WHEN `name` LIKE '%橙%' OR `name` LIKE '%柑%' OR `name` LIKE '%柠檬%' THEN CONCAT(`name`, '｜柑橘类适合补充维C，鲜食与榨汁都合适。建议置于阴凉通风处短存，需久放可冷藏并尽量分批取用。')
  WHEN `name` LIKE '%西瓜%' OR `name` LIKE '%哈密瓜%' OR `name` LIKE '%香瓜%' THEN CONCAT(`name`, '｜瓜类建议按需购买，切开后请及时冷藏并覆盖保鲜。适合夏季鲜食、果盘与轻饮，口感以清甜多汁为主。')
  WHEN `name` LIKE '%桃%' OR `name` LIKE '%李%' OR `name` LIKE '%樱桃%' THEN CONCAT(`name`, '｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。')
  WHEN `name` LIKE '%苹果%' OR `name` LIKE '%梨%' THEN CONCAT(`name`, '｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。')
  WHEN `name` LIKE '%菠萝%' OR `name` LIKE '%无花果%' OR `name` LIKE '%桑葚%' THEN CONCAT(`name`, '｜该品类风味层次明显，适合鲜食、轻甜品或沙拉搭配。建议低温保鲜并避免长时间挤压。')

  WHEN `name` LIKE '%生菜%' OR `name` LIKE '%油麦%' OR `name` LIKE '%菠菜%' OR `name` LIKE '%小白菜%' THEN CONCAT(`name`, '｜叶菜类建议快炒或汆烫，清洗后沥干再入锅可减少出水。适合家常快手菜，建议到货后尽快食用。')
  WHEN `name` LIKE '%西兰花%' OR `name` LIKE '%花菜%' THEN CONCAT(`name`, '｜花菜类适合焯水后再炒，口感更脆且更易入味。适合清炒、蒜蓉和便当配菜，冷藏可短期保鲜。')
  WHEN `name` LIKE '%胡萝卜%' OR `name` LIKE '%白萝卜%' OR `name` LIKE '%红薯%' OR `name` LIKE '%土豆%' THEN CONCAT(`name`, '｜根茎类储存性较好，适合炖煮、快炒和汤底搭配。建议阴凉干燥保存，避免与高湿食材混放。')
  WHEN `name` LIKE '%黄瓜%' OR `name` LIKE '%苦瓜%' OR `name` LIKE '%南瓜%' THEN CONCAT(`name`, '｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。')
  WHEN `name` LIKE '%豆芽%' OR `name` LIKE '%四季豆%' OR `name` LIKE '%荷兰豆%' OR `name` LIKE '%豌豆%' OR `name` LIKE '%毛豆%' THEN CONCAT(`name`, '｜豆类蔬菜适合快炒与配菜搭配，建议控制火候以保留脆嫩口感。到货后冷藏并尽快食用。')
  WHEN `name` LIKE '%番茄%' OR `name` LIKE '%茄子%' OR `name` LIKE '%彩椒%' THEN CONCAT(`name`, '｜茄果类适合家常快炒、炖煮和轻食搭配，风味稳定且适配度高。建议按成熟度分批食用。')
  WHEN `name` LIKE '%金针菇%' OR `name` LIKE '%香菇%' OR `name` LIKE '%杏鲍菇%' THEN CONCAT(`name`, '｜菌菇类适合火锅、汤品与小炒，建议清洗后沥干再烹饪，口感更佳。冷藏条件下建议2天内使用。')

  ELSE CONCAT(`name`, '｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。')
END
WHERE `status` = 1;

-- 2) 关键词真实化：按品类补全“风味+用途+储存+产地”维度
UPDATE `goods`
SET `keywords` = CONCAT_WS(',',
  `name`,
  IFNULL(NULLIF(TRIM(`origin`), ''), '时令产区'),
  CASE
    WHEN `category_id` IN (11,12,13,14,15,16) THEN '鲜食水果'
    WHEN `category_id` IN (3,4,5,6,7,8,9,10) THEN '家常蔬菜'
    ELSE '时令蔬果'
  END,
  CASE
    WHEN `name` LIKE '%草莓%' OR `name` LIKE '%蓝莓%' OR `name` LIKE '%樱桃%' THEN '酸甜'
    WHEN `name` LIKE '%苹果%' OR `name` LIKE '%橙%' OR `name` LIKE '%梨%' THEN '清甜'
    WHEN `name` LIKE '%柠檬%' THEN '清香'
    WHEN `name` LIKE '%西兰花%' OR `name` LIKE '%生菜%' THEN '脆嫩'
    WHEN `name` LIKE '%香菇%' OR `name` LIKE '%金针菇%' THEN '鲜香'
    ELSE '新鲜'
  END,
  CASE
    WHEN `category_id` IN (11,12,13,14,15,16) THEN '冷藏保存'
    ELSE '家常烹饪'
  END
)
WHERE `status` = 1;

-- 3) 原价修正：保持真实价差（1.12~1.28区间），避免机械统一
UPDATE `goods`
SET `original_price` = ROUND(`price` * (
  CASE
    WHEN `price` <= 6 THEN 1.28
    WHEN `price` <= 10 THEN 1.24
    WHEN `price` <= 20 THEN 1.20
    WHEN `price` <= 35 THEN 1.16
    ELSE 1.12
  END
), 2)
WHERE `status` = 1 AND (`original_price` IS NULL OR `original_price` < `price` OR `original_price` > `price` * 1.6);

-- 4) 销量修正：只修异常值（0或空），按品类价格与推荐属性给自然分层
UPDATE `goods`
SET `sales_volume` =
  CASE
    WHEN `is_recommend` = 1 AND `price` <= 12 THEN 600 + (`id` % 900)
    WHEN `is_recommend` = 1 THEN 300 + (`id` % 500)
    WHEN `category_id` IN (11,12,13,14,15,16) THEN 120 + (`id` % 260)
    ELSE 90 + (`id` % 220)
  END
WHERE `status` = 1 AND (`sales_volume` IS NULL OR `sales_volume` <= 0);

-- 5) 首页排序修正：仅处理明显异常值
UPDATE `goods`
SET `home_sort` = (`id` % 80) + 1
WHERE `status` = 1 AND (`home_sort` IS NULL OR `home_sort` <= 0 OR `home_sort` > 500);

-- 6) 推荐修正：只对活跃畅销商品补推荐，不全量打开
UPDATE `goods`
SET `is_recommend` = 1
WHERE `status` = 1
  AND `stock` > 0
  AND `sales_volume` >= 450
  AND `price` BETWEEN 6 AND 40
  AND (`is_recommend` IS NULL OR `is_recommend` = 0);

-- 7) 秒杀清洗：关闭无效秒杀，保留合理秒杀
UPDATE `goods`
SET `is_flash` = 0,
    `flash_price` = NULL,
    `flash_start_time` = NULL,
    `flash_end_time` = NULL,
    `flash_stock` = 0
WHERE `is_flash` = 1
  AND (
    `flash_price` IS NULL
    OR `flash_price` <= 0
    OR `flash_price` >= `price`
    OR `flash_start_time` IS NULL
    OR `flash_end_time` IS NULL
    OR `flash_end_time` <= `flash_start_time`
  );

UPDATE `goods`
SET `flash_stock` = LEAST(GREATEST(FLOOR(`stock` * 0.3), 10), `stock`)
WHERE `is_flash` = 1 AND (`flash_stock` IS NULL OR `flash_stock` <= 0);

-- 8) 产地兜底
UPDATE `goods`
SET `origin` = '全国优选产区'
WHERE `status` = 1 AND (`origin` IS NULL OR CHAR_LENGTH(TRIM(`origin`)) = 0);

SET FOREIGN_KEY_CHECKS = 1;