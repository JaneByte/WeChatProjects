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

 Date: 07/05/2026 16:26:46
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
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收货地址表' ROW_FORMAT = Compact;

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
INSERT INTO `address` VALUES (9, 51, '1', '12345678910', 'a', 'a', 'a', 'a', 0, '2026-05-02 16:38:17');
INSERT INTO `address` VALUES (11, 60, 'a', '12345678910', 'a', 'a', 's', 'f', 0, '2026-05-02 17:37:14');
INSERT INTO `address` VALUES (12, 66, '1', '12345678910', '1', '1', '1', '1', 0, '2026-05-02 17:52:49');
INSERT INTO `address` VALUES (13, 68, '1', '12345678909', '1', '1', 's', 'x', 0, '2026-05-02 18:11:28');

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
) ENGINE = InnoDB AUTO_INCREMENT = 25 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '购物车表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (4, 39, 3, 1, 1, 1, '2026-04-28 19:32:51');
INSERT INTO `cart` VALUES (7, 46, 5, 1, 1, 1, '2026-05-02 15:42:19');
INSERT INTO `cart` VALUES (13, 60, 1, 1, 1, 1, '2026-05-02 17:43:24');
INSERT INTO `cart` VALUES (14, 60, 3, 1, 1, 1, '2026-05-02 17:43:25');
INSERT INTO `cart` VALUES (15, 60, 2, 1, 1, 1, '2026-05-02 17:43:26');
INSERT INTO `cart` VALUES (16, 65, 1, 1, 1, 1, '2026-05-02 17:48:18');
INSERT INTO `cart` VALUES (17, 65, 3, 1, 1, 1, '2026-05-02 17:48:18');
INSERT INTO `cart` VALUES (24, 136, 2, 1, 1, 1, '2026-05-03 18:27:02');

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
INSERT INTO `goods` VALUES (1, 1, 11, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', NULL, NULL, 25.80, 32.80, 89, '斤', 903, 1, 0, NULL, NULL, NULL, 0, 3, 1, 1, '2026-04-26 23:44:33', '草莓,奶油草莓,浆果', '山东');
INSERT INTO `goods` VALUES (2, 1, 11, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', NULL, NULL, 38.80, 45.80, 74, '盒', 462, 0, 0, NULL, NULL, NULL, 0, 5, 1, 1, '2026-04-25 23:44:33', '蓝莓,浆果,护眼', '云南');
INSERT INTO `goods` VALUES (3, 1, 11, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', NULL, NULL, 18.80, NULL, 139, '斤', 1035, 1, 0, NULL, NULL, NULL, 0, 0, 1, 1, '2026-04-21 15:33:25', '葡萄,巨峰,多汁', '新疆');
INSERT INTO `goods` VALUES (4, 1, 12, '橙子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg', NULL, NULL, 8.80, 10.80, 300, '斤', 1567, 1, 0, NULL, NULL, NULL, 0, 2, 1, 1, '2026-04-26 23:44:33', '橙子,柑橘,维C', '江西');
INSERT INTO `goods` VALUES (5, 1, 12, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', NULL, NULL, 7.50, NULL, 247, '斤', 1027, 1, 1, 7.90, '2026-04-27 23:44:33', '2026-04-28 05:44:33', 22, 0, 1, 1, '2026-04-21 15:33:25', '丑橘,柑橘,果冻橙', '四川');
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
-- Table structure for home_nav
-- ----------------------------
DROP TABLE IF EXISTS `home_nav`;
CREATE TABLE `home_nav`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '快捷入口ID',
  `nav_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入口标识',
  `nav_text` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入口文案',
  `icon_text` varchar(8) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '入口图标文字',
  `link_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'goods' COMMENT '跳转类型：goods/search/category/url/goodsDetail',
  `link_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '跳转值',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '首页快捷入口表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of home_nav
-- ----------------------------
INSERT INTO `home_nav` VALUES (1, 'seasonal', '时令优选', '时', 'goods', 'seasonal', 1, 1, '2026-05-03 15:53:16');
INSERT INTO `home_nav` VALUES (2, 'hot', '热销爆款', '热', 'goods', 'hot', 2, 1, '2026-05-03 15:53:16');
INSERT INTO `home_nav` VALUES (3, 'flash', '限时秒杀', '秒', 'goods', 'flash', 3, 1, '2026-05-03 15:53:16');
INSERT INTO `home_nav` VALUES (4, 'category', '全部分类', '类', 'category', 'category', 4, 1, '2026-05-03 15:53:16');

-- ----------------------------
-- Table structure for home_notice
-- ----------------------------
DROP TABLE IF EXISTS `home_notice`;
CREATE TABLE `home_notice`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '公告ID',
  `notice_text` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '公告文案',
  `link_type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'none' COMMENT '跳转类型：none/goods/search/category/url/goodsDetail',
  `link_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '跳转值',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '首页公告表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of home_notice
-- ----------------------------
INSERT INTO `home_notice` VALUES (1, '今日上新优先发货，最快次日达', 'none', '', 1, 1, '2026-05-03 15:53:16');
INSERT INTO `home_notice` VALUES (2, '限时秒杀库存有限，先到先得', 'goods', 'flash', 2, 1, '2026-05-03 15:53:16');

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
  `coupon_id` bigint(20) NULL DEFAULT NULL COMMENT '使用优惠券ID',
  `status` tinyint(4) NOT NULL COMMENT '状态 0待付款 1待发货 2待收货 3已完成 4已取消 5已退款 6退款中',
  `pay_channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '支付渠道（mock_wechat）',
  `pay_trade_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '模拟支付交易号',
  `pay_status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '支付状态 0未发起 1待确认 2已支付',
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
) ENGINE = InnoDB AUTO_INCREMENT = 23 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES (1, 'FT1777360002250A4A5D0', 1, 1, 32.60, 0.00, 32.60, '默认收货人', '13800000000', '默认收货地址', NULL, NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-04-28 15:06:42');
INSERT INTO `order` VALUES (2, 'FT17773600348125CAA4B', 1, 1, 26.30, 0.00, 26.30, '默认收货人', '13800000000', '默认收货地址', NULL, NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-04-28 15:07:14');
INSERT INTO `order` VALUES (3, 'FT177736021698855D2E1', 1, 1, 61.40, 0.00, 61.40, '默认收货人', '13800000000', '默认收货地址', NULL, NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-04-28 15:10:16');
INSERT INTO `order` VALUES (4, 'FT17773607735249F833F', 1, 1, 47.60, 0.00, 47.60, '默认收货人', '13800000000', '默认收货地址', NULL, NULL, 4, NULL, NULL, 0, '2026-04-28 15:19:37', NULL, NULL, NULL, '2026-04-28 15:19:33');
INSERT INTO `order` VALUES (5, 'FT1777361007976374D76', 1, 1, 44.60, 0.00, 44.60, '默认收货人', '13800000000', '默认收货地址', NULL, NULL, 3, 'mock_wechat', 'MOCK17773610075', 2, '2026-04-28 15:23:30', '2026-04-28 15:23:32', NULL, NULL, '2026-04-28 15:23:27');
INSERT INTO `order` VALUES (6, 'FT17773617211284CAFD3', 2, 1, 25.80, 0.00, 25.80, '默认收货人', '13800000000', '默认收货地址', NULL, NULL, 3, 'mock_wechat', 'MOCK17773617216', 2, '2026-04-28 15:35:22', '2026-04-28 15:35:23', NULL, NULL, '2026-04-28 15:35:21');
INSERT INTO `order` VALUES (7, 'FT1777364541652D0D827', 2, 1, 25.80, 0.00, 25.80, '陈女士', '123456', '湖南省长沙天心区中南林业科技大学', NULL, NULL, 3, 'mock_wechat', 'MOCK17773645417', 2, '2026-04-28 16:22:30', '2026-04-28 16:23:17', NULL, NULL, '2026-04-28 16:22:21');
INSERT INTO `order` VALUES (8, 'FT1777364771407C062B3', 3693519, 1, 48.60, 0.00, 48.60, 'jiannvshi', '123', 'qaa1', NULL, NULL, 3, 'mock_wechat', 'MOCK17773647718', 2, '2026-04-28 16:26:26', '2026-04-28 16:26:33', NULL, NULL, '2026-04-28 16:26:11');
INSERT INTO `order` VALUES (9, 'FT1777372943976293DFC', 22, 1, 36.40, 0.00, 36.40, 'abc', '12345678910', '北京市海淀区axxxx', '配送到家', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-04-28 18:42:23');
INSERT INTO `order` VALUES (10, 'FT17773729701201DC438', 22, 1, 6.80, 0.00, 6.80, 'abc', '12345678910', '北京市海淀区axxxx', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-04-28 18:42:50');
INSERT INTO `order` VALUES (11, 'FT17773734250435E781A', 25, 1, 37.60, 0.00, 37.60, 'a', '18229656601', 'axxavbciii', '快速送达', NULL, 3, 'mock_wechat', 'MOCK177737342511', 2, '2026-04-28 18:50:46', '2026-04-28 18:50:57', NULL, NULL, '2026-04-28 18:50:25');
INSERT INTO `order` VALUES (12, 'FT177737398888747CF65', 33, 1, 18.80, 0.00, 18.80, 'a', '12345678910', 'aaaa', '', NULL, 4, NULL, NULL, 0, '2026-04-28 19:00:02', NULL, NULL, NULL, '2026-04-28 18:59:48');
INSERT INTO `order` VALUES (13, 'FT1777374063650114FAB', 33, 1, 18.80, 0.00, 18.80, 'a', '12345678910', 'aaaa', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-04-28 19:01:03');
INSERT INTO `order` VALUES (14, 'FT1777377545303F093F1', 41, 1, 7.50, 0.00, 7.50, 'a', '12345678910', 'aaaa', '', NULL, 1, 'mock_wechat', 'MOCK177737754514', 2, '2026-04-28 19:59:11', NULL, NULL, NULL, '2026-04-28 19:59:05');
INSERT INTO `order` VALUES (15, 'FT1777377605751C0E3E5', 41, 1, 63.20, 0.00, 63.20, 'a', '12345678910', 'aaaa', '', NULL, 1, 'mock_wechat', 'MOCK177737760515', 2, '2026-04-28 20:00:10', NULL, NULL, NULL, '2026-04-28 20:00:05');
INSERT INTO `order` VALUES (16, 'FT1777452869015566591', 45, 1, 18.80, 0.00, 18.80, 'a', '12345678910', 'aaaa', '', NULL, 1, 'mock_wechat', 'MOCK177745286916', 2, '2026-04-29 16:54:51', NULL, NULL, NULL, '2026-04-29 16:54:29');
INSERT INTO `order` VALUES (17, 'FT177771110012930F1D9', 51, 1, 7.50, 0.00, 7.50, '1', '12345678910', 'aaaa', '', NULL, 1, 'mock_wechat', 'MOCK17777111001732CBD293C', 2, '2026-05-02 16:38:20', NULL, NULL, NULL, '2026-05-02 16:38:20');
INSERT INTO `order` VALUES (19, 'FT17777146405748499AC', 60, 1, 25.80, 0.00, 25.80, 'a', '12345678910', 'aasf', '', NULL, 1, 'mock_wechat', 'MOCK1777714640616814C0913', 2, '2026-05-02 17:37:20', NULL, NULL, NULL, '2026-05-02 17:37:20');
INSERT INTO `order` VALUES (20, 'FT1777714995557072313', 60, 1, 64.60, 0.00, 64.60, 'a', '12345678910', 'aasf', '', NULL, 4, 'mock_wechat', 'MOCK177771499560266D9F595', 2, '2026-05-02 17:43:15', NULL, NULL, NULL, '2026-05-02 17:43:15');
INSERT INTO `order` VALUES (21, 'FT17777155968477A16A3', 66, 1, 83.40, 8.00, 75.40, '1', '12345678910', '1111', '', NULL, 6, 'mock_wechat', 'MOCK1777715596875CD01CC67', 2, '2026-05-02 17:53:16', NULL, NULL, NULL, '2026-05-02 17:53:16');
INSERT INTO `order` VALUES (22, 'FT1777716700709E41306', 68, 1, 83.40, 8.00, 75.40, '1', '12345678909', '11sx', '', NULL, 1, 'mock_wechat', 'MOCK17777167007423EE796E2', 2, '2026-05-02 18:11:40', NULL, NULL, NULL, '2026-05-02 18:11:40');

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
) ENGINE = InnoDB AUTO_INCREMENT = 36 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = Compact;

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
INSERT INTO `order_item` VALUES (25, 17, 5, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', 7.50, 1, 7.50);
INSERT INTO `order_item` VALUES (27, 19, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (28, 20, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (29, 20, 2, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', 38.80, 1, 38.80);
INSERT INTO `order_item` VALUES (30, 21, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (31, 21, 2, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', 38.80, 1, 38.80);
INSERT INTO `order_item` VALUES (32, 21, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);
INSERT INTO `order_item` VALUES (33, 22, 1, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', 25.80, 1, 25.80);
INSERT INTO `order_item` VALUES (34, 22, 2, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', 38.80, 1, 38.80);
INSERT INTO `order_item` VALUES (35, 22, 3, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', 18.80, 1, 18.80);

-- ----------------------------
-- Table structure for service_faq
-- ----------------------------
DROP TABLE IF EXISTS `service_faq`;
CREATE TABLE `service_faq`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT 'FAQ ID',
  `question` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '问题',
  `answer` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '回答',
  `sort` int(11) NOT NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '客服常见问题表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of service_faq
-- ----------------------------
INSERT INTO `service_faq` VALUES (1, '配送多久可以送达？', '默认当日或次日送达，具体以下单页为准。', 1, 1, '2026-05-02 15:38:31');
INSERT INTO `service_faq` VALUES (2, '商品不新鲜怎么办？', '签收后24小时内可在订单页申请售后。', 2, 1, '2026-05-02 15:38:31');
INSERT INTO `service_faq` VALUES (3, '如何联系客服？', '你可以拨打 400-888-1024（9:00-21:00）。', 3, 1, '2026-05-02 15:38:31');

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
-- Table structure for trace_record
-- ----------------------------
DROP TABLE IF EXISTS `trace_record`;
CREATE TABLE `trace_record`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '溯源记录ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `origin_card_id` bigint(20) NOT NULL COMMENT '产地卡片ID',
  `location` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '产地位置',
  `harvest_date` date NOT NULL COMMENT '采收日期',
  `batch_no` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '质检批次号',
  `cold_chain_status` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '冷链状态',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品溯源记录表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of trace_record
-- ----------------------------
INSERT INTO `trace_record` VALUES (1, 3, 2, '云南红河', '2026-04-28', 'FT-TRACE-260428-003', '全程冷链在途', 1, '2026-05-02 15:38:31');
INSERT INTO `trace_record` VALUES (2, 13, 1, '山东烟台', '2026-04-27', 'FT-TRACE-260427-013', '冷库待配货', 1, '2026-05-02 15:38:31');
INSERT INTO `trace_record` VALUES (3, 5, 3, '海南乐东', '2026-04-29', 'FT-TRACE-260429-005', '冷链已签收', 1, '2026-05-02 15:38:31');

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
) ENGINE = InnoDB AUTO_INCREMENT = 149 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Compact;

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
INSERT INTO `user` VALUES (46, 'wxcode_0b3zOEkl2mtFDh4ahmll2J3RPQ1zOEkt', '微信用户', NULL, NULL, 1, '2026-05-02 15:40:07');
INSERT INTO `user` VALUES (47, 'wxcode_0d3Ne0Ha1xybDL06ugGa1NafhU1Ne0Hy', '微信用户', NULL, NULL, 1, '2026-05-02 15:47:08');
INSERT INTO `user` VALUES (48, 'wxcode_0a3Nu2ml2jhiCh4d9col2lQJGc0Nu2mE', '微信用户', NULL, NULL, 1, '2026-05-02 15:47:17');
INSERT INTO `user` VALUES (49, 'wxcode_0c3LERml2loRFh4uaHol2JryAE4LERmV', '微信用户', NULL, NULL, 1, '2026-05-02 15:47:30');
INSERT INTO `user` VALUES (50, 'wxcode_0d3bAYZv3BJlY63Hno3w3Nlost2bAYZ9', '微信用户', NULL, NULL, 1, '2026-05-02 15:47:49');
INSERT INTO `user` VALUES (51, 'wxcode_0d3cA10w3R0sY63MEc1w3okbN33cA10s', '微信用户', NULL, NULL, 1, '2026-05-02 16:37:01');
INSERT INTO `user` VALUES (52, 'wxcode_0b3WPf2w3q8D0736lx3w3089Fe2WPf2U', '微信用户', NULL, NULL, 1, '2026-05-02 17:07:34');
INSERT INTO `user` VALUES (53, 'wxcode_0b3n4xGa1MUHCL0vqvJa1juE3P2n4xGJ', '微信用户', NULL, NULL, 1, '2026-05-02 17:07:59');
INSERT INTO `user` VALUES (54, 'wxcode_0f3SWHFa1FVwDL0NroFa1YJAZW2SWHFJ', '微信用户', NULL, NULL, 1, '2026-05-02 17:08:25');
INSERT INTO `user` VALUES (55, 'wxcode_0e3vVqFa1K0ODL0Jd2Ha1Raalu4vVqFp', '微信用户', NULL, NULL, 1, '2026-05-02 17:08:51');
INSERT INTO `user` VALUES (56, 'wxcode_0d3icOGa17MqCL0dl0Ha1WcJDI3icOGa', '微信用户', NULL, NULL, 1, '2026-05-02 17:09:17');
INSERT INTO `user` VALUES (57, 'wxcode_0e3h5l0w39k8Y63InD2w3dHSxn4h5l0H', '微信用户', NULL, NULL, 1, '2026-05-02 17:17:14');
INSERT INTO `user` VALUES (58, 'wxcode_0e3gf0Ga1A9dEL0Q4SHa1YfMcN3gf0GK', '微信用户', NULL, NULL, 1, '2026-05-02 17:28:52');
INSERT INTO `user` VALUES (59, 'wxcode_0e3LMnHa1YkQCL0JmwIa1hTF7p0LMnHl', '微信用户', NULL, NULL, 1, '2026-05-02 17:33:43');
INSERT INTO `user` VALUES (60, 'wxcode_0c3zHPGa1oaiCL0gVDIa1JoWWD0zHPGO', '微信用户', NULL, NULL, 1, '2026-05-02 17:33:57');
INSERT INTO `user` VALUES (61, 'wxcode_0b3gCJFa1AtoDL06MCFa1saRo03gCJF5', '微信用户', NULL, NULL, 1, '2026-05-02 17:35:46');
INSERT INTO `user` VALUES (62, 'wxcode_0d3wtD0w3pOPY63czV1w3wPjnE1wtD0G', '微信用户', NULL, NULL, 1, '2026-05-02 17:39:15');
INSERT INTO `user` VALUES (63, 'wxcode_0f3bpQGa1CDiCL0qwHHa1tk82N0bpQGa', '微信用户', NULL, NULL, 1, '2026-05-02 17:45:29');
INSERT INTO `user` VALUES (64, 'wxcode_0b3xw3ll2eJkDh4Todll23fFA30xw3l3', '微信用户', NULL, NULL, 1, '2026-05-02 17:45:45');
INSERT INTO `user` VALUES (65, 'wxcode_0f3XB7Ha15u8DL0e3MFa1TlXwA0XB7Hy', '微信用户', NULL, NULL, 1, '2026-05-02 17:48:04');
INSERT INTO `user` VALUES (66, 'wxcode_0a3ZTFHa1f3SFL0bqcJa1n8waO0ZTFHL', '微信用户', NULL, NULL, 1, '2026-05-02 17:51:14');
INSERT INTO `user` VALUES (67, 'wxcode_0f3Cnd1w39qdX636pD3w3Grp6W0Cnd1F', '微信用户', NULL, NULL, 1, '2026-05-02 18:08:53');
INSERT INTO `user` VALUES (68, 'wxcode_0c3lcUll2TRwCh4yl1ll2PBux13lcUlP', '微信用户', NULL, NULL, 1, '2026-05-02 18:10:48');
INSERT INTO `user` VALUES (69, 'wxcode_0f3o6MFa1YKrDL0a7LGa1CHIhl4o6MF7', '微信用户', NULL, NULL, 1, '2026-05-02 18:16:32');
INSERT INTO `user` VALUES (70, 'wxcode_0e3ASBGa165BCL0OYMHa1sWaaz2ASBG9', '微信用户', NULL, NULL, 1, '2026-05-02 18:26:52');
INSERT INTO `user` VALUES (71, 'wxcode_0a3gQvFa12FHDL0rXHGa1O7xdD1gQvFI', '微信用户', NULL, NULL, 1, '2026-05-02 18:29:28');
INSERT INTO `user` VALUES (72, 'wxcode_0b3YvaHa1tn3DL0fnDJa1SWkwF1YvaHX', '微信用户', NULL, NULL, 1, '2026-05-02 18:35:41');
INSERT INTO `user` VALUES (73, 'wxcode_0c3F2Mml2vQHCh4KdOnl2RmEsc2F2Mmy', '微信用户', NULL, NULL, 1, '2026-05-02 18:55:02');
INSERT INTO `user` VALUES (74, 'wxcode_0d365a0w3GNdY63Bw52w3eX2XU065a0m', '微信用户', NULL, NULL, 1, '2026-05-02 18:56:24');
INSERT INTO `user` VALUES (75, 'wxcode_0b3E6vml2RYYCh4UoPml2CVMco3E6vmX', '微信用户', NULL, NULL, 1, '2026-05-02 18:56:54');
INSERT INTO `user` VALUES (76, 'wxcode_0c34Y7ll2gdgDh4HfNll20Axks24Y7ls', '微信用户', NULL, NULL, 1, '2026-05-02 18:58:38');
INSERT INTO `user` VALUES (77, 'wxcode_0b3YbGkl2LjJDh46Lgol2JvzZs1YbGkD', '微信用户', NULL, NULL, 1, '2026-05-02 20:42:19');
INSERT INTO `user` VALUES (78, 'wxcode_0a373VFa1I8wDL05H1Ia1qdF9V373VFe', '微信用户', NULL, NULL, 1, '2026-05-03 15:21:45');
INSERT INTO `user` VALUES (79, 'wxcode_0a3HqEFa1TulEL0f8ZFa1sZLGF4HqEF-', '微信用户', NULL, NULL, 1, '2026-05-03 15:28:47');
INSERT INTO `user` VALUES (80, 'wxcode_0e3uMiHa1boHCL0vzqGa1h7tZv0uMiHX', '微信用户', NULL, NULL, 1, '2026-05-03 15:29:44');
INSERT INTO `user` VALUES (81, 'wxcode_0f31DnFa1eP3EL0MfGIa1APwt421DnF5', '微信用户', NULL, NULL, 1, '2026-05-03 15:32:51');
INSERT INTO `user` VALUES (82, 'wxcode_0c3rQWFa1FXuDL07qzHa1SgzkO3rQWFk', '微信用户', NULL, NULL, 1, '2026-05-03 15:51:12');
INSERT INTO `user` VALUES (83, 'wxcode_0d3ORWFa1sLuDL0koiHa1VUYyd2ORWFL', '微信用户', NULL, NULL, 1, '2026-05-03 15:51:34');
INSERT INTO `user` VALUES (84, 'wxcode_0f3hl5ml24A9Dh4AOgnl2Y1wMp4hl5m6', '微信用户', NULL, NULL, 1, '2026-05-03 15:52:03');
INSERT INTO `user` VALUES (85, 'wxcode_0d3GBIkl2cmaEh4O9hol2Ve1a00GBIkS', '微信用户', NULL, NULL, 1, '2026-05-03 16:00:24');
INSERT INTO `user` VALUES (86, 'wxcode_0d3K6hll2pLCDh4IUGnl2nKhuP3K6hlm', '微信用户', NULL, NULL, 1, '2026-05-03 16:07:01');
INSERT INTO `user` VALUES (87, 'wxcode_0b3D3NGa1EMRCL0naGJa1oaIcj2D3NGk', '微信用户', NULL, NULL, 1, '2026-05-03 16:08:41');
INSERT INTO `user` VALUES (88, 'wxcode_0d3WowGa13R8DL0q77Ia1bUmjn1WowGG', '微信用户', NULL, NULL, 1, '2026-05-03 16:15:07');
INSERT INTO `user` VALUES (89, 'wxcode_0e3wtHFa1HOYDL03g8Ga1XyN2P2wtHF9', '微信用户', NULL, NULL, 1, '2026-05-03 16:18:44');
INSERT INTO `user` VALUES (90, 'wxcode_0b3CN0ll2KGUDh4tWmll29iE1o0CN0lp', '微信用户', NULL, NULL, 1, '2026-05-03 16:19:10');
INSERT INTO `user` VALUES (91, 'wxcode_0d3gc2ll2JsWDh4ZoMll2xGjo03gc2lC', '微信用户', NULL, NULL, 1, '2026-05-03 16:42:04');
INSERT INTO `user` VALUES (92, 'wxcode_0b3RrAll2DeoDh4gRBol2m0iDG1RrAlp', '微信用户', NULL, NULL, 1, '2026-05-03 16:44:36');
INSERT INTO `user` VALUES (93, 'wxcode_0f39lLkl2XndEh4mBInl2wFDqc29lLkB', '微信用户', NULL, NULL, 1, '2026-05-03 16:45:14');
INSERT INTO `user` VALUES (94, 'wxcode_0c3Xp2ll2VlWDh4Ax5ol2uNPOT0Xp2lA', '微信用户', NULL, NULL, 1, '2026-05-03 16:45:42');
INSERT INTO `user` VALUES (95, 'wxcode_0b34BRll2YE7Dh4b8wnl2DsoXZ14BRl0', '微信用户', NULL, NULL, 1, '2026-05-03 16:46:14');
INSERT INTO `user` VALUES (96, 'wxcode_0d3huPGa1rBUCL02dQHa1CtRCf4huPGk', '微信用户', NULL, NULL, 1, '2026-05-03 16:48:32');
INSERT INTO `user` VALUES (97, 'wxcode_0f3KD2ll21wWDh45Wrnl2J4nOz1KD2lI', '微信用户', NULL, NULL, 1, '2026-05-03 16:49:21');
INSERT INTO `user` VALUES (98, 'wxcode_0a3pmsFa1DdhEL0D0ZGa1CZ09a2pmsFU', '微信用户', NULL, NULL, 1, '2026-05-03 16:50:27');
INSERT INTO `user` VALUES (99, 'wxcode_0c3YnsFa11dhEL06AXGa1dpNJR3YnsFq', '微信用户', NULL, NULL, 1, '2026-05-03 16:50:52');
INSERT INTO `user` VALUES (100, 'wxcode_0e3NKhGa12esDL09R3Ga1kCu3l1NKhGl', '微信用户', NULL, NULL, 1, '2026-05-03 16:54:30');
INSERT INTO `user` VALUES (101, 'wxcode_0c35HJFa13YZDL085kHa1WqTbm15HJFW', '微信用户', NULL, NULL, 1, '2026-05-03 16:55:08');
INSERT INTO `user` VALUES (102, 'wxcode_0b3kikll2FKGDh4qaGnl2dkDD74kikls', '微信用户', NULL, NULL, 1, '2026-05-03 16:59:17');
INSERT INTO `user` VALUES (103, 'wxcode_0a3131Ga1NRKDL07IEHa1qwRiC4131G7', '微信用户', NULL, NULL, 1, '2026-05-03 17:00:08');
INSERT INTO `user` VALUES (104, 'wxcode_0c3EJm0w3jmEY63cSL1w3HyCJg4EJm0h', '微信用户', NULL, NULL, 1, '2026-05-03 17:02:24');
INSERT INTO `user` VALUES (105, 'wxcode_0c3OjzGa1OEcDL03z1Ia1hCpu64OjzGP', '微信用户', NULL, NULL, 1, '2026-05-03 17:02:58');
INSERT INTO `user` VALUES (106, 'wxcode_0a3CAkll2jxGDh462Xnl2zOC2A4CAklG', '微信用户', NULL, NULL, 1, '2026-05-03 17:04:07');
INSERT INTO `user` VALUES (107, 'wxcode_0b3qgV0w3725Y63CJ31w3hPznp3qgV0j', '微信用户', NULL, NULL, 1, '2026-05-03 17:09:31');
INSERT INTO `user` VALUES (108, 'wxcode_0b3TVFHa1JVtGL0nGRGa18Uk7n3TVFH7', '微信用户', NULL, NULL, 1, '2026-05-03 17:09:50');
INSERT INTO `user` VALUES (109, 'wxcode_0e3ZT7Ha1drDCL0J01Ja1imfES0ZT7Hu', '微信用户', NULL, NULL, 1, '2026-05-03 17:10:56');
INSERT INTO `user` VALUES (110, 'wxcode_0c3uGIml2oVkCh4yzwol2neCV21uGImJ', '微信用户', NULL, NULL, 1, '2026-05-03 17:18:04');
INSERT INTO `user` VALUES (111, 'wxcode_0a3lWt1w31zzX63dUk3w3UCoU72lWt1j', '微信用户', NULL, NULL, 1, '2026-05-03 17:18:59');
INSERT INTO `user` VALUES (112, 'wxcode_0d3YXn0w3y6GY63TwV3w3ZFygU1YXn02', '微信用户', NULL, NULL, 1, '2026-05-03 17:22:36');
INSERT INTO `user` VALUES (113, 'wxcode_0a3zBRGa1L1XCL0CMmJa1Ietjg3zBRG9', '微信用户', NULL, NULL, 1, '2026-05-03 17:23:16');
INSERT INTO `user` VALUES (114, 'wxcode_0e3d3o0w3vSFY63xwV0w3Q9Zmp3d3o0I', '微信用户', NULL, NULL, 1, '2026-05-03 17:23:59');
INSERT INTO `user` VALUES (115, 'wxcode_0c3wz2Ga1ghMDL0sfEGa11DE412wz2Gb', '微信用户', NULL, NULL, 1, '2026-05-03 17:25:07');
INSERT INTO `user` VALUES (116, 'wxcode_0f3kTlll23MIDh4Qzvll2LSsS72kTlli', '微信用户', NULL, NULL, 1, '2026-05-03 17:25:28');
INSERT INTO `user` VALUES (117, 'wxcode_0f3OkW0w3Lt8Y633Sj0w3ltmig3OkW0I', '微信用户', NULL, NULL, 1, '2026-05-03 17:27:02');
INSERT INTO `user` VALUES (118, 'wxcode_0e3o2HHa1myxGL0FqKHa1JmKEw4o2HHL', '微信用户', NULL, NULL, 1, '2026-05-03 17:27:57');
INSERT INTO `user` VALUES (119, 'wxcode_0e3I85ll2NAZDh4VHhll23bLU43I85lv', '微信用户', NULL, NULL, 1, '2026-05-03 17:30:20');
INSERT INTO `user` VALUES (120, 'wxcode_0d3sjfIa141ZFL0YsdGa1TGCzC2sjfIX', '微信用户', NULL, NULL, 1, '2026-05-03 17:30:52');
INSERT INTO `user` VALUES (121, 'wxcode_0d3P0MFa1pI3EL0sBMFa1Y3r7x0P0MFn', '微信用户', NULL, NULL, 1, '2026-05-03 17:33:09');
INSERT INTO `user` VALUES (122, 'wxcode_0b3qqOkl2ksfEh4m8wnl2FZk092qqOk5', '微信用户', NULL, NULL, 1, '2026-05-03 17:35:50');
INSERT INTO `user` VALUES (123, 'wxcode_0d3GfvFa1BojEL0SEEIa11KbWj1GfvFA', '微信用户', NULL, NULL, 1, '2026-05-03 17:37:53');
INSERT INTO `user` VALUES (124, 'wxcode_0f3Bp3Ga1CdLDL0WqgGa1MTv4W0Bp3G6', '微信用户', NULL, NULL, 1, '2026-05-03 17:38:54');
INSERT INTO `user` VALUES (125, 'wxcode_0e3KBkGa1pTuDL0PXJHa1HfgBJ0KBkGt', '微信用户', NULL, NULL, 1, '2026-05-03 17:41:19');
INSERT INTO `user` VALUES (126, 'wxcode_0e3o1cml2kHSCh4bwiol2tbmLb3o1cmF', '微信用户', NULL, NULL, 1, '2026-05-03 17:41:36');
INSERT INTO `user` VALUES (127, 'wxcode_0e3iGX0w3C27Y633mS1w3TGeIe2iGX0s', '微信用户', NULL, NULL, 1, '2026-05-03 17:49:07');
INSERT INTO `user` VALUES (128, 'wxcode_0c3k6q0w3DrIY638sQ2w3Hlcaa2k6q0S', '微信用户', NULL, NULL, 1, '2026-05-03 17:57:37');
INSERT INTO `user` VALUES (129, 'wxcode_0f3GUCGa1cngDL0S7HFa1t1uco3GUCGE', '微信用户', NULL, NULL, 1, '2026-05-03 18:01:55');
INSERT INTO `user` VALUES (130, 'wxcode_0a3aUlGa1KAxDL0mXCFa1dhBQB3aUlGn', '微信用户', NULL, NULL, 1, '2026-05-03 18:02:35');
INSERT INTO `user` VALUES (131, 'wxcode_0d3F1UGa1JuZCL0tPnIa1W2K5E3F1UGJ', '微信用户', NULL, NULL, 1, '2026-05-03 18:02:58');
INSERT INTO `user` VALUES (132, 'wxcode_0c3EhDGa1KagDL0h7EHa1l9ere4EhDG2', '微信用户', NULL, NULL, 1, '2026-05-03 18:08:00');
INSERT INTO `user` VALUES (133, 'wxcode_0e3jAoll2qXJDh4Id0ll20Z3OE2jAolf', '微信用户', NULL, NULL, 1, '2026-05-03 18:09:38');
INSERT INTO `user` VALUES (134, 'wxcode_0b3yColl20WJDh4ImCol29HJDm2yCol2', '微信用户', NULL, NULL, 1, '2026-05-03 18:10:14');
INSERT INTO `user` VALUES (135, 'wxcode_0c3TR7ll2HC3Eh4TQCml2EqZV43TR7lT', '微信用户', NULL, NULL, 1, '2026-05-03 18:15:05');
INSERT INTO `user` VALUES (136, 'wxcode_0a39yXll2t8fDh4cXVml2AMVcc49yXld', '微信用户', NULL, NULL, 1, '2026-05-03 18:23:52');
INSERT INTO `user` VALUES (137, 'wxcode_0c3nvPFa1Oa4EL0ZXBFa1QaHwA0nvPFC', '微信用户', NULL, NULL, 1, '2026-05-03 18:30:26');
INSERT INTO `user` VALUES (138, 'wxcode_0f3p2fml26nUCh4p3aml2weH6O0p2fmb', '微信用户', NULL, NULL, 1, '2026-05-03 18:31:04');
INSERT INTO `user` VALUES (139, 'wxcode_0e3jHs0w3HrHY633xF3w3SXf6n3jHs07', '微信用户', NULL, NULL, 1, '2026-05-03 18:40:12');
INSERT INTO `user` VALUES (140, 'wxcode_0a3OL2Ia187iGL0r1uGa13v87C1OL2IU', '微信用户', NULL, NULL, 1, '2026-05-03 18:44:46');
INSERT INTO `user` VALUES (141, 'wxcode_0b3zQYll2cncDh4YBkml224cp03zQYlw', '微信用户', NULL, NULL, 1, '2026-05-03 18:45:08');
INSERT INTO `user` VALUES (142, 'wxcode_0e35ZHll2bitDh47qDnl2CuzLl05ZHlm', '微信用户', NULL, NULL, 1, '2026-05-03 18:48:12');
INSERT INTO `user` VALUES (143, 'wxcode_0c3XToGa1NayDL0nj4Ja1sUkqw1XToGL', '微信用户', NULL, NULL, 1, '2026-05-03 18:51:44');
INSERT INTO `user` VALUES (144, 'wxcode_0a3drZll210cDh4nFanl2UH6Jx4drZlG', '微信用户', NULL, NULL, 1, '2026-05-03 18:54:50');
INSERT INTO `user` VALUES (145, 'wxcode_0c33oSkl2YRCFh4P5Wml2ALeq713oSkF', '微信用户', NULL, NULL, 1, '2026-05-07 15:53:14');
INSERT INTO `user` VALUES (146, 'wxcode_0d3emzFa1mHHFL0pwKHa1tTvxC2emzFZ', '微信用户', NULL, NULL, 1, '2026-05-07 15:57:39');
INSERT INTO `user` VALUES (147, 'wxcode_0d3XIWGa1bxSEL0mz9Ja1UDh6E3XIWGu', '微信用户', NULL, NULL, 1, '2026-05-07 15:59:38');
INSERT INTO `user` VALUES (148, 'wxcode_0a38Z7Ga1VsgGL0G4pIa1LAiYv08Z7G7', '微信用户', NULL, NULL, 1, '2026-05-07 16:06:20');

-- ----------------------------
-- Table structure for user_coupon
-- ----------------------------
DROP TABLE IF EXISTS `user_coupon`;
CREATE TABLE `user_coupon`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '用户券ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '优惠券标题',
  `condition_text` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '使用条件文案',
  `threshold_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '使用门槛金额',
  `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `expire_date` date NOT NULL COMMENT '到期日期',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0失效 1可用 2已使用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 298 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户优惠券表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user_coupon
-- ----------------------------
INSERT INTO `user_coupon` VALUES (1, 1, '满50减8', '全场可用', 50.00, 8.00, '2026-05-31', 1, '2026-05-02 15:38:31');
INSERT INTO `user_coupon` VALUES (2, 1, '满99减15', '生鲜专区', 99.00, 15.00, '2026-06-15', 1, '2026-05-02 15:38:31');
INSERT INTO `user_coupon` VALUES (3, 2, '满39减5', '全场可用', 39.00, 5.00, '2026-05-20', 1, '2026-05-02 15:38:31');
INSERT INTO `user_coupon` VALUES (4, 61, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:38:20');
INSERT INTO `user_coupon` VALUES (5, 61, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:38:20');
INSERT INTO `user_coupon` VALUES (6, 17, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (7, 14, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (8, 1, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (9, 48, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (10, 32, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (11, 6, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (12, 22, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (13, 37, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (14, 2, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (15, 35, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (16, 61, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (17, 53, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (18, 4, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (19, 20, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (20, 3, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (21, 52, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (22, 46, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (23, 8, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (24, 45, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (25, 19, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (26, 36, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (27, 28, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (28, 49, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (29, 18, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (30, 29, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (31, 24, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (32, 38, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (33, 60, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (34, 50, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (35, 11, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (36, 51, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (37, 7, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (38, 44, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (39, 33, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (40, 56, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (41, 42, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (42, 47, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (43, 30, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (44, 41, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (45, 10, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (46, 34, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (47, 12, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (48, 21, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (49, 62, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (50, 39, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (51, 15, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (52, 43, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (53, 31, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (54, 40, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (55, 58, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (56, 5, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (57, 57, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (58, 27, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (59, 59, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (60, 23, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (61, 9, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (62, 26, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (63, 55, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (64, 13, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (65, 16, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (66, 54, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (67, 25, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (69, 17, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (70, 14, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (71, 1, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (72, 48, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (73, 32, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (74, 6, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (75, 22, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (76, 37, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (77, 2, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (78, 35, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (79, 61, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (80, 53, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (81, 4, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (82, 20, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (83, 3, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (84, 52, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (85, 46, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (86, 8, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (87, 45, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (88, 19, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (89, 36, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (90, 28, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (91, 49, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (92, 18, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (93, 29, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (94, 24, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (95, 38, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (96, 60, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (97, 50, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (98, 11, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (99, 51, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (100, 7, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (101, 44, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (102, 33, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (103, 56, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (104, 42, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (105, 47, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (106, 30, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (107, 41, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (108, 10, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (109, 34, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (110, 12, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (111, 21, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (112, 62, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (113, 39, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (114, 15, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (115, 43, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (116, 31, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (117, 40, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (118, 58, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (119, 5, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (120, 57, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (121, 27, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (122, 59, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (123, 23, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (124, 9, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (125, 26, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (126, 55, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (127, 13, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (128, 16, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (129, 54, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (130, 25, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:41:37');
INSERT INTO `user_coupon` VALUES (132, 63, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (133, 63, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (134, 64, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (135, 64, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (136, 65, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (137, 65, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (138, 66, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 2, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (139, 66, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 17:52:21');
INSERT INTO `user_coupon` VALUES (140, 66, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 18:10:59');
INSERT INTO `user_coupon` VALUES (141, 67, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-02 18:10:59');
INSERT INTO `user_coupon` VALUES (142, 67, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 18:10:59');
INSERT INTO `user_coupon` VALUES (143, 68, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 2, '2026-05-02 18:10:59');
INSERT INTO `user_coupon` VALUES (144, 68, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-02 18:10:59');
INSERT INTO `user_coupon` VALUES (145, 68, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (146, 69, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (147, 69, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (148, 70, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (149, 70, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (150, 71, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (151, 71, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (152, 72, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (153, 72, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (154, 73, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (155, 73, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (156, 74, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (157, 74, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (158, 75, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (159, 75, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (160, 76, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (161, 76, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (162, 77, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (163, 77, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (164, 78, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (165, 78, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (166, 79, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (167, 79, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (168, 80, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (169, 80, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (170, 81, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (171, 81, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (172, 82, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (173, 82, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (174, 83, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (175, 83, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (176, 84, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (177, 84, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (178, 85, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (179, 85, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (180, 86, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (181, 86, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (182, 87, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (183, 87, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (184, 88, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (185, 88, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (186, 89, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (187, 89, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (188, 90, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:41');
INSERT INTO `user_coupon` VALUES (189, 90, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (190, 91, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (191, 91, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (192, 92, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (193, 92, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (194, 93, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (195, 93, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (196, 94, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (197, 94, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (198, 95, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (199, 95, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (200, 96, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (201, 96, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (202, 97, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (203, 97, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (204, 98, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (205, 98, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (206, 99, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (207, 99, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (208, 100, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (209, 100, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (210, 101, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (211, 101, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (212, 102, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (213, 102, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (214, 103, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (215, 103, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (216, 104, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (217, 104, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (218, 105, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (219, 105, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (220, 106, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (221, 106, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (222, 107, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (223, 107, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (224, 108, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (225, 108, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (226, 109, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (227, 109, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (228, 110, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (229, 110, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (230, 111, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (231, 111, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (232, 112, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (233, 112, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (234, 113, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (235, 113, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (236, 114, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (237, 114, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (238, 115, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (239, 115, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (240, 116, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (241, 116, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (242, 117, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (243, 117, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (244, 118, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (245, 118, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (246, 119, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (247, 119, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (248, 120, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (249, 120, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (250, 121, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (251, 121, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (252, 122, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (253, 122, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (254, 123, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (255, 123, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (256, 124, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (257, 124, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (258, 125, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (259, 125, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (260, 126, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (261, 126, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (262, 127, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (263, 127, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (264, 128, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (265, 128, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (266, 129, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (267, 129, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (268, 130, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (269, 130, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (270, 131, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (271, 131, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (272, 132, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (273, 132, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (274, 133, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (275, 133, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (276, 134, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (277, 134, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (278, 135, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (279, 135, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (280, 136, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (281, 136, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (282, 137, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (283, 137, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (284, 138, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (285, 138, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (286, 139, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (287, 139, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (288, 140, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (289, 140, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (290, 141, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (291, 141, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (292, 142, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (293, 142, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (294, 143, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (295, 143, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (296, 144, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-03 18:55:42');
INSERT INTO `user_coupon` VALUES (297, 144, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-03 18:55:42');

-- ----------------------------
-- Table structure for user_setting
-- ----------------------------
DROP TABLE IF EXISTS `user_setting`;
CREATE TABLE `user_setting`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '设置ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `notify_order` tinyint(4) NOT NULL DEFAULT 1 COMMENT '订单通知',
  `notify_promo` tinyint(4) NOT NULL DEFAULT 0 COMMENT '活动通知',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户设置表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user_setting
-- ----------------------------
INSERT INTO `user_setting` VALUES (1, 1, 1, 0, '2026-05-02 15:38:31');
INSERT INTO `user_setting` VALUES (2, 2, 1, 1, '2026-05-02 15:38:31');
INSERT INTO `user_setting` VALUES (3, 46, 1, 0, '2026-05-02 15:41:27');
INSERT INTO `user_setting` VALUES (4, 58, 1, 1, '2026-05-02 17:31:26');
INSERT INTO `user_setting` VALUES (5, 60, 1, 1, '2026-05-02 17:34:13');
INSERT INTO `user_setting` VALUES (6, 66, 1, 0, '2026-05-02 17:52:18');
INSERT INTO `user_setting` VALUES (7, 68, 1, 0, '2026-05-02 18:10:57');
INSERT INTO `user_setting` VALUES (8, 136, 1, 0, '2026-05-03 18:28:12');
INSERT INTO `user_setting` VALUES (9, 144, 1, 0, '2026-05-03 18:55:39');
INSERT INTO `user_setting` VALUES (10, 145, 1, 0, '2026-05-07 15:53:45');

SET FOREIGN_KEY_CHECKS = 1;
