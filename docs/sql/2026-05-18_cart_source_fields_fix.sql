ALTER TABLE `cart`
  ADD COLUMN `source_type` varchar(32) DEFAULT NULL COMMENT '来源类型：NORMAL/MEAL/COMBO/SEASONAL/MIXED',
  ADD COLUMN `source_plan_id` bigint DEFAULT NULL COMMENT '来源方案ID',
  ADD COLUMN `source_scene` varchar(64) DEFAULT NULL COMMENT '来源场景'
;
