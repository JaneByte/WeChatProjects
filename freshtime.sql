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

 Date: 27/04/2026 23:38:39
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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收货地址表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of address
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '购物车表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of cart
-- ----------------------------

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
INSERT INTO `goods` VALUES (1, 1, 11, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', NULL, NULL, 25.80, 32.80, 100, '斤', 892, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (2, 1, 11, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', NULL, NULL, 38.80, 45.80, 80, '盒', 456, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (3, 1, 11, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', NULL, NULL, 18.80, NULL, 150, '斤', 1024, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (4, 1, 12, '橙子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg', NULL, NULL, 8.80, 10.80, 300, '斤', 1567, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (5, 1, 12, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', NULL, NULL, 7.50, NULL, 250, '斤', 1024, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (6, 1, 12, '柠檬', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/柠檬.jpg', NULL, NULL, 6.80, 8.80, 180, '斤', 567, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (7, 1, 13, '西瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/西瓜.jpg', NULL, NULL, 3.80, NULL, 300, '斤', 1567, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (8, 1, 13, '哈密瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/哈密瓜.jpg', NULL, NULL, 8.80, 10.80, 150, '个', 678, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (9, 1, 13, '香瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/香瓜.jpg', NULL, NULL, 6.80, NULL, 120, '斤', 345, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (10, 1, 14, '水蜜桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/水蜜桃.jpg', NULL, NULL, 18.80, 22.80, 120, '斤', 678, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (11, 1, 14, '黑布李', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黑布李.jpg', NULL, NULL, 12.80, NULL, 150, '斤', 345, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (12, 1, 14, '樱桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/樱桃.jpg', NULL, NULL, 48.80, 58.80, 60, '斤', 234, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (13, 1, 15, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', NULL, NULL, 9.80, 12.80, 300, '斤', 2048, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (14, 1, 15, '皇冠梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/皇冠梨.jpg', NULL, NULL, 7.80, NULL, 250, '斤', 1024, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (15, 1, 15, '枇杷', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/枇杷.jpg', NULL, NULL, 8.80, 10.80, 180, '斤', 567, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (16, 1, 16, '菠萝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝.jpg', NULL, NULL, 12.80, 15.80, 100, '个', 678, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (17, 1, 16, '无花果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/无花果.jpg', NULL, NULL, 22.80, 28.80, 60, '斤', 234, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);
INSERT INTO `goods` VALUES (18, 1, 16, '桑葚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/桑葚.jpg', NULL, NULL, 15.80, NULL, 80, '盒', 345, 0, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', NULL, NULL);

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order_item
-- ----------------------------

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
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
