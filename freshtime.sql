/*
 Navicat Premium Data Transfer

 Source Server         : freshtime
 Source Server Type    : MySQL
 Source Server Version : 50562 (5.5.62)
 Source Host           : localhost:3306
 Source Schema         : freshtime

 Target Server Type    : MySQL
 Target Server Version : 50562 (5.5.62)
 File Encoding         : 65001

 Date: 02/05/2026 14:46:37
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for address
-- ----------------------------
DROP TABLE IF EXISTS `address`;
CREATE TABLE `address`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '地址ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `receiver_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货人手机号',
  `province` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '省份',
  `city` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '城市',
  `district` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '区/县',
  `detail` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '详细地址',
  `is_default` tinyint(4) NULL DEFAULT 0 COMMENT '是否默认地址 0否 1是',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收货地址表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, 2, '陈女士', '123456', '湖南省', '长沙', '天心区', '中南林业科技大学', 0, '2026-04-28 16:22:17');
INSERT INTO `address` VALUES (2, 3693519, 'jiannvshi', '123', 'q', 'a', 'a', '1', 0, '2026-04-28 16:26:07');
INSERT INTO `address` VALUES (3, 22, 'abc', '12345678910', '北京市', '海淀区', 'a', 'xxxx', 0, '2026-04-28 18:42:09');
INSERT INTO `address` VALUES (4, 25, 'a', '18229656601', 'a', 'xx', 'avbc', 'iii', 0, '2026-04-28 18:50:13');
INSERT INTO `address` VALUES (5, 25, 'a', '18229656601', 'a', 'xx', 'avbc', 'iii', 0, '2026-04-28 18:50:14');
INSERT INTO `address` VALUES (6, 33, 'a', '12345678910', 'a', 'a', 'a', 'a', 0, '2026-04-28 18:59:45');
INSERT INTO `address` VALUES (7, 41, 'a', '12345678910', 'a', 'a', 'a', 'a', 1, '2026-04-28 19:59:01');
INSERT INTO `address` VALUES (8, 45, 'a', '12345678910', 'a', 'a', 'a', 'a', 1, '2026-04-29 16:54:08');

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '管理员ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码（加密存储）',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1正常',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '管理员表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of admin
-- ----------------------------

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `image` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '图片URL',
  `link_type` tinyint(4) NULL DEFAULT 0 COMMENT '跳转类型 0无 1商品详情 2分类 3外链',
  `link_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '跳转值（商品ID/分类ID/URL）',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '轮播图表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of banner
-- ----------------------------

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '购物车项ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '商家ID',
  `quantity` int(11) NOT NULL DEFAULT 1 COMMENT '购买数量',
  `selected` tinyint(4) NULL DEFAULT 1 COMMENT '是否选中 0否 1是',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_goods`(`user_id`, `goods_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '购物车表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (4, 39, 3, 1, 1, 1, '2026-04-28 19:32:51');

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '分类ID',
  `name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '分类名称（如：蔬菜、水果、菌菇）',
  `icon` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分类图标',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序值（越小越靠前）',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `parent_id` bigint(20) NULL DEFAULT 0 COMMENT '父分类ID，0表示顶级分类',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_parent_id`(`parent_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品分类表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '蔬菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/vegetable.png', 1, 1, '2026-04-20 16:06:37', 0);
INSERT INTO `category` VALUES (2, '水果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/fruit.png', 2, 1, '2026-04-20 16:06:37', 0);
INSERT INTO `category` VALUES (3, '叶菜类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/叶菜.png', 1, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (4, '根茎类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/根茎.png', 2, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (5, '茄果类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/茄果.png', 3, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (6, '菌菇类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/菌菇.png', 4, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (7, '瓜类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/瓜.png', 5, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (8, '豆类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/豆.png', 6, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (9, '葱姜蒜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/葱姜蒜.png', 7, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (10, '花菜类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/花菜.png', 8, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (11, '浆果类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/浆果.png', 1, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (12, '柑橘类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/柑橘.png', 2, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (13, '瓜类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/瓜果.png', 3, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (14, '核果类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/核果.png', 4, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (15, '仁果类', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/仁果.png', 5, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (16, '聚花果类及其他', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/蔬菜水果/聚花果类.png', 6, 1, '2026-04-21 15:23:54', 2);

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '商家ID',
  `rating` tinyint(4) NOT NULL COMMENT '评分 1-5星',
  `content` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '评价内容',
  `images` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '评价图片（JSON数组）',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '评价时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '评价表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of comment
-- ----------------------------

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商品ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '所属商家ID',
  `category_id` bigint(20) NOT NULL COMMENT '分类ID',
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称',
  `main_image` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '主图URL',
  `images` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '详情图片（JSON数组存储多张）',
  `detail` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '商品详情（富文本）',
  `price` decimal(10, 2) NOT NULL COMMENT '售价',
  `original_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '原价（划线价）',
  `stock` int(11) NOT NULL DEFAULT 0 COMMENT '库存数量',
  `unit` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT '斤' COMMENT '单位（斤、个、份、kg等）',
  `sales_volume` int(11) NULL DEFAULT 0 COMMENT '销量',
  `is_recommend` tinyint(4) NULL DEFAULT 0 COMMENT '是否推荐 0否 1是',
  `is_flash` tinyint(4) NULL DEFAULT 0 COMMENT '是否秒杀 0否1是',
  `flash_price` decimal(10, 2) NULL DEFAULT NULL COMMENT '秒杀价',
  `flash_start_time` datetime NULL DEFAULT NULL COMMENT '秒杀开始时间',
  `flash_end_time` datetime NULL DEFAULT NULL COMMENT '秒杀结束时间',
  `flash_stock` int(11) NULL DEFAULT 0 COMMENT '秒杀库存',
  `home_sort` int(11) NULL DEFAULT 0 COMMENT '首页排序（越小越靠前）',
  `show_in_home` tinyint(4) NULL DEFAULT 1 COMMENT '是否首页展示 0否1是',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0下架 1上架',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `keywords` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '搜索关键词，逗号分隔（如：芭乐,鸡屎果,番桃）',
  `origin` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '产地（如：山东、新疆、进口）',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE,
  INDEX `idx_category_id`(`category_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_goods_home`(`show_in_home`, `status`, `home_sort`) USING BTREE,
  INDEX `idx_goods_flash`(`is_flash`, `flash_start_time`, `flash_end_time`, `status`) USING BTREE,
  INDEX `idx_goods_sales`(`sales_volume`, `status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 19 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, 1, 11, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', NULL, NULL, 25.80, 32.80, 97, '斤', 895, 1, 0, NULL, NULL, NULL, 0, 3, 1, 1, '2026-04-26 23:44:33', '草莓,奶油草莓,浆果', '山东');
INSERT INTO `goods` VALUES (2, 1, 11, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', NULL, NULL, 38.80, 45.80, 79, '盒', 457, 0, 0, NULL, NULL, NULL, 0, 5, 1, 1, '2026-04-25 23:44:33', '蓝莓,浆果,护眼', '云南');
INSERT INTO `goods` VALUES (3, 1, 11, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', NULL, NULL, 18.80, NULL, 146, '斤', 1028, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '葡萄,巨峰,多汁', '新疆');
INSERT INTO `goods` VALUES (4, 1, 12, '橙子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg', NULL, NULL, 8.80, 10.80, 300, '斤', 1567, 1, 0, NULL, NULL, NULL, 0, 2, 1, 1, '2026-04-26 23:44:33', '橙子,柑橘,维C', '江西');
INSERT INTO `goods` VALUES (5, 1, 12, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', NULL, NULL, 7.50, NULL, 249, '斤', 1025, 1, 1, 7.90, '2026-04-27 23:44:33', '2026-04-28 05:44:33', 22, 0, 1, 1, '2026-04-21 15:33:25', '丑橘,柑橘,果冻橙', '四川');
INSERT INTO `goods` VALUES (6, 1, 12, '柠檬', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/柠檬.jpg', NULL, NULL, 6.80, 8.80, 180, '斤', 567, 0, 1, 6.90, '2026-04-27 23:44:33', '2026-04-28 05:44:33', 30, 0, 1, 1, '2026-04-21 15:33:25', '柠檬,泡水,维C', '海南');
INSERT INTO `goods` VALUES (7, 1, 13, '西瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/西瓜.jpg', NULL, NULL, 3.80, NULL, 300, '斤', 1567, 0, 0, NULL, NULL, NULL, 0, 6, 1, 1, '2026-04-21 15:33:25', '西瓜,瓜类,夏季', '河南');
INSERT INTO `goods` VALUES (8, 1, 13, '哈密瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/哈密瓜.jpg', NULL, NULL, 8.80, 10.80, 150, '个', 678, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '哈密瓜,瓜类,香甜', '新疆');
INSERT INTO `goods` VALUES (9, 1, 13, '香瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/香瓜.jpg', NULL, NULL, 6.80, NULL, 120, '斤', 345, 0, 1, 5.90, '2026-04-27 23:44:33', '2026-04-28 05:44:33', 36, 0, 1, 1, '2026-04-21 15:33:25', '香瓜,瓜类,清甜', '海南');
INSERT INTO `goods` VALUES (10, 1, 14, '水蜜桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/水蜜桃.jpg', NULL, NULL, 18.80, 22.80, 120, '斤', 678, 1, 0, NULL, NULL, NULL, 0, 4, 1, 1, '2026-04-25 23:44:33', '水蜜桃,核果,香甜', '浙江');
INSERT INTO `goods` VALUES (11, 1, 14, '黑布李', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黑布李.jpg', NULL, NULL, 12.80, NULL, 150, '斤', 345, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '黑布李,李子,核果', '广东');
INSERT INTO `goods` VALUES (12, 1, 14, '樱桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/樱桃.jpg', NULL, NULL, 48.80, 58.80, 60, '斤', 234, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '樱桃,核果,高端水果', '山东');
INSERT INTO `goods` VALUES (13, 1, 15, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', NULL, NULL, 9.80, 12.80, 299, '斤', 2049, 1, 0, NULL, NULL, NULL, 0, 1, 1, 1, '2026-04-26 23:44:33', '苹果,红富士,脆甜', '陕西');
INSERT INTO `goods` VALUES (14, 1, 15, '皇冠梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/皇冠梨.jpg', NULL, NULL, 7.80, NULL, 250, '斤', 1024, 0, 0, NULL, NULL, NULL, 0, 7, 1, 1, '2026-04-21 15:33:25', '皇冠梨,梨,多汁', '河北');
INSERT INTO `goods` VALUES (15, 1, 15, '枇杷', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/枇杷.jpg', NULL, NULL, 8.80, 10.80, 180, '斤', 567, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '枇杷,仁果,润喉', '福建');
INSERT INTO `goods` VALUES (16, 1, 16, '菠萝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝.jpg', NULL, NULL, 12.80, 15.80, 100, '个', 678, 0, 0, NULL, NULL, NULL, 0, 8, 1, 1, '2026-04-25 23:44:33', '菠萝,热带水果,酸甜', '海南');
INSERT INTO `goods` VALUES (17, 1, 16, '无花果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/无花果.jpg', NULL, NULL, 22.80, 28.80, 60, '斤', 234, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '无花果,聚花果,软糯', '四川');
INSERT INTO `goods` VALUES (18, 1, 16, '桑葚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/桑葚.jpg', NULL, NULL, 15.80, NULL, 76, '盒', 349, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '桑葚,浆果,花青素', '广西');

-- ----------------------------
-- Table structure for goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `goods_sku`;
CREATE TABLE `goods_sku`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '规格ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `spec_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规格名称（如：500g、1000g）',
  `price` decimal(10, 2) NOT NULL COMMENT '规格价格',
  `stock` int(11) NOT NULL DEFAULT 0 COMMENT '规格库存',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品规格表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of goods_sku
-- ----------------------------

-- ----------------------------
-- Table structure for goods_tag
-- ----------------------------
DROP TABLE IF EXISTS `goods_tag`;
CREATE TABLE `goods_tag`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `goods_id` bigint(20) NOT NULL,
  `tag_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of goods_tag
-- ----------------------------

-- ----------------------------
-- Table structure for home_origin_card
-- ----------------------------
DROP TABLE IF EXISTS `home_origin_card`;
CREATE TABLE `home_origin_card`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
  `origin_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '产地名称',
  `card_desc` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '卡片描述',
  `card_meta` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '卡片标签',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用1启用',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序（越小越靠前）',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_status_sort`(`status`, `sort`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '首页产地溯源卡片' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of home_origin_card
-- ----------------------------
INSERT INTO `home_origin_card` VALUES (1, '山东寿光', '当日采收，次日发货', '蔬菜基地直采', 1, 1, '2026-04-27 23:38:01');
INSERT INTO `home_origin_card` VALUES (2, '云南高原', '高海拔慢生长，更香甜', '水果产区直供', 1, 2, '2026-04-27 23:38:01');
INSERT INTO `home_origin_card` VALUES (3, '海南乐东', '热带日照足，口感更稳定', '产地溯源可查', 1, 3, '2026-04-27 23:38:01');

-- ----------------------------
-- Table structure for merchant
-- ----------------------------
DROP TABLE IF EXISTS `merchant`;
CREATE TABLE `merchant`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商家ID',
  `username` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录账号',
  `password` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '登录密码（加密存储）',
  `shop_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '店铺名称',
  `contact_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系人姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '店铺地址',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '店铺简介',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1正常 2待审核',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '入驻时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商家表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of merchant
-- ----------------------------
INSERT INTO `merchant` VALUES (1, 'admin', '123456', '鲜果时光旗舰店', '张三', '075157183889', '湖南省长沙市天心区文源街道', NULL, 1, '2026-04-20 18:51:30');

-- ----------------------------
-- Table structure for order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `merchant_id` bigint(20) NOT NULL COMMENT '商家ID',
  `total_amount` decimal(10, 2) NOT NULL COMMENT '商品总金额',
  `discount_amount` decimal(10, 2) NULL DEFAULT 0.00 COMMENT '优惠金额',
  `actual_amount` decimal(10, 2) NOT NULL COMMENT '实付金额',
  `receiver_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货人姓名',
  `receiver_phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货人手机号',
  `receiver_address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '收货地址',
  `remark` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '订单备注',
  `status` tinyint(4) NOT NULL COMMENT '状态 0待付款 1待发货 2待收货 3已完成 4已取消 5已退款',
  `pay_time` timestamp NULL DEFAULT NULL COMMENT '支付时间',
  `deliver_time` timestamp NULL DEFAULT NULL COMMENT '发货时间',
  `finish_time` timestamp NULL DEFAULT NULL COMMENT '完成时间',
  `cancel_time` timestamp NULL DEFAULT NULL COMMENT '取消时间',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_order_no`(`order_no`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_merchant_id`(`merchant_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 17 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES (1, 'FT1777360002250A4A5D0', 1, 1, 32.60, 0.00, 32.60, '默认收货人', '13800000000', '默认收货地址', NULL, 4, NULL, NULL, NULL, NULL, '2026-04-28 15:06:42');
INSERT INTO `order` VALUES (2, 'FT17773600348125CAA4B', 1, 1, 26.30, 0.00, 26.30, '默认收货人', '13800000000', '默认收货地址', NULL, 4, NULL, NULL, NULL, NULL, '2026-04-28 15:07:14');
INSERT INTO `order` VALUES (3, 'FT177736021698855D2E1', 1, 1, 61.40, 0.00, 61.40, '默认收货人', '13800000000', '默认收货地址', NULL, 4, NULL, NULL, NULL, NULL, '2026-04-28 15:10:16');
INSERT INTO `order` VALUES (4, 'FT17773607735249F833F', 1, 1, 47.60, 0.00, 47.60, '默认收货人', '13800000000', '默认收货地址', NULL, 4, '2026-04-28 15:19:37', NULL, NULL, NULL, '2026-04-28 15:19:33');
INSERT INTO `order` VALUES (5, 'FT1777361007976374D76', 1, 1, 44.60, 0.00, 44.60, '默认收货人', '13800000000', '默认收货地址', NULL, 3, '2026-04-28 15:23:30', '2026-04-28 15:23:32', NULL, NULL, '2026-04-28 15:23:27');
INSERT INTO `order` VALUES (6, 'FT17773617211284CAFD3', 2, 1, 25.80, 0.00, 25.80, '默认收货人', '13800000000', '默认收货地址', NULL, 3, '2026-04-28 15:35:22', '2026-04-28 15:35:23', NULL, NULL, '2026-04-28 15:35:21');
INSERT INTO `order` VALUES (7, 'FT1777364541652D0D827', 2, 1, 25.80, 0.00, 25.80, '陈女士', '123456', '湖南省长沙天心区中南林业科技大学', NULL, 3, '2026-04-28 16:22:30', '2026-04-28 16:23:17', NULL, NULL, '2026-04-28 16:22:21');
INSERT INTO `order` VALUES (8, 'FT1777364771407C062B3', 3693519, 1, 48.60, 0.00, 48.60, 'jiannvshi', '123', 'qaa1', NULL, 3, '2026-04-28 16:26:26', '2026-04-28 16:26:33', NULL, NULL, '2026-04-28 16:26:11');
INSERT INTO `order` VALUES (9, 'FT1777372943976293DFC', 22, 1, 36.40, 0.00, 36.40, 'abc', '12345678910', '北京市海淀区axxxx', '配送到家', 4, NULL, NULL, NULL, NULL, '2026-04-28 18:42:23');
INSERT INTO `order` VALUES (10, 'FT17773729701201DC438', 22, 1, 6.80, 0.00, 6.80, 'abc', '12345678910', '北京市海淀区axxxx', '', 4, NULL, NULL, NULL, NULL, '2026-04-28 18:42:50');
INSERT INTO `order` VALUES (11, 'FT17773734250435E781A', 25, 1, 37.60, 0.00, 37.60, 'a', '18229656601', 'axxavbciii', '快速送达', 3, '2026-04-28 18:50:46', '2026-04-28 18:50:57', NULL, NULL, '2026-04-28 18:50:25');
INSERT INTO `order` VALUES (12, 'FT177737398888747CF65', 33, 1, 18.80, 0.00, 18.80, 'a', '12345678910', 'aaaa', '', 4, '2026-04-28 19:00:02', NULL, NULL, NULL, '2026-04-28 18:59:48');
INSERT INTO `order` VALUES (13, 'FT1777374063650114FAB', 33, 1, 18.80, 0.00, 18.80, 'a', '12345678910', 'aaaa', '', 4, NULL, NULL, NULL, NULL, '2026-04-28 19:01:03');
INSERT INTO `order` VALUES (14, 'FT1777377545303F093F1', 41, 1, 7.50, 0.00, 7.50, 'a', '12345678910', 'aaaa', '', 1, '2026-04-28 19:59:11', NULL, NULL, NULL, '2026-04-28 19:59:05');
INSERT INTO `order` VALUES (15, 'FT1777377605751C0E3E5', 41, 1, 63.20, 0.00, 63.20, 'a', '12345678910', 'aaaa', '', 1, '2026-04-28 20:00:10', NULL, NULL, NULL, '2026-04-28 20:00:05');
INSERT INTO `order` VALUES (16, 'FT1777452869015566591', 45, 1, 18.80, 0.00, 18.80, 'a', '12345678910', 'aaaa', '', 1, '2026-04-29 16:54:51', NULL, NULL, NULL, '2026-04-29 16:54:29');

-- ----------------------------
-- Table structure for order_item
-- ----------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `goods_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称（快照）',
  `goods_image` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片（快照）',
  `price` decimal(10, 2) NOT NULL COMMENT '购买时单价',
  `quantity` int(11) NOT NULL COMMENT '购买数量',
  `total_price` decimal(10, 2) NOT NULL COMMENT '小计金额',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id`) USING BTREE,
  INDEX `idx_order_item_goods_id`(`goods_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order_item
-- ----------------------------
INSERT INTO `order_item` VALUES (1, 1, 9, '香瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/香瓜.jpg', 6.80, 1, 6.80);
INSERT INTO `order_item` VALUES (2, 1, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (3, 2, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);
INSERT INTO `order_item` VALUES (4, 2, 5, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', 7.50, 1, 7.50);
INSERT INTO `order_item` VALUES (5, 3, 16, '菠萝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝.jpg', 12.80, 1, 12.80);
INSERT INTO `order_item` VALUES (6, 3, 2, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', 38.80, 1, 38.80);
INSERT INTO `order_item` VALUES (7, 3, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (8, 4, 2, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', 38.80, 1, 38.80);
INSERT INTO `order_item` VALUES (9, 4, 4, '橙子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg', 8.80, 1, 8.80);
INSERT INTO `order_item` VALUES (10, 5, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (11, 5, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);
INSERT INTO `order_item` VALUES (12, 6, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (13, 7, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (14, 8, 2, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', 38.80, 1, 38.80);
INSERT INTO `order_item` VALUES (15, 8, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (16, 9, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);
INSERT INTO `order_item` VALUES (17, 9, 15, '枇杷', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/枇杷.jpg', 8.80, 2, 17.60);
INSERT INTO `order_item` VALUES (18, 10, 9, '香瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/香瓜.jpg', 6.80, 1, 6.80);
INSERT INTO `order_item` VALUES (19, 11, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 2, 37.60);
INSERT INTO `order_item` VALUES (20, 12, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);
INSERT INTO `order_item` VALUES (21, 13, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);
INSERT INTO `order_item` VALUES (22, 14, 5, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', 7.50, 1, 7.50);
INSERT INTO `order_item` VALUES (23, 15, 18, '桑葚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/桑葚.jpg', 15.80, 4, 63.20);
INSERT INTO `order_item` VALUES (24, 16, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tag_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签名称',
  `type` tinyint(4) NULL DEFAULT 1 COMMENT '类型 1产地 2属性 3营销',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tag
-- ----------------------------

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户ID',
  `openid` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '微信openid',
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '头像URL',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '手机号',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1正常',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_openid`(`openid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 46 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'wxcode_0a3f4G2w3ZhrZ63SjM3w3ib7Ib3f4G2-', '微信用户', NULL, NULL, 1, '2026-04-28 17:46:09');
INSERT INTO `user` VALUES (2, 'wxcode_0b3awIll2ke6Dh4W0nll2hmqVj1awIlN', '微信用户', NULL, NULL, 1, '2026-04-28 17:46:50');
INSERT INTO `user` VALUES (3, 'wxcode_0b3wnRFa1kqCCL0wlDIa1ZeYTD0wnRFY', '微信用户', NULL, NULL, 1, '2026-04-28 17:51:03');
INSERT INTO `user` VALUES (4, 'wxcode_0b3OHall25NPCh4vHDll2a5lOd0OHalz', '微信用户', NULL, NULL, 1, '2026-04-28 17:51:31');
INSERT INTO `user` VALUES (5, 'wxcode_0e3GpJll2PuoDh4S16ml2UqOMk3GpJl9', '微信用户', NULL, NULL, 1, '2026-04-28 18:01:31');
INSERT INTO `user` VALUES (6, 'wxcode_0a3y0BFa1EsDCL0JlyIa1CAUNk3y0BFj', '微信用户', NULL, NULL, 1, '2026-04-28 18:02:10');
INSERT INTO `user` VALUES (7, 'wxcode_0d3eeSFa1rpUCL0nptIa1CgXVF2eeSFo', '微信用户', NULL, NULL, 1, '2026-04-28 18:04:59');
INSERT INTO `user` VALUES (8, 'wxcode_0c32vIGa10rKDL0LgzGa1MScBr32vIGP', '微信用户', NULL, NULL, 1, '2026-04-28 18:23:26');
INSERT INTO `user` VALUES (9, 'wxcode_0e3NqTFa1s3VCL0B6nGa1t28OE2NqTFk', '微信用户', NULL, NULL, 1, '2026-04-28 18:24:43');
INSERT INTO `user` VALUES (10, 'wxcode_0d3SLTFa1nRWCL07gwHa1koyRh4SLTFN', '微信用户', NULL, NULL, 1, '2026-04-28 18:30:17');
INSERT INTO `user` VALUES (11, 'wxcode_0d3c4DFa108FCL0IxJHa1Kj24H2c4DFV', '微信用户', NULL, NULL, 1, '2026-04-28 18:35:56');
INSERT INTO `user` VALUES (12, 'wxcode_0d3u4DFa1D8FCL0KTWFa1K2KGo4u4DF0', '微信用户', NULL, NULL, 1, '2026-04-28 18:36:01');
INSERT INTO `user` VALUES (13, 'wxcode_0f36Gf0w3WFhX636ch1w3Y9h9f36Gf0I', '微信用户', NULL, NULL, 1, '2026-04-28 18:36:10');
INSERT INTO `user` VALUES (14, 'wxcode_0a3dnFkl2XUjCh4kfhnl2JrTlu4dnFk7', '微信用户', NULL, NULL, 1, '2026-04-28 18:36:52');
INSERT INTO `user` VALUES (15, 'wxcode_0e33Spnl2Rn4Fh4aeuml2bw4sj03SpnP', '微信用户', NULL, NULL, 1, '2026-04-28 18:37:00');
INSERT INTO `user` VALUES (16, 'wxcode_0f3PD2ml22oHDh4spsol2tGxdZ2PD2mW', '微信用户', NULL, NULL, 1, '2026-04-28 18:37:15');
INSERT INTO `user` VALUES (17, 'wxcode_0a3CfbGa19odDL0eUMHa1CFIV43CfbGd', '微信用户', NULL, NULL, 1, '2026-04-28 18:37:21');
INSERT INTO `user` VALUES (18, 'wxcode_0c3RjsGa1vquDL06MwHa1rINKg4RjsGi', '微信用户', NULL, NULL, 1, '2026-04-28 18:37:41');
INSERT INTO `user` VALUES (19, 'wxcode_0c3cuWkl2PYACh4wmfml2mTchW3cuWkz', '微信用户', NULL, NULL, 1, '2026-04-28 18:37:55');
INSERT INTO `user` VALUES (20, 'wxcode_0b3QAull2e59Dh43GUll2uThmp3QAulB', '微信用户', NULL, NULL, 1, '2026-04-28 18:38:04');
INSERT INTO `user` VALUES (21, 'wxcode_0d3UQYZv3Ks0X63Nr20w3md3N33UQYZ0', '微信用户', NULL, NULL, 1, '2026-04-28 18:39:50');
INSERT INTO `user` VALUES (22, 'wxcode_0b35HyHa1DmAEL0ozNGa11lcCJ05HyHK', '微信用户', NULL, NULL, 1, '2026-04-28 18:40:37');
INSERT INTO `user` VALUES (23, 'wxcode_0e3NqHnl2RanFh48pAnl2Js1Y60NqHnI', '微信用户', NULL, NULL, 1, '2026-04-28 18:45:24');
INSERT INTO `user` VALUES (24, 'wxcode_0c3WeBml24ZgEh4SIill2esFCm2WeBmp', '微信用户', NULL, NULL, 1, '2026-04-28 18:45:28');
INSERT INTO `user` VALUES (25, 'wxcode_0f3zAO0w3LRPX63nvm1w3xjaRa1zAO0u', '微信用户', NULL, NULL, 1, '2026-04-28 18:49:30');
INSERT INTO `user` VALUES (26, 'wxcode_0e3UutGa1oSuDL0cqnHa1siWbB4UutGI', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:01');
INSERT INTO `user` VALUES (27, 'wxcode_0e3jvtGa1VTuDL0VR7Ja1HJWFF4jvtGA', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:06');
INSERT INTO `user` VALUES (28, 'wxcode_0c3jqVFa1AOWCL0kdqGa1LaeK62jqVFA', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:23');
INSERT INTO `user` VALUES (29, 'wxcode_0c3StcGa1ZNdDL03TiJa1ypJmz0StcGb', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:32');
INSERT INTO `user` VALUES (30, 'wxcode_0d3qxtGa1iRuDL05meHa1AiJsD4qxtGs', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:40');
INSERT INTO `user` VALUES (31, 'wxcode_0e3eToIa1ndqFL0UYjJa1e55C74eToIE', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:49');
INSERT INTO `user` VALUES (32, 'wxcode_0a3tmnFa1NLoCL0btNIa1bD25M3tmnFv', '微信用户', NULL, NULL, 1, '2026-04-28 18:57:58');
INSERT INTO `user` VALUES (33, 'wxcode_0d3gztGa1TYuDL0P4wFa1cdDnY0gztG5', '微信用户', NULL, NULL, 1, '2026-04-28 18:58:09');
INSERT INTO `user` VALUES (34, 'wxcode_0d3TAgol21DWFh4zsTol25plqD4TAgoq', '微信用户', NULL, NULL, 1, '2026-04-28 19:02:52');
INSERT INTO `user` VALUES (35, 'wxcode_0b3eavGa12YwDL0QqMGa18JWh90eavGl', '微信用户', NULL, NULL, 1, '2026-04-28 19:24:20');
INSERT INTO `user` VALUES (36, 'wxcode_0c3hw3Ha1Yc4EL0gH6Ia1d8G9w3hw3HC', '微信用户', NULL, NULL, 1, '2026-04-28 19:28:33');
INSERT INTO `user` VALUES (37, 'wxcode_0b3AFBHa1hvCEL0ho0Ja1eihTo2AFBHX', '微信用户', NULL, NULL, 1, '2026-04-28 19:29:25');
INSERT INTO `user` VALUES (38, 'wxcode_0c3XnXFa1pdYCL0oAjGa116TlE1XnXFE', '微信用户', NULL, NULL, 1, '2026-04-28 19:29:34');
INSERT INTO `user` VALUES (39, 'wxcode_0d3XCeGa19pfDL0lryFa1RfQ9B4XCeGu', '微信用户', NULL, NULL, 1, '2026-04-28 19:32:44');
INSERT INTO `user` VALUES (40, 'wxcode_0e3F8OGa12kODL0gz7Ha15SU4x0F8OGQ', '微信用户', NULL, NULL, 1, '2026-04-28 19:55:55');
INSERT INTO `user` VALUES (41, 'wxcode_0d3R3ZFa10gZCL0syAGa1z4uiC4R3ZF2', '微信用户', NULL, NULL, 1, '2026-04-28 19:57:03');
INSERT INTO `user` VALUES (42, 'wxcode_0d3mEKkl2FxnCh4MeAll2iem192mEKkm', '微信用户', NULL, NULL, 1, '2026-04-28 20:03:25');
INSERT INTO `user` VALUES (43, 'wxcode_0e3CaEHa1IaEEL0KfJHa1iSthZ2CaEH8', '微信用户', NULL, NULL, 1, '2026-04-28 20:10:26');
INSERT INTO `user` VALUES (44, 'wxcode_0d3gxC0w3E8qX63d7M1w3SCF0j4gxC00', '微信用户', NULL, NULL, 1, '2026-04-28 20:11:26');
INSERT INTO `user` VALUES (45, 'wxcode_0c3bbQFa1wYfCL0uPnGa1hevSS3bbQFT', '微信用户', NULL, NULL, 1, '2026-04-29 16:49:29');

SET FOREIGN_KEY_CHECKS = 1;
