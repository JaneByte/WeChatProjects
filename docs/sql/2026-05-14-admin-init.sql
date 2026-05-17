-- 2026-05-14-admin-init.sql
-- 作用：初始化管理员后台账号表与默认管理员数据
USE `freshtime`;

CREATE TABLE IF NOT EXISTS `admin` (
  `id` BIGINT NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` VARCHAR(50) NOT NULL COMMENT '管理员账号',
  `password` VARCHAR(100) NOT NULL COMMENT '管理员密码',
  `nickname` VARCHAR(50) NOT NULL DEFAULT '' COMMENT '管理员昵称',
  `status` TINYINT NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
  `create_time` DATETIME NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_admin_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci COMMENT='管理员表';

INSERT INTO `admin` (`username`, `password`, `nickname`, `status`, `create_time`)
SELECT 'admin', '123456', '系统管理员', 1, NOW()
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1
  FROM `admin`
  WHERE `username` = 'admin'
);
