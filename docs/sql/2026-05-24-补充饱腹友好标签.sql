-- 说明：
-- 1. 本脚本用于补充“营养-饱腹友好”标签（tag_id = 143）
-- 2. 仅补充当前 freshtime.sql 中明显适合作为高饱腹感食材的商品
-- 3. 使用 INSERT ... SELECT ... WHERE NOT EXISTS，避免重复插入

USE `freshtime`;

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 28, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 28 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 34, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 34 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 36, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 36 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 40, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 40 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 41, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 41 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 44, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 44 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 46, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 46 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 53, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 53 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 54, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 54 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 57, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 57 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 58, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 58 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 59, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 59 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 60, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 60 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 61, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 61 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 62, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 62 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 63, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 63 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 64, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 64 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 65, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 65 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 66, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 66 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 69, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 69 AND `tag_id` = 143
);

INSERT INTO `goods_tag` (`goods_id`, `tag_id`)
SELECT 70, 143 FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `goods_tag` WHERE `goods_id` = 70 AND `tag_id` = 143
);
