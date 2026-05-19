-- 毕设演示用：首页秒杀商品配置
-- 作用：
-- 1. 先清空当前所有商品的秒杀状态
-- 2. 再为 3 个高认知商品开启“当前正在生效”的秒杀
-- 3. 执行后首页“限时秒杀”模块会立即显示
--
-- 使用说明：
-- 1. 在你的数据库中直接执行本文件
-- 2. 执行完成后，刷新后端首页接口或重新进入小程序首页即可看到效果
--
-- 说明：
-- 1. 本脚本仅修改 goods 表中的秒杀相关字段
-- 2. 选择了橙子、红富士苹果、西瓜三种商品，比较适合演示

START TRANSACTION;

-- 第一步：清空现有秒杀配置，避免历史秒杀数据互相干扰
UPDATE `goods`
SET
  `is_flash` = 0,
  `flash_price` = NULL,
  `flash_start_time` = NULL,
  `flash_end_time` = NULL,
  `flash_stock` = 0
WHERE `status` = 1;

-- 第二步：配置当前正在生效的秒杀商品
-- 橙子：高频、低门槛、适合首页展示
UPDATE `goods`
SET
  `is_flash` = 1,
  `flash_price` = 6.90,
  `flash_start_time` = DATE_SUB(NOW(), INTERVAL 1 DAY),
  `flash_end_time` = DATE_ADD(NOW(), INTERVAL 20 DAY),
  `flash_stock` = LEAST(`stock`, 40)
WHERE `id` = 4
  AND `status` = 1
  AND `stock` > 0;

-- 红富士苹果：大众认知高，适合作为稳定款秒杀
UPDATE `goods`
SET
  `is_flash` = 1,
  `flash_price` = 7.90,
  `flash_start_time` = DATE_SUB(NOW(), INTERVAL 1 DAY),
  `flash_end_time` = DATE_ADD(NOW(), INTERVAL 20 DAY),
  `flash_stock` = LEAST(`stock`, 36)
WHERE `id` = 13
  AND `status` = 1
  AND `stock` > 0;

-- 西瓜：季节感强，首页视觉效果好
UPDATE `goods`
SET
  `is_flash` = 1,
  `flash_price` = 2.30,
  `flash_start_time` = DATE_SUB(NOW(), INTERVAL 1 DAY),
  `flash_end_time` = DATE_ADD(NOW(), INTERVAL 20 DAY),
  `flash_stock` = LEAST(`stock`, 50)
WHERE `id` = 7
  AND `status` = 1
  AND `stock` > 0;

COMMIT;

-- 可选检查：执行后可运行下面这条 SQL 确认是否已生效
-- SELECT id, name, price, flash_price, flash_stock, flash_start_time, flash_end_time
-- FROM goods
-- WHERE status = 1
--   AND is_flash = 1
--   AND flash_stock > 0
--   AND flash_start_time <= NOW()
--   AND flash_end_time >= NOW()
-- ORDER BY flash_end_time ASC, home_sort ASC, flash_price ASC, sales_volume DESC;
