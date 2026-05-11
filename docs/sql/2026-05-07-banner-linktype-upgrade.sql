-- Banner link_type 升级为字符串枚举，支持 none / knowledge / goodsDetail / category / url / search / goods
-- 执行前请先备份数据库

START TRANSACTION;

ALTER TABLE `banner`
  MODIFY COLUMN `link_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'none' COMMENT '跳转类型：none/goodsDetail/category/url/knowledge/search/goods';

UPDATE `banner`
SET `link_type` = CASE `link_type`
  WHEN '0' THEN 'none'
  WHEN '1' THEN 'goodsDetail'
  WHEN '2' THEN 'category'
  WHEN '3' THEN 'url'
  WHEN '4' THEN 'knowledge'
  ELSE `link_type`
END;

UPDATE `banner`
SET `link_value` = ''
WHERE `link_type` = 'none' AND (`link_value` IS NULL);

COMMIT;