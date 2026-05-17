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

 Date: 16/05/2026 22:58:56
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
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `fk_address_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '收货地址表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of address
-- ----------------------------
INSERT INTO `address` VALUES (1, 1, '张三', '18229656601', '湖南省', '长沙市', '天心区', '中南林业科技大学', 1, '2026-05-15 16:27:49');

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `username` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员账号',
  `password` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL COMMENT '管理员密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '管理员昵称',
  `shop_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '' COMMENT '店铺名称',
  `contact_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系人姓名',
  `phone` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '联系电话',
  `address` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '店铺地址',
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '店铺简介',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态：1启用 0停用',
  `create_time` datetime NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_admin_username`(`username`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci COMMENT = '管理员表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '123123', 'admin', 'FreshTime鲜时刻', '张三', '0736888999', '湖南省长沙市天心区文源街道', NULL, 1, '0000-00-00 00:00:00');

-- ----------------------------
-- Table structure for banner
-- ----------------------------
DROP TABLE IF EXISTS `banner`;
CREATE TABLE `banner`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '轮播图ID',
  `title` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '标题',
  `image` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '图片URL',
  `link_type` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT 'none' COMMENT '跳转类型：none/goodsDetail/category/url/knowledge/search/goods',
  `link_value` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '跳转值（商品ID/分类ID/URL）',
  `sort` int(11) NULL DEFAULT 0 COMMENT '排序值',
  `status` tinyint(4) NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '轮播图表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of banner
-- ----------------------------
INSERT INTO `banner` VALUES (1, '品牌主题', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/鲜时刻品牌主题.jpg', 'knowledge', '1', 1, 1, '2026-05-07 16:38:20');
INSERT INTO `banner` VALUES (2, '当季维C补给', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/1.jpg', 'knowledge', '2', 2, 1, '2026-05-07 16:38:20');
INSERT INTO `banner` VALUES (3, '一周轻食搭配', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/2.jpg', 'knowledge', '3', 3, 1, '2026-05-07 16:38:20');

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '购物车项ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `sku_id` bigint(20) NULL DEFAULT NULL COMMENT '商品规格ID',
  `quantity` int(11) NOT NULL DEFAULT 1 COMMENT '购买数量',
  `selected` tinyint(4) NULL DEFAULT 1 COMMENT '是否选中 0否 1是',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_user_goods_sku`(`user_id`, `goods_id`, `sku_id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `fk_cart_goods`(`goods_id`) USING BTREE,
  CONSTRAINT `fk_cart_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '购物车表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of cart
-- ----------------------------
INSERT INTO `cart` VALUES (3, 1, 1, 1, 1, 1, '2026-05-15 17:16:38');
INSERT INTO `cart` VALUES (4, 1, 49, 49, 1, 1, '2026-05-16 17:44:37');
INSERT INTO `cart` VALUES (5, 1, 19, 19, 1, 1, '2026-05-16 17:44:37');
INSERT INTO `cart` VALUES (6, 1, 14, 14, 1, 1, '2026-05-16 17:44:37');

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
INSERT INTO `category` VALUES (1, '蔬菜', '', 1, 1, '2026-04-20 16:06:37', 0);
INSERT INTO `category` VALUES (2, '水果', '', 2, 1, '2026-04-20 16:06:37', 0);
INSERT INTO `category` VALUES (3, '叶菜类', '', 1, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (4, '根茎类', '', 2, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (5, '茄果类', '', 3, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (6, '菌菇类', '', 4, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (7, '瓜类', '', 5, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (8, '豆类', '', 6, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (9, '花菜类', '', 7, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (10, '其他', '', 8, 1, '2026-04-20 16:06:37', 1);
INSERT INTO `category` VALUES (11, '浆果类', '', 1, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (12, '柑橘类', '', 2, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (13, '瓜类', '', 3, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (14, '核果类', '', 4, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (15, '仁果类', '', 5, 1, '2026-04-20 16:06:37', 2);
INSERT INTO `category` VALUES (16, '聚花果类及其他', '', 6, 1, '2026-04-21 15:23:54', 2);

-- ----------------------------
-- Table structure for comment
-- ----------------------------
DROP TABLE IF EXISTS `comment`;
CREATE TABLE `comment`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '评价ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
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
-- Table structure for coupon
-- ----------------------------
DROP TABLE IF EXISTS `coupon`;
CREATE TABLE `coupon`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '优惠券名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '优惠说明',
  `threshold_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '使用门槛',
  `discount_amount` decimal(10, 2) NOT NULL DEFAULT 0.00 COMMENT '优惠金额',
  `expire_date` date NULL DEFAULT NULL COMMENT '过期日期',
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '状态 0禁用 1启用',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '优惠券模板表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of coupon
-- ----------------------------
INSERT INTO `coupon` VALUES (1, '满50减8', '全场可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-09 17:10:08');
INSERT INTO `coupon` VALUES (2, '满99减15', '生鲜专区', 99.00, 15.00, '2026-12-31', 1, '2026-05-09 17:10:08');
INSERT INTO `coupon` VALUES (3, '满39减5', '新人专享', 39.00, 5.00, '2026-12-31', 1, '2026-05-09 17:10:08');

-- ----------------------------
-- Table structure for goods
-- ----------------------------
DROP TABLE IF EXISTS `goods`;
CREATE TABLE `goods`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '商品ID',
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
  INDEX `idx_category_id`(`category_id`) USING BTREE,
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `idx_goods_home`(`show_in_home`, `status`, `home_sort`) USING BTREE,
  INDEX `idx_goods_flash`(`is_flash`, `flash_start_time`, `flash_end_time`, `status`) USING BTREE,
  INDEX `idx_goods_sales`(`sales_volume`, `status`) USING BTREE,
  CONSTRAINT `fk_goods_category` FOREIGN KEY (`category_id`) REFERENCES `category` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 191 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of goods
-- ----------------------------
INSERT INTO `goods` VALUES (1, 11, '草莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/草莓.jpg\"]', '草莓｜建议挑选果面有光泽、果蒂鲜绿的批次，口感偏酸甜，适合鲜食、酸奶杯和轻食沙拉。到货后建议冷藏2-4℃保存，24小时内食用风味最佳。', 25.80, 32.80, 84, '斤', 908, 1, 0, NULL, NULL, NULL, 0, 3, 1, 1, '2026-04-26 23:44:33', '草莓,山东,鲜食水果,酸甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (2, 11, '蓝莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/蓝莓.jpg\"]', '蓝莓｜果粉完整、手感干爽说明新鲜度更好，适合直接食用、烘焙与奶昔。建议冷藏保鲜，食用前轻冲洗并沥干。', 38.80, 45.80, 72, '盒', 464, 0, 0, NULL, NULL, NULL, 0, 5, 1, 1, '2026-04-25 23:44:33', '蓝莓,云南,鲜食水果,酸甜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (3, 11, '巨峰葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/巨峰葡萄.jpg\"]', '巨峰葡萄｜建议选择果粒饱满、果梗青绿的批次，甜度与汁水表现更稳定。适合鲜食或冷泡果饮，冷藏后口感更佳。', 18.80, 22.56, 137, '斤', 1037, 1, 0, NULL, NULL, NULL, 0, 4, 1, 1, '2026-04-21 15:33:25', '巨峰葡萄,新疆,鲜食水果,新鲜,冷藏保存', '新疆');
INSERT INTO `goods` VALUES (4, 12, '橙子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橙子.jpg\"]', '橙子｜柑橘类适合补充维C，鲜食与榨汁都合适。建议置于阴凉通风处短存，需久放可冷藏并尽量分批取用。', 8.80, 10.80, 299, '斤', 1568, 1, 0, NULL, NULL, NULL, 0, 2, 1, 1, '2026-04-26 23:44:33', '橙子,江西,鲜食水果,清甜,冷藏保存', '江西');
INSERT INTO `goods` VALUES (5, 12, '丑橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/丑橘.jpg\"]', '丑橘｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.50, 9.00, 247, '斤', 1027, 1, 0, NULL, NULL, NULL, 0, 6, 1, 1, '2026-04-21 15:33:25', '丑橘,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (6, 12, '柠檬', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/柠檬.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/柠檬.jpg\"]', '柠檬｜柑橘类适合补充维C，鲜食与榨汁都合适。建议置于阴凉通风处短存，需久放可冷藏并尽量分批取用。', 6.80, 8.80, 180, '斤', 567, 1, 0, NULL, NULL, NULL, 0, 7, 1, 1, '2026-04-21 15:33:25', '柠檬,海南,鲜食水果,清香,冷藏保存', '海南');
INSERT INTO `goods` VALUES (7, 13, '西瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/西瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/西瓜.jpg\"]', '西瓜｜瓜类建议按需购买，切开后请及时冷藏并覆盖保鲜。适合夏季鲜食、果盘与轻饮，口感以清甜多汁为主。', 3.80, 4.56, 300, '斤', 1567, 0, 0, NULL, NULL, NULL, 0, 6, 1, 1, '2026-04-21 15:33:25', '西瓜,河南,鲜食水果,新鲜,冷藏保存', '河南');
INSERT INTO `goods` VALUES (8, 13, '哈密瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/哈密瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/哈密瓜.jpg\"]', '哈密瓜｜瓜类建议按需购买，切开后请及时冷藏并覆盖保鲜。适合夏季鲜食、果盘与轻饮，口感以清甜多汁为主。', 8.80, 10.80, 150, '个', 678, 1, 0, NULL, NULL, NULL, 0, 9, 1, 1, '2026-04-21 15:33:25', '哈密瓜,新疆,鲜食水果,新鲜,冷藏保存', '新疆');
INSERT INTO `goods` VALUES (9, 13, '香瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/香瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/香瓜.jpg\"]', '香瓜｜瓜类建议按需购买，切开后请及时冷藏并覆盖保鲜。适合夏季鲜食、果盘与轻饮，口感以清甜多汁为主。', 6.80, 8.16, 120, '斤', 345, 0, 0, NULL, NULL, NULL, 0, 10, 1, 1, '2026-04-21 15:33:25', '香瓜,海南,鲜食水果,新鲜,冷藏保存', '海南');
INSERT INTO `goods` VALUES (10, 14, '水蜜桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/水蜜桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/水蜜桃.jpg\"]', '水蜜桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 18.80, 22.80, 119, '斤', 679, 1, 0, NULL, NULL, NULL, 0, 4, 1, 1, '2026-04-25 23:44:33', '水蜜桃,浙江,鲜食水果,新鲜,冷藏保存', '浙江');
INSERT INTO `goods` VALUES (11, 14, '黑布李', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黑布李.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黑布李.jpg\"]', '黑布李｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.36, 150, '斤', 345, 0, 0, NULL, NULL, NULL, 0, 12, 1, 1, '2026-04-21 15:33:25', '黑布李,广东,鲜食水果,新鲜,冷藏保存', '广东');
INSERT INTO `goods` VALUES (12, 14, '樱桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/樱桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/樱桃.jpg\"]', '樱桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 48.80, 58.80, 60, '斤', 234, 0, 0, NULL, NULL, NULL, 0, 13, 1, 1, '2026-04-21 15:33:25', '樱桃,山东,鲜食水果,酸甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (13, 15, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg\"]', '红富士苹果｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 9.80, 12.80, 297, '斤', 2051, 1, 0, NULL, NULL, NULL, 0, 1, 1, 1, '2026-04-26 23:44:33', '红富士苹果,陕西,鲜食水果,清甜,冷藏保存', '陕西');
INSERT INTO `goods` VALUES (14, 15, '皇冠梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/皇冠梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/皇冠梨.jpg\"]', '皇冠梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 7.80, 9.36, 250, '斤', 1024, 1, 0, NULL, NULL, NULL, 0, 7, 1, 1, '2026-04-21 15:33:25', '皇冠梨,河北,鲜食水果,清甜,冷藏保存', '河北');
INSERT INTO `goods` VALUES (15, 15, '枇杷', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/枇杷.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/枇杷.jpg\"]', '枇杷｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 8.80, 10.80, 180, '斤', 567, 1, 0, NULL, NULL, NULL, 0, 16, 1, 1, '2026-04-21 15:33:25', '枇杷,福建,鲜食水果,新鲜,冷藏保存', '福建');
INSERT INTO `goods` VALUES (16, 16, '菠萝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝.jpg\"]', '菠萝｜该品类风味层次明显，适合鲜食、轻甜品或沙拉搭配。建议低温保鲜并避免长时间挤压。', 12.80, 15.80, 100, '个', 678, 1, 0, NULL, NULL, NULL, 0, 8, 1, 1, '2026-04-25 23:44:33', '菠萝,海南,鲜食水果,新鲜,冷藏保存', '海南');
INSERT INTO `goods` VALUES (17, 16, '无花果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/无花果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/无花果.jpg\"]', '无花果｜该品类风味层次明显，适合鲜食、轻甜品或沙拉搭配。建议低温保鲜并避免长时间挤压。', 22.80, 28.80, 60, '斤', 234, 0, 0, NULL, NULL, NULL, 0, 18, 1, 1, '2026-04-21 15:33:25', '无花果,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (18, 16, '桑葚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/桑葚.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/桑葚.jpg\"]', '桑葚｜该品类风味层次明显，适合鲜食、轻甜品或沙拉搭配。建议低温保鲜并避免长时间挤压。', 15.80, 18.96, 76, '盒', 349, 0, 0, NULL, NULL, NULL, 0, 19, 1, 1, '2026-04-21 15:33:25', '桑葚,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (19, 8, '豆芽', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/豆芽.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/豆芽.jpg\"]', '豆芽｜豆类蔬菜适合快炒与配菜搭配，建议控制火候以保留脆嫩口感。到货后冷藏并尽快食用。', 8.60, 10.49, 170, '斤', 139, 0, 0, NULL, NULL, NULL, 0, 20, 1, 1, '2026-05-11 16:06:35', '豆芽,广西,家常蔬菜,新鲜,家常烹饪', '广西');
INSERT INTO `goods` VALUES (20, 8, '荷兰豆', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/荷兰豆.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/荷兰豆.jpg\"]', '荷兰豆｜豆类蔬菜适合快炒与配菜搭配，建议控制火候以保留脆嫩口感。到货后冷藏并尽快食用。', 8.60, 10.49, 170, '斤', 140, 0, 0, NULL, NULL, NULL, 0, 21, 1, 1, '2026-05-11 16:06:35', '荷兰豆,广西,家常蔬菜,新鲜,家常烹饪', '广西');
INSERT INTO `goods` VALUES (21, 8, '毛豆', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/毛豆.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/毛豆.jpg\"]', '毛豆｜豆类蔬菜适合快炒与配菜搭配，建议控制火候以保留脆嫩口感。到货后冷藏并尽快食用。', 8.60, 10.49, 170, '斤', 141, 0, 0, NULL, NULL, NULL, 0, 22, 1, 1, '2026-05-11 16:06:35', '毛豆,广西,家常蔬菜,新鲜,家常烹饪', '广西');
INSERT INTO `goods` VALUES (22, 8, '四季豆', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/四季豆.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/四季豆.jpg\"]', '四季豆｜豆类蔬菜适合快炒与配菜搭配，建议控制火候以保留脆嫩口感。到货后冷藏并尽快食用。', 8.60, 10.49, 170, '斤', 142, 0, 0, NULL, NULL, NULL, 0, 23, 1, 1, '2026-05-11 16:06:35', '四季豆,广西,家常蔬菜,新鲜,家常烹饪', '广西');
INSERT INTO `goods` VALUES (23, 8, '豌豆', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/豌豆.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/豌豆.jpg\"]', '豌豆｜豆类蔬菜适合快炒与配菜搭配，建议控制火候以保留脆嫩口感。到货后冷藏并尽快食用。', 8.60, 10.49, 170, '斤', 143, 1, 0, NULL, NULL, NULL, 0, 24, 1, 1, '2026-05-11 16:06:35', '豌豆,广西,家常蔬菜,新鲜,家常烹饪', '广西');
INSERT INTO `goods` VALUES (24, 8, '长豆角', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/长豆角.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/豆类/长豆角.jpg\"]', '长豆角｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 8.60, 10.49, 170, '斤', 144, 0, 0, NULL, NULL, NULL, 0, 25, 1, 1, '2026-05-11 16:06:35', '长豆角,广西,家常蔬菜,新鲜,家常烹饪', '广西');
INSERT INTO `goods` VALUES (25, 4, '白萝卜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/白萝卜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/白萝卜.jpg\"]', '白萝卜｜根茎类储存性较好，适合炖煮、快炒和汤底搭配。建议阴凉干燥保存，避免与高湿食材混放。', 6.80, 8.30, 220, '斤', 145, 0, 0, NULL, NULL, NULL, 0, 225, 1, 1, '2026-05-11 16:06:35', '白萝卜,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (26, 4, '大蒜头', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/大蒜头.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/大蒜头.jpg\"]', '大蒜头｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 146, 0, 0, NULL, NULL, NULL, 0, 226, 1, 1, '2026-05-11 16:06:35', '大蒜头,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (27, 4, '独头蒜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/独头蒜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/独头蒜.jpg\"]', '独头蒜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 147, 0, 0, NULL, NULL, NULL, 0, 227, 1, 1, '2026-05-11 16:06:35', '独头蒜,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (28, 4, '红薯', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/红薯.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/红薯.jpg\"]', '红薯｜根茎类储存性较好，适合炖煮、快炒和汤底搭配。建议阴凉干燥保存，避免与高湿食材混放。', 6.80, 8.30, 220, '斤', 148, 0, 0, NULL, NULL, NULL, 0, 228, 1, 1, '2026-05-11 16:06:35', '红薯,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (29, 4, '胡萝卜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/胡萝卜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/胡萝卜.jpg\"]', '胡萝卜｜根茎类储存性较好，适合炖煮、快炒和汤底搭配。建议阴凉干燥保存，避免与高湿食材混放。', 6.80, 8.30, 220, '斤', 149, 0, 0, NULL, NULL, NULL, 0, 229, 1, 1, '2026-05-11 16:06:35', '胡萝卜,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (30, 4, '茭白', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/茭白.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/茭白.jpg\"]', '茭白｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 150, 0, 0, NULL, NULL, NULL, 0, 200, 1, 1, '2026-05-11 16:06:35', '茭白,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (31, 4, '莲藕', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/莲藕.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/莲藕.jpg\"]', '莲藕｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 151, 0, 0, NULL, NULL, NULL, 0, 201, 1, 1, '2026-05-11 16:06:35', '莲藕,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (32, 4, '芦笋', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/芦笋.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/芦笋.jpg\"]', '芦笋｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 152, 0, 0, NULL, NULL, NULL, 0, 202, 1, 1, '2026-05-11 16:06:35', '芦笋,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (33, 4, '南姜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/南姜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/南姜.jpg\"]', '南姜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 153, 0, 0, NULL, NULL, NULL, 0, 203, 1, 1, '2026-05-11 16:06:35', '南姜,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (34, 4, '山药', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/山药.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/山药.jpg\"]', '山药｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 154, 0, 0, NULL, NULL, NULL, 0, 204, 1, 1, '2026-05-11 16:06:35', '山药,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (35, 4, '生姜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/生姜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/生姜.jpg\"]', '生姜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 155, 0, 0, NULL, NULL, NULL, 0, 205, 1, 1, '2026-05-11 16:06:35', '生姜,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (36, 4, '土豆', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/土豆.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/土豆.jpg\"]', '土豆｜根茎类储存性较好，适合炖煮、快炒和汤底搭配。建议阴凉干燥保存，避免与高湿食材混放。', 6.80, 8.30, 220, '斤', 156, 0, 0, NULL, NULL, NULL, 0, 206, 1, 1, '2026-05-11 16:06:35', '土豆,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (37, 4, '莴笋', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/莴笋.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/莴笋.jpg\"]', '莴笋｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 157, 0, 0, NULL, NULL, NULL, 0, 207, 1, 1, '2026-05-11 16:06:35', '莴笋,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (38, 4, '洋葱', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/洋葱.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/洋葱.jpg\"]', '洋葱｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 158, 0, 0, NULL, NULL, NULL, 0, 208, 1, 1, '2026-05-11 16:06:35', '洋葱,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (39, 4, '樱桃萝卜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/樱桃萝卜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/樱桃萝卜.jpg\"]', '樱桃萝卜｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 6.80, 8.30, 220, '斤', 159, 1, 0, NULL, NULL, NULL, 0, 209, 1, 1, '2026-05-11 16:06:35', '樱桃萝卜,河南,家常蔬菜,酸甜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (40, 4, '芋艿', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/芋艿.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/芋艿.jpg\"]', '芋艿｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 160, 0, 0, NULL, NULL, NULL, 0, 210, 1, 1, '2026-05-11 16:06:35', '芋艿,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (41, 4, '芋头', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/芋头.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/芋头.jpg\"]', '芋头｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 161, 0, 0, NULL, NULL, NULL, 0, 211, 1, 1, '2026-05-11 16:06:35', '芋头,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (42, 4, '竹笋', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/竹笋.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/竹笋.jpg\"]', '竹笋｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 162, 0, 0, NULL, NULL, NULL, 0, 212, 1, 1, '2026-05-11 16:06:35', '竹笋,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (43, 4, '子姜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/子姜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/子姜.jpg\"]', '子姜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 163, 0, 0, NULL, NULL, NULL, 0, 213, 1, 1, '2026-05-11 16:06:35', '子姜,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (44, 4, '紫薯', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/紫薯.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/根茎类/紫薯.jpg\"]', '紫薯｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.80, 8.30, 220, '斤', 164, 0, 0, NULL, NULL, NULL, 0, 214, 1, 1, '2026-05-11 16:06:35', '紫薯,河南,家常蔬菜,新鲜,家常烹饪', '河南');
INSERT INTO `goods` VALUES (45, 7, '八角丝瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/八角丝瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/八角丝瓜.jpg\"]', '八角丝瓜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.20, 7.56, 210, '斤', 115, 0, 0, NULL, NULL, NULL, 0, 46, 1, 1, '2026-05-11 16:06:35', '八角丝瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (46, 7, '贝贝南瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/贝贝南瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/贝贝南瓜.jpg\"]', '贝贝南瓜｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。', 6.20, 7.56, 210, '斤', 116, 0, 0, NULL, NULL, NULL, 0, 47, 1, 1, '2026-05-11 16:06:35', '贝贝南瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (47, 7, '冬瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/冬瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/冬瓜.jpg\"]', '冬瓜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.20, 7.56, 210, '斤', 117, 0, 0, NULL, NULL, NULL, 0, 48, 1, 1, '2026-05-11 16:06:35', '冬瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (48, 7, '佛手瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/佛手瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/佛手瓜.jpg\"]', '佛手瓜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.20, 7.56, 210, '斤', 118, 0, 0, NULL, NULL, NULL, 0, 49, 1, 1, '2026-05-11 16:06:35', '佛手瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (49, 7, '黄瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/黄瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/黄瓜.jpg\"]', '黄瓜｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。', 6.20, 7.56, 210, '斤', 119, 0, 0, NULL, NULL, NULL, 0, 50, 1, 1, '2026-05-11 16:06:35', '黄瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (50, 7, '苦瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/苦瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/苦瓜.jpg\"]', '苦瓜｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。', 6.20, 7.56, 210, '斤', 120, 0, 0, NULL, NULL, NULL, 0, 51, 1, 1, '2026-05-11 16:06:35', '苦瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (51, 7, '南瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/南瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/南瓜.jpg\"]', '南瓜｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。', 6.20, 7.56, 210, '斤', 121, 0, 0, NULL, NULL, NULL, 0, 52, 1, 1, '2026-05-11 16:06:35', '南瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (52, 7, '嫩南瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/嫩南瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/嫩南瓜.jpg\"]', '嫩南瓜｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。', 6.20, 7.56, 210, '斤', 122, 0, 0, NULL, NULL, NULL, 0, 53, 1, 1, '2026-05-11 16:06:35', '嫩南瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (53, 7, '丝瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/丝瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/丝瓜.jpg\"]', '丝瓜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.20, 7.56, 210, '斤', 123, 0, 0, NULL, NULL, NULL, 0, 54, 1, 1, '2026-05-11 16:06:35', '丝瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (54, 7, '小黄瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/小黄瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/瓜类/小黄瓜.jpg\"]', '小黄瓜｜瓜类蔬菜适合清炒、凉拌或做汤。建议按烹饪场景分切，减少二次处理损耗。', 6.20, 7.56, 210, '斤', 124, 0, 0, NULL, NULL, NULL, 0, 55, 1, 1, '2026-05-11 16:06:35', '小黄瓜,海南,家常蔬菜,新鲜,家常烹饪', '海南');
INSERT INTO `goods` VALUES (55, 9, '花椰菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/花菜类/花椰菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/花菜类/花椰菜.jpg\"]', '花椰菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.20, 8.78, 190, '斤', 175, 0, 0, NULL, NULL, NULL, 0, 56, 1, 1, '2026-05-11 16:06:35', '花椰菜,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (56, 9, '黄花菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/花菜类/黄花菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/花菜类/黄花菜.jpg\"]', '黄花菜｜花菜类适合焯水后再炒，口感更脆且更易入味。适合清炒、蒜蓉和便当配菜，冷藏可短期保鲜。', 7.20, 8.78, 190, '斤', 176, 0, 0, NULL, NULL, NULL, 0, 57, 1, 1, '2026-05-11 16:06:35', '黄花菜,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (57, 9, '西兰花', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/花菜类/西兰花.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/花菜类/西兰花.jpg\"]', '西兰花｜花菜类适合焯水后再炒，口感更脆且更易入味。适合清炒、蒜蓉和便当配菜，冷藏可短期保鲜。', 7.20, 8.78, 190, '斤', 177, 0, 0, NULL, NULL, NULL, 0, 58, 1, 1, '2026-05-11 16:06:35', '西兰花,云南,家常蔬菜,脆嫩,家常烹饪', '云南');
INSERT INTO `goods` VALUES (58, 6, '茨菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/茨菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/茨菇.jpg\"]', '茨菇｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 9.80, 11.96, 160, '斤', 178, 0, 0, NULL, NULL, NULL, 0, 59, 1, 1, '2026-05-11 16:06:35', '茨菇,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (59, 6, '凤尾菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/凤尾菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/凤尾菇.jpg\"]', '凤尾菇｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 9.80, 11.96, 160, '斤', 179, 0, 0, NULL, NULL, NULL, 0, 60, 1, 1, '2026-05-11 16:06:35', '凤尾菇,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (60, 6, '海鲜菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/海鲜菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/海鲜菇.jpg\"]', '海鲜菇｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 9.80, 11.96, 160, '斤', 180, 0, 0, NULL, NULL, NULL, 0, 1, 1, 1, '2026-05-11 16:06:35', '海鲜菇,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (61, 6, '花菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/花菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/花菇.jpg\"]', '花菇｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 9.80, 11.96, 160, '斤', 181, 0, 0, NULL, NULL, NULL, 0, 2, 1, 1, '2026-05-11 16:06:35', '花菇,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (62, 6, '金针菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/金针菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/金针菇.jpg\"]', '金针菇｜菌菇类适合火锅、汤品与小炒，建议清洗后沥干再烹饪，口感更佳。冷藏条件下建议2天内使用。', 9.80, 11.96, 160, '斤', 182, 0, 0, NULL, NULL, NULL, 0, 3, 1, 1, '2026-05-11 16:06:35', '金针菇,福建,家常蔬菜,鲜香,家常烹饪', '福建');
INSERT INTO `goods` VALUES (63, 6, '木耳', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/木耳.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/木耳.jpg\"]', '木耳｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 9.80, 11.96, 160, '斤', 183, 0, 0, NULL, NULL, NULL, 0, 4, 1, 1, '2026-05-11 16:06:35', '木耳,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (64, 6, '平菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/平菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/平菇.jpg\"]', '平菇｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 9.80, 11.96, 160, '斤', 184, 0, 0, NULL, NULL, NULL, 0, 5, 1, 1, '2026-05-11 16:06:35', '平菇,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (65, 6, '香菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/香菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/香菇.jpg\"]', '香菇｜菌菇类适合火锅、汤品与小炒，建议清洗后沥干再烹饪，口感更佳。冷藏条件下建议2天内使用。', 9.80, 11.96, 160, '斤', 185, 0, 0, NULL, NULL, NULL, 0, 6, 1, 1, '2026-05-11 16:06:35', '香菇,福建,家常蔬菜,鲜香,家常烹饪', '福建');
INSERT INTO `goods` VALUES (66, 6, '杏鲍菇', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/杏鲍菇.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/菌菇类/杏鲍菇.jpg\"]', '杏鲍菇｜菌菇类适合火锅、汤品与小炒，建议清洗后沥干再烹饪，口感更佳。冷藏条件下建议2天内使用。', 9.80, 11.96, 160, '斤', 186, 0, 0, NULL, NULL, NULL, 0, 7, 1, 1, '2026-05-11 16:06:35', '杏鲍菇,福建,家常蔬菜,新鲜,家常烹饪', '福建');
INSERT INTO `goods` VALUES (67, 10, '蒜苗', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/其他/蒜苗.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/其他/蒜苗.jpg\"]', '蒜苗｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.60, 8.05, 150, '斤', 137, 0, 0, NULL, NULL, NULL, 0, 8, 1, 1, '2026-05-11 16:06:35', '蒜苗,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (68, 10, '香葱', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/其他/香葱.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/其他/香葱.jpg\"]', '香葱｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.60, 8.05, 150, '斤', 138, 0, 0, NULL, NULL, NULL, 0, 9, 1, 1, '2026-05-11 16:06:35', '香葱,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (69, 10, '香茅', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/其他/香茅.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/其他/香茅.jpg\"]', '香茅｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 6.60, 8.05, 150, '斤', 139, 0, 0, NULL, NULL, NULL, 0, 10, 1, 1, '2026-05-11 16:06:35', '香茅,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (70, 5, '彩椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/彩椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/彩椒.jpg\"]', '彩椒｜茄果类适合家常快炒、炖煮和轻食搭配，风味稳定且适配度高。建议按成熟度分批食用。', 7.80, 9.52, 200, '斤', 190, 0, 0, NULL, NULL, NULL, 0, 11, 1, 1, '2026-05-11 16:06:35', '彩椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (71, 5, '灯笼彩椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/灯笼彩椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/灯笼彩椒.jpg\"]', '灯笼彩椒｜茄果类适合家常快炒、炖煮和轻食搭配，风味稳定且适配度高。建议按成熟度分批食用。', 7.80, 9.52, 200, '斤', 191, 0, 0, NULL, NULL, NULL, 0, 12, 1, 1, '2026-05-11 16:06:35', '灯笼彩椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (72, 5, '湖南椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/湖南椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/湖南椒.jpg\"]', '湖南椒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 192, 0, 0, NULL, NULL, NULL, 0, 13, 1, 1, '2026-05-11 16:06:35', '湖南椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (73, 5, '螺丝椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/螺丝椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/螺丝椒.jpg\"]', '螺丝椒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 193, 0, 0, NULL, NULL, NULL, 0, 14, 1, 1, '2026-05-11 16:06:35', '螺丝椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (74, 5, '茄子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/茄子.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/茄子.jpg\"]', '茄子｜茄果类适合家常快炒、炖煮和轻食搭配，风味稳定且适配度高。建议按成熟度分批食用。', 7.80, 9.52, 200, '斤', 194, 0, 0, NULL, NULL, NULL, 0, 15, 1, 1, '2026-05-11 16:06:35', '茄子,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (75, 5, '青辣椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/青辣椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/青辣椒.jpg\"]', '青辣椒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 195, 0, 0, NULL, NULL, NULL, 0, 16, 1, 1, '2026-05-11 16:06:35', '青辣椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (76, 5, '秋葵', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/秋葵.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/秋葵.jpg\"]', '秋葵｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 196, 0, 0, NULL, NULL, NULL, 0, 17, 1, 1, '2026-05-11 16:06:35', '秋葵,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (77, 5, '西红柿', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/西红柿.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/西红柿.jpg\"]', '西红柿｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 197, 0, 0, NULL, NULL, NULL, 0, 18, 1, 1, '2026-05-11 16:06:35', '西红柿,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (78, 5, '小米椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/小米椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/小米椒.jpg\"]', '小米椒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 198, 0, 0, NULL, NULL, NULL, 0, 19, 1, 1, '2026-05-11 16:06:35', '小米椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (79, 5, '玉米', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/玉米.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/玉米.jpg\"]', '玉米｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 199, 0, 0, NULL, NULL, NULL, 0, 20, 1, 1, '2026-05-11 16:06:35', '玉米,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (80, 5, '圆椒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/圆椒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/茄果类/圆椒.jpg\"]', '圆椒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 7.80, 9.52, 200, '斤', 200, 0, 0, NULL, NULL, NULL, 0, 21, 1, 1, '2026-05-11 16:06:35', '圆椒,云南,家常蔬菜,新鲜,家常烹饪', '云南');
INSERT INTO `goods` VALUES (81, 3, '包菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/包菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/包菜.jpg\"]', '包菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 201, 0, 0, NULL, NULL, NULL, 0, 121, 1, 1, '2026-05-11 16:06:35', '包菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (82, 3, '菠菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/菠菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/菠菜.jpg\"]', '菠菜｜叶菜类建议快炒或汆烫，清洗后沥干再入锅可减少出水。适合家常快手菜，建议到货后尽快食用。', 5.80, 7.08, 180, '斤', 202, 0, 0, NULL, NULL, NULL, 0, 122, 1, 1, '2026-05-11 16:06:35', '菠菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (83, 3, '菜心', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/菜心.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/菜心.jpg\"]', '菜心｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 203, 0, 0, NULL, NULL, NULL, 0, 123, 1, 1, '2026-05-11 16:06:35', '菜心,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (84, 3, '大白菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/大白菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/大白菜.jpg\"]', '大白菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 204, 0, 0, NULL, NULL, NULL, 0, 124, 1, 1, '2026-05-11 16:06:35', '大白菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (85, 3, '红菜薹', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/红菜薹.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/红菜薹.jpg\"]', '红菜薹｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 205, 0, 0, NULL, NULL, NULL, 0, 125, 1, 1, '2026-05-11 16:06:35', '红菜薹,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (86, 3, '黄心白', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/黄心白.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/黄心白.jpg\"]', '黄心白｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 206, 0, 0, NULL, NULL, NULL, 0, 126, 1, 1, '2026-05-11 16:06:35', '黄心白,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (87, 3, '茴香', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/茴香.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/茴香.jpg\"]', '茴香｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 207, 0, 0, NULL, NULL, NULL, 0, 127, 1, 1, '2026-05-11 16:06:35', '茴香,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (88, 3, '芥蓝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/芥蓝.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/芥蓝.jpg\"]', '芥蓝｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 208, 0, 0, NULL, NULL, NULL, 0, 128, 1, 1, '2026-05-11 16:06:35', '芥蓝,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (89, 3, '韭菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/韭菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/韭菜.jpg\"]', '韭菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 209, 0, 0, NULL, NULL, NULL, 0, 129, 1, 1, '2026-05-11 16:06:35', '韭菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (90, 3, '韭黄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/韭黄.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/韭黄.jpg\"]', '韭黄｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 120, 0, 0, NULL, NULL, NULL, 0, 100, 1, 1, '2026-05-11 16:06:35', '韭黄,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (91, 3, '蕨菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/蕨菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/蕨菜.jpg\"]', '蕨菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 121, 0, 0, NULL, NULL, NULL, 0, 101, 1, 1, '2026-05-11 16:06:35', '蕨菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (92, 3, '空心菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/空心菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/空心菜.jpg\"]', '空心菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 122, 0, 0, NULL, NULL, NULL, 0, 102, 1, 1, '2026-05-11 16:06:35', '空心菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (93, 3, '苦麦菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/苦麦菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/苦麦菜.jpg\"]', '苦麦菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 123, 0, 0, NULL, NULL, NULL, 0, 103, 1, 1, '2026-05-11 16:06:35', '苦麦菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (94, 3, '木耳菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/木耳菜.JPG', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/木耳菜.JPG\"]', '木耳菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 124, 0, 0, NULL, NULL, NULL, 0, 104, 1, 1, '2026-05-11 16:06:35', '木耳菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (95, 3, '芹菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/芹菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/芹菜.jpg\"]', '芹菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 125, 0, 0, NULL, NULL, NULL, 0, 105, 1, 1, '2026-05-11 16:06:35', '芹菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (96, 3, '上海青', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/上海青.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/上海青.jpg\"]', '上海青｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 126, 0, 0, NULL, NULL, NULL, 0, 106, 1, 1, '2026-05-11 16:06:35', '上海青,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (97, 3, '生菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/生菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/生菜.jpg\"]', '生菜｜叶菜类建议快炒或汆烫，清洗后沥干再入锅可减少出水。适合家常快手菜，建议到货后尽快食用。', 5.80, 7.08, 180, '斤', 127, 0, 0, NULL, NULL, NULL, 0, 107, 1, 1, '2026-05-11 16:06:35', '生菜,山东,家常蔬菜,脆嫩,家常烹饪', '山东');
INSERT INTO `goods` VALUES (98, 3, '塔菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/塔菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/塔菜.jpg\"]', '塔菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 128, 0, 0, NULL, NULL, NULL, 0, 108, 1, 1, '2026-05-11 16:06:35', '塔菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (99, 3, '茼蒿', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/茼蒿.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/茼蒿.jpg\"]', '茼蒿｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 129, 0, 0, NULL, NULL, NULL, 0, 109, 1, 1, '2026-05-11 16:06:35', '茼蒿,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (100, 3, '娃娃菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/娃娃菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/娃娃菜.jpg\"]', '娃娃菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 130, 0, 0, NULL, NULL, NULL, 0, 110, 1, 1, '2026-05-11 16:06:35', '娃娃菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (101, 3, '西洋菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/西洋菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/西洋菜.jpg\"]', '西洋菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 131, 0, 0, NULL, NULL, NULL, 0, 111, 1, 1, '2026-05-11 16:06:35', '西洋菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (102, 3, '苋菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/苋菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/苋菜.jpg\"]', '苋菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 132, 0, 0, NULL, NULL, NULL, 0, 112, 1, 1, '2026-05-11 16:06:35', '苋菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (103, 3, '香菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/香菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/香菜.jpg\"]', '香菜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 133, 0, 0, NULL, NULL, NULL, 0, 113, 1, 1, '2026-05-11 16:06:35', '香菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (104, 3, '小白菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/小白菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/小白菜.jpg\"]', '小白菜｜叶菜类建议快炒或汆烫，清洗后沥干再入锅可减少出水。适合家常快手菜，建议到货后尽快食用。', 5.80, 7.08, 180, '斤', 134, 0, 0, NULL, NULL, NULL, 0, 114, 1, 1, '2026-05-11 16:06:35', '小白菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (105, 3, '油麦菜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/油麦菜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/油麦菜.jpg\"]', '油麦菜｜叶菜类建议快炒或汆烫，清洗后沥干再入锅可减少出水。适合家常快手菜，建议到货后尽快食用。', 5.80, 7.08, 180, '斤', 135, 0, 0, NULL, NULL, NULL, 0, 115, 1, 1, '2026-05-11 16:06:35', '油麦菜,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (106, 3, '紫甘蓝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/紫甘蓝.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/vegetables/叶菜类/紫甘蓝.jpg\"]', '紫甘蓝｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 5.80, 7.08, 180, '斤', 136, 0, 0, NULL, NULL, NULL, 0, 116, 1, 1, '2026-05-11 16:06:35', '紫甘蓝,山东,家常蔬菜,新鲜,家常烹饪', '山东');
INSERT INTO `goods` VALUES (107, 11, '白心芭乐', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/白心芭乐.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/白心芭乐.jpg\"]', '白心芭乐｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 97, 0, 0, NULL, NULL, NULL, 0, 48, 1, 1, '2026-05-15 17:59:14', '白心芭乐,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (108, 11, '百香果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/百香果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/百香果.jpg\"]', '百香果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 98, 0, 0, NULL, NULL, NULL, 0, 49, 1, 1, '2026-05-15 17:59:14', '百香果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (109, 11, '脆柿', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/脆柿.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/脆柿.jpg\"]', '脆柿｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 99, 0, 0, NULL, NULL, NULL, 0, 50, 1, 1, '2026-05-15 17:59:14', '脆柿,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (110, 11, '灯笼果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/灯笼果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/灯笼果.jpg\"]', '灯笼果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 100, 0, 0, NULL, NULL, NULL, 0, 51, 1, 1, '2026-05-15 17:59:14', '灯笼果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (111, 11, '黑加仑', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/黑加仑.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/黑加仑.jpg\"]', '黑加仑｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 101, 0, 0, NULL, NULL, NULL, 0, 52, 1, 1, '2026-05-15 17:59:14', '黑加仑,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (112, 11, '黑金刚莲雾', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/黑金刚莲雾.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/黑金刚莲雾.jpg\"]', '黑金刚莲雾｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 102, 0, 0, NULL, NULL, NULL, 0, 53, 1, 1, '2026-05-15 17:59:14', '黑金刚莲雾,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (113, 11, '黑莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/黑莓.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/黑莓.jpg\"]', '黑莓｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 103, 0, 0, NULL, NULL, NULL, 0, 54, 1, 1, '2026-05-15 17:59:14', '黑莓,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (114, 11, '红宝石莲雾', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红宝石莲雾.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红宝石莲雾.jpg\"]', '红宝石莲雾｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 104, 0, 0, NULL, NULL, NULL, 0, 55, 1, 1, '2026-05-15 17:59:14', '红宝石莲雾,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (115, 11, '红提', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红提.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红提.jpg\"]', '红提｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 105, 0, 0, NULL, NULL, NULL, 0, 56, 1, 1, '2026-05-15 17:59:14', '红提,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (116, 11, '红心芭乐', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红心芭乐.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红心芭乐.jpg\"]', '红心芭乐｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 106, 0, 0, NULL, NULL, NULL, 0, 57, 1, 1, '2026-05-15 17:59:14', '红心芭乐,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (117, 11, '红心火龙果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红心火龙果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/红心火龙果.jpg\"]', '红心火龙果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 107, 0, 0, NULL, NULL, NULL, 0, 58, 1, 1, '2026-05-15 17:59:14', '红心火龙果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (118, 11, '火龙果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/火龙果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/火龙果.jpg\"]', '火龙果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 108, 0, 0, NULL, NULL, NULL, 0, 59, 1, 1, '2026-05-15 17:59:14', '火龙果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (119, 11, '猕猴桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/猕猴桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/猕猴桃.jpg\"]', '猕猴桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 109, 0, 0, NULL, NULL, NULL, 0, 60, 1, 1, '2026-05-15 17:59:14', '猕猴桃,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (120, 11, '木瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/木瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/木瓜.jpg\"]', '木瓜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 110, 0, 0, NULL, NULL, NULL, 0, 1, 1, 1, '2026-05-15 17:59:14', '木瓜,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (121, 11, '牛奶葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/牛奶葡萄.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/牛奶葡萄.jpg\"]', '牛奶葡萄｜建议选择果粒饱满、果梗青绿的批次，甜度与汁水表现更稳定。适合鲜食或冷泡果饮，冷藏后口感更佳。', 12.80, 15.80, 120, '斤', 111, 0, 0, NULL, NULL, NULL, 0, 2, 1, 1, '2026-05-15 17:59:14', '牛奶葡萄,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (122, 11, '牛油果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/牛油果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/牛油果.jpg\"]', '牛油果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 112, 0, 0, NULL, NULL, NULL, 0, 3, 1, 1, '2026-05-15 17:59:14', '牛油果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (123, 11, '青提', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/青提.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/青提.jpg\"]', '青提｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 113, 0, 0, NULL, NULL, NULL, 0, 4, 1, 1, '2026-05-15 17:59:14', '青提,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (124, 11, '人参果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/人参果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/人参果.jpg\"]', '人参果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 114, 0, 0, NULL, NULL, NULL, 0, 5, 1, 1, '2026-05-15 17:59:14', '人参果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (125, 11, '软柿子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/软柿子.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/软柿子.jpg\"]', '软柿子｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 115, 0, 0, NULL, NULL, NULL, 0, 6, 1, 1, '2026-05-15 17:59:14', '软柿子,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (126, 11, '山竹', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/山竹.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/山竹.jpg\"]', '山竹｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 116, 0, 0, NULL, NULL, NULL, 0, 7, 1, 1, '2026-05-15 17:59:14', '山竹,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (127, 11, '圣女果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/圣女果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/圣女果.jpg\"]', '圣女果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 117, 0, 0, NULL, NULL, NULL, 0, 8, 1, 1, '2026-05-15 17:59:14', '圣女果,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (128, 11, '石榴', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/石榴.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/石榴.jpg\"]', '石榴｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 118, 0, 0, NULL, NULL, NULL, 0, 9, 1, 1, '2026-05-15 17:59:14', '石榴,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (129, 11, '树莓', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/树莓.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/树莓.jpg\"]', '树莓｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 119, 0, 0, NULL, NULL, NULL, 0, 10, 1, 1, '2026-05-15 17:59:14', '树莓,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (130, 11, '无核白葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/无核白葡萄.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/无核白葡萄.jpg\"]', '无核白葡萄｜建议选择果粒饱满、果梗青绿的批次，甜度与汁水表现更稳定。适合鲜食或冷泡果饮，冷藏后口感更佳。', 12.80, 15.80, 120, '斤', 120, 0, 0, NULL, NULL, NULL, 0, 11, 1, 1, '2026-05-15 17:59:14', '无核白葡萄,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (131, 11, '夏黑葡萄', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/夏黑葡萄.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/夏黑葡萄.jpg\"]', '夏黑葡萄｜建议选择果粒饱满、果梗青绿的批次，甜度与汁水表现更稳定。适合鲜食或冷泡果饮，冷藏后口感更佳。', 12.80, 15.80, 120, '斤', 121, 0, 0, NULL, NULL, NULL, 0, 12, 1, 1, '2026-05-15 17:59:14', '夏黑葡萄,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (132, 11, '香蕉', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/香蕉.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/香蕉.jpg\"]', '香蕉｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 122, 0, 0, NULL, NULL, NULL, 0, 13, 1, 1, '2026-05-15 17:59:14', '香蕉,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (133, 11, '小米蕉', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/小米蕉.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/小米蕉.jpg\"]', '小米蕉｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 123, 0, 0, NULL, NULL, NULL, 0, 14, 1, 1, '2026-05-15 17:59:14', '小米蕉,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (134, 11, '杨桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/杨桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/浆果类/杨桃.jpg\"]', '杨桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 124, 0, 0, NULL, NULL, NULL, 0, 15, 1, 1, '2026-05-15 17:59:14', '杨桃,云南,鲜食水果,新鲜,冷藏保存', '云南');
INSERT INTO `goods` VALUES (135, 12, '白心蜜柚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/白心蜜柚.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/白心蜜柚.jpg\"]', '白心蜜柚｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 125, 0, 0, NULL, NULL, NULL, 0, 16, 1, 1, '2026-05-15 17:59:14', '白心蜜柚,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (136, 12, '红西柚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/红西柚.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/红西柚.jpg\"]', '红西柚｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 126, 0, 0, NULL, NULL, NULL, 0, 17, 1, 1, '2026-05-15 17:59:14', '红西柚,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (137, 12, '红心柚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/红心柚.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/红心柚.jpg\"]', '红心柚｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 127, 0, 0, NULL, NULL, NULL, 0, 18, 1, 1, '2026-05-15 17:59:14', '红心柚,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (138, 12, '黄心柚', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/黄心柚.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/黄心柚.jpg\"]', '黄心柚｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 128, 0, 0, NULL, NULL, NULL, 0, 19, 1, 1, '2026-05-15 17:59:14', '黄心柚,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (139, 12, '金桔', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/金桔.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/金桔.jpg\"]', '金桔｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 129, 0, 0, NULL, NULL, NULL, 0, 20, 1, 1, '2026-05-15 17:59:14', '金桔,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (140, 12, '橘子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橘子.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/橘子.jpg\"]', '橘子｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 130, 0, 0, NULL, NULL, NULL, 0, 21, 1, 1, '2026-05-15 17:59:14', '橘子,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (141, 12, '青柠', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/青柠.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/青柠.jpg\"]', '青柠｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 131, 0, 0, NULL, NULL, NULL, 0, 22, 1, 1, '2026-05-15 17:59:14', '青柠,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (142, 12, '砂糖橘', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/砂糖橘.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/砂糖橘.jpg\"]', '砂糖橘｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 132, 0, 0, NULL, NULL, NULL, 0, 23, 1, 1, '2026-05-15 17:59:14', '砂糖橘,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (143, 12, '小青桔', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/小青桔.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/小青桔.jpg\"]', '小青桔｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 133, 0, 0, NULL, NULL, NULL, 0, 24, 1, 1, '2026-05-15 17:59:14', '小青桔,广西,鲜食水果,新鲜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (144, 12, '血橙', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/血橙.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/柑橘类/血橙.jpg\"]', '血橙｜柑橘类适合补充维C，鲜食与榨汁都合适。建议置于阴凉通风处短存，需久放可冷藏并尽量分批取用。', 12.80, 15.80, 120, '斤', 134, 1, 0, NULL, NULL, NULL, 0, 25, 1, 1, '2026-05-15 17:59:14', '血橙,广西,鲜食水果,清甜,冷藏保存', '广西');
INSERT INTO `goods` VALUES (145, 13, '刺角瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/刺角瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/刺角瓜.jpg\"]', '刺角瓜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 135, 0, 0, NULL, NULL, NULL, 0, 26, 1, 1, '2026-05-15 17:59:14', '刺角瓜,海南,鲜食水果,新鲜,冷藏保存', '海南');
INSERT INTO `goods` VALUES (146, 13, '黄瓤西瓜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/黄瓤西瓜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/黄瓤西瓜.jpg\"]', '黄瓤西瓜｜瓜类建议按需购买，切开后请及时冷藏并覆盖保鲜。适合夏季鲜食、果盘与轻饮，口感以清甜多汁为主。', 12.80, 15.80, 120, '斤', 136, 0, 0, NULL, NULL, NULL, 0, 27, 1, 1, '2026-05-15 17:59:14', '黄瓤西瓜,海南,鲜食水果,新鲜,冷藏保存', '海南');
INSERT INTO `goods` VALUES (147, 13, '羊角蜜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/羊角蜜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/瓜类/羊角蜜.jpg\"]', '羊角蜜｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 137, 0, 0, NULL, NULL, NULL, 0, 28, 1, 1, '2026-05-15 17:59:14', '羊角蜜,海南,鲜食水果,新鲜,冷藏保存', '海南');
INSERT INTO `goods` VALUES (148, 14, '脆李', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/脆李.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/脆李.jpg\"]', '脆李｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 138, 0, 0, NULL, NULL, NULL, 0, 29, 1, 1, '2026-05-15 17:59:14', '脆李,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (149, 14, '冬枣', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/冬枣.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/冬枣.jpg\"]', '冬枣｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 139, 0, 0, NULL, NULL, NULL, 0, 30, 1, 1, '2026-05-15 17:59:14', '冬枣,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (150, 14, '贵妃芒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/贵妃芒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/贵妃芒.jpg\"]', '贵妃芒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 140, 0, 0, NULL, NULL, NULL, 0, 31, 1, 1, '2026-05-15 17:59:14', '贵妃芒,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (151, 14, '红毛丹', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/红毛丹.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/红毛丹.jpg\"]', '红毛丹｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 141, 0, 0, NULL, NULL, NULL, 0, 32, 1, 1, '2026-05-15 17:59:14', '红毛丹,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (152, 14, '红枣', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/红枣.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/红枣.jpg\"]', '红枣｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 142, 0, 0, NULL, NULL, NULL, 0, 33, 1, 1, '2026-05-15 17:59:14', '红枣,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (153, 14, '黄杏', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黄杏.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黄杏.jpg\"]', '黄杏｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 143, 0, 0, NULL, NULL, NULL, 0, 34, 1, 1, '2026-05-15 17:59:14', '黄杏,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (154, 14, '黄樱桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黄樱桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/黄樱桃.jpg\"]', '黄樱桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 144, 1, 0, NULL, NULL, NULL, 0, 35, 1, 1, '2026-05-15 17:59:14', '黄樱桃,四川,鲜食水果,酸甜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (155, 14, '金煌芒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/金煌芒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/金煌芒.jpg\"]', '金煌芒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 145, 0, 0, NULL, NULL, NULL, 0, 36, 1, 1, '2026-05-15 17:59:14', '金煌芒,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (156, 14, '荔枝', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/荔枝.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/荔枝.jpg\"]', '荔枝｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 146, 0, 0, NULL, NULL, NULL, 0, 37, 1, 1, '2026-05-15 17:59:14', '荔枝,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (157, 14, '榴莲', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/榴莲.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/榴莲.jpg\"]', '榴莲｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 147, 0, 0, NULL, NULL, NULL, 0, 38, 1, 1, '2026-05-15 17:59:14', '榴莲,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (158, 14, '龙眼', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/龙眼.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/龙眼.jpg\"]', '龙眼｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 148, 0, 0, NULL, NULL, NULL, 0, 39, 1, 1, '2026-05-15 17:59:14', '龙眼,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (159, 14, '牛奶青枣', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/牛奶青枣.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/牛奶青枣.jpg\"]', '牛奶青枣｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 149, 0, 0, NULL, NULL, NULL, 0, 40, 1, 1, '2026-05-15 17:59:14', '牛奶青枣,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (160, 14, '蟠桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/蟠桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/蟠桃.jpg\"]', '蟠桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 70, 0, 0, NULL, NULL, NULL, 0, 41, 1, 1, '2026-05-15 17:59:14', '蟠桃,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (161, 14, '苹果李', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/苹果李.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/苹果李.jpg\"]', '苹果李｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 71, 1, 0, NULL, NULL, NULL, 0, 42, 1, 1, '2026-05-15 17:59:14', '苹果李,四川,鲜食水果,清甜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (162, 14, '青芒果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/青芒果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/青芒果.jpg\"]', '青芒果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 72, 0, 0, NULL, NULL, NULL, 0, 43, 1, 1, '2026-05-15 17:59:14', '青芒果,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (163, 14, '蛇皮果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/蛇皮果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/蛇皮果.jpg\"]', '蛇皮果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 73, 0, 0, NULL, NULL, NULL, 0, 44, 1, 1, '2026-05-15 17:59:14', '蛇皮果,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (164, 14, '释迦果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/释迦果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/释迦果.jpg\"]', '释迦果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 74, 0, 0, NULL, NULL, NULL, 0, 45, 1, 1, '2026-05-15 17:59:14', '释迦果,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (165, 14, '西梅', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/西梅.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/西梅.jpg\"]', '西梅｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 75, 0, 0, NULL, NULL, NULL, 0, 46, 1, 1, '2026-05-15 17:59:14', '西梅,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (166, 14, '小台芒', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/小台芒.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/小台芒.jpg\"]', '小台芒｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 76, 0, 0, NULL, NULL, NULL, 0, 47, 1, 1, '2026-05-15 17:59:14', '小台芒,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (167, 14, '杨梅', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/杨梅.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/杨梅.jpg\"]', '杨梅｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 77, 0, 0, NULL, NULL, NULL, 0, 48, 1, 1, '2026-05-15 17:59:14', '杨梅,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (168, 14, '椰子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/椰子.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/椰子.jpg\"]', '椰子｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 78, 0, 0, NULL, NULL, NULL, 0, 49, 1, 1, '2026-05-15 17:59:14', '椰子,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (169, 14, '樱桃李', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/樱桃李.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/樱桃李.jpg\"]', '樱桃李｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 79, 1, 0, NULL, NULL, NULL, 0, 50, 1, 1, '2026-05-15 17:59:14', '樱桃李,四川,鲜食水果,酸甜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (170, 14, '油柑子', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/油柑子.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/油柑子.jpg\"]', '油柑子｜柑橘类适合补充维C，鲜食与榨汁都合适。建议置于阴凉通风处短存，需久放可冷藏并尽量分批取用。', 12.80, 15.80, 120, '斤', 80, 0, 0, NULL, NULL, NULL, 0, 51, 1, 1, '2026-05-15 17:59:14', '油柑子,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (171, 14, '油奈', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/油奈.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/油奈.jpg\"]', '油奈｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 81, 0, 0, NULL, NULL, NULL, 0, 52, 1, 1, '2026-05-15 17:59:14', '油奈,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (172, 14, '油桃', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/油桃.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/核果类/油桃.jpg\"]', '油桃｜核果类建议观察果面完整度与成熟度分层食用。可鲜食或做冷萃果饮，成熟果建议冷藏并尽快食用。', 12.80, 15.80, 120, '斤', 82, 0, 0, NULL, NULL, NULL, 0, 53, 1, 1, '2026-05-15 17:59:14', '油桃,四川,鲜食水果,新鲜,冷藏保存', '四川');
INSERT INTO `goods` VALUES (173, 15, '阿克苏苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/阿克苏苹果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/阿克苏苹果.jpg\"]', '阿克苏苹果｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 83, 1, 0, NULL, NULL, NULL, 0, 54, 1, 1, '2026-05-15 17:59:14', '阿克苏苹果,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (174, 15, '丰水梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/丰水梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/丰水梨.jpg\"]', '丰水梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 84, 1, 0, NULL, NULL, NULL, 0, 55, 1, 1, '2026-05-15 17:59:14', '丰水梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (175, 15, '嘎啦苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/嘎啦苹果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/嘎啦苹果.jpg\"]', '嘎啦苹果｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 85, 1, 0, NULL, NULL, NULL, 0, 56, 1, 1, '2026-05-15 17:59:14', '嘎啦苹果,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (176, 15, '红地厘蛇果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红地厘蛇果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红地厘蛇果.jpg\"]', '红地厘蛇果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 86, 0, 0, NULL, NULL, NULL, 0, 57, 1, 1, '2026-05-15 17:59:14', '红地厘蛇果,山东,鲜食水果,新鲜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (177, 15, '红香酥梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红香酥梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红香酥梨.jpg\"]', '红香酥梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 87, 1, 0, NULL, NULL, NULL, 0, 58, 1, 1, '2026-05-15 17:59:14', '红香酥梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (178, 15, '黄元帅苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/黄元帅苹果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/黄元帅苹果.jpg\"]', '黄元帅苹果｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 88, 1, 0, NULL, NULL, NULL, 0, 59, 1, 1, '2026-05-15 17:59:14', '黄元帅苹果,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (179, 15, '库尔勒香梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/库尔勒香梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/库尔勒香梨.jpg\"]', '库尔勒香梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 89, 1, 0, NULL, NULL, NULL, 0, 60, 1, 1, '2026-05-15 17:59:14', '库尔勒香梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (180, 15, '奶油苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/奶油苹果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/奶油苹果.jpg\"]', '奶油苹果｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 90, 1, 0, NULL, NULL, NULL, 0, 1, 1, 1, '2026-05-15 17:59:14', '奶油苹果,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (181, 15, '青苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/青苹果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/青苹果.jpg\"]', '青苹果｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 91, 1, 0, NULL, NULL, NULL, 0, 2, 1, 1, '2026-05-15 17:59:14', '青苹果,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (182, 15, '秋月梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/秋月梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/秋月梨.jpg\"]', '秋月梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 92, 1, 0, NULL, NULL, NULL, 0, 3, 1, 1, '2026-05-15 17:59:14', '秋月梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (183, 15, '山楂', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/山楂.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/山楂.jpg\"]', '山楂｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 93, 0, 0, NULL, NULL, NULL, 0, 4, 1, 1, '2026-05-15 17:59:14', '山楂,山东,鲜食水果,新鲜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (184, 15, '香酥梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/香酥梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/香酥梨.jpg\"]', '香酥梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 94, 1, 0, NULL, NULL, NULL, 0, 5, 1, 1, '2026-05-15 17:59:14', '香酥梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (185, 15, '雪花梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/雪花梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/雪花梨.jpg\"]', '雪花梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 95, 1, 0, NULL, NULL, NULL, 0, 6, 1, 1, '2026-05-15 17:59:14', '雪花梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (186, 15, '鸭梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/鸭梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/鸭梨.jpg\"]', '鸭梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 96, 1, 0, NULL, NULL, NULL, 0, 7, 1, 1, '2026-05-15 17:59:14', '鸭梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (187, 15, '早酥梨', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/早酥梨.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/早酥梨.jpg\"]', '早酥梨｜仁果类储存稳定，适合作为日常家庭常备水果。可直接鲜食、榨汁或做早餐拼盘，建议避潮保存。', 12.80, 15.80, 120, '斤', 97, 1, 0, NULL, NULL, NULL, 0, 8, 1, 1, '2026-05-15 17:59:14', '早酥梨,山东,鲜食水果,清甜,冷藏保存', '山东');
INSERT INTO `goods` VALUES (188, 16, '菠萝蜜', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝蜜.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/菠萝蜜.jpg\"]', '菠萝蜜｜该品类风味层次明显，适合鲜食、轻甜品或沙拉搭配。建议低温保鲜并避免长时间挤压。', 12.80, 15.80, 120, '斤', 98, 0, 0, NULL, NULL, NULL, 0, 9, 1, 1, '2026-05-15 17:59:14', '菠萝蜜,福建,鲜食水果,新鲜,冷藏保存', '福建');
INSERT INTO `goods` VALUES (189, 16, '甘蔗', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/甘蔗.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/甘蔗.jpg\"]', '甘蔗｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 99, 0, 0, NULL, NULL, NULL, 0, 10, 1, 1, '2026-05-15 17:59:14', '甘蔗,福建,鲜食水果,新鲜,冷藏保存', '福建');
INSERT INTO `goods` VALUES (190, 16, '雪莲果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/雪莲果.jpg', '[\"cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/聚花果及其他/雪莲果.jpg\"]', '雪莲果｜鲜时刻严选产地批次，适合家庭日常烹饪与一人食搭配。建议按到货批次分层存放，并在新鲜窗口内食用。', 12.80, 15.80, 120, '斤', 100, 0, 0, NULL, NULL, NULL, 0, 11, 1, 1, '2026-05-15 17:59:14', '雪莲果,福建,鲜食水果,新鲜,冷藏保存', '福建');

-- ----------------------------
-- Table structure for goods_sku
-- ----------------------------
DROP TABLE IF EXISTS `goods_sku`;
CREATE TABLE `goods_sku`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `goods_id` bigint(20) NOT NULL,
  `sku_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '规格名称，如250g/盒',
  `sku_weight_g` int(11) NULL DEFAULT NULL COMMENT '规格重量(g)',
  `sku_price` decimal(10, 2) NOT NULL,
  `sku_stock` int(11) NOT NULL DEFAULT 0,
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1启用 0停用',
  `sort` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_goods_id`(`goods_id`) USING BTREE,
  CONSTRAINT `fk_goods_sku_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 256 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '商品SKU规格表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of goods_sku
-- ----------------------------
INSERT INTO `goods_sku` VALUES (1, 1, '标准装', 500, 25.80, 84, 1, 0);
INSERT INTO `goods_sku` VALUES (2, 2, '标准装', 500, 38.80, 72, 1, 0);
INSERT INTO `goods_sku` VALUES (3, 3, '标准装', 500, 18.80, 137, 1, 0);
INSERT INTO `goods_sku` VALUES (4, 4, '标准装', 500, 8.80, 299, 1, 0);
INSERT INTO `goods_sku` VALUES (5, 5, '标准装', 500, 7.50, 247, 1, 0);
INSERT INTO `goods_sku` VALUES (6, 6, '标准装', 500, 6.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (7, 7, '标准装', 500, 3.80, 300, 1, 0);
INSERT INTO `goods_sku` VALUES (8, 8, '标准装', 500, 8.80, 150, 1, 0);
INSERT INTO `goods_sku` VALUES (9, 9, '标准装', 500, 6.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (10, 10, '标准装', 500, 18.80, 119, 1, 0);
INSERT INTO `goods_sku` VALUES (11, 11, '标准装', 500, 12.80, 150, 1, 0);
INSERT INTO `goods_sku` VALUES (12, 12, '标准装', 500, 48.80, 60, 1, 0);
INSERT INTO `goods_sku` VALUES (13, 13, '标准装', 500, 9.80, 298, 1, 0);
INSERT INTO `goods_sku` VALUES (14, 14, '标准装', 500, 7.80, 250, 1, 0);
INSERT INTO `goods_sku` VALUES (15, 15, '标准装', 500, 8.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (16, 16, '标准装', 500, 12.80, 100, 1, 0);
INSERT INTO `goods_sku` VALUES (17, 17, '标准装', 500, 22.80, 60, 1, 0);
INSERT INTO `goods_sku` VALUES (18, 18, '标准装', 500, 15.80, 76, 1, 0);
INSERT INTO `goods_sku` VALUES (19, 19, '标准装', 500, 8.60, 170, 1, 0);
INSERT INTO `goods_sku` VALUES (20, 20, '标准装', 500, 8.60, 170, 1, 0);
INSERT INTO `goods_sku` VALUES (21, 21, '标准装', 500, 8.60, 170, 1, 0);
INSERT INTO `goods_sku` VALUES (22, 22, '标准装', 500, 8.60, 170, 1, 0);
INSERT INTO `goods_sku` VALUES (23, 23, '标准装', 500, 8.60, 170, 1, 0);
INSERT INTO `goods_sku` VALUES (24, 24, '标准装', 500, 8.60, 170, 1, 0);
INSERT INTO `goods_sku` VALUES (25, 25, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (26, 26, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (27, 27, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (28, 28, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (29, 29, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (30, 30, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (31, 31, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (32, 32, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (33, 33, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (34, 34, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (35, 35, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (36, 36, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (37, 37, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (38, 38, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (39, 39, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (40, 40, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (41, 41, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (42, 42, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (43, 43, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (44, 44, '标准装', 500, 6.80, 220, 1, 0);
INSERT INTO `goods_sku` VALUES (45, 45, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (46, 46, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (47, 47, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (48, 48, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (49, 49, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (50, 50, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (51, 51, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (52, 52, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (53, 53, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (54, 54, '标准装', 500, 6.20, 210, 1, 0);
INSERT INTO `goods_sku` VALUES (55, 55, '标准装', 500, 7.20, 190, 1, 0);
INSERT INTO `goods_sku` VALUES (56, 56, '标准装', 500, 7.20, 190, 1, 0);
INSERT INTO `goods_sku` VALUES (57, 57, '标准装', 500, 7.20, 190, 1, 0);
INSERT INTO `goods_sku` VALUES (58, 58, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (59, 59, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (60, 60, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (61, 61, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (62, 62, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (63, 63, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (64, 64, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (65, 65, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (66, 66, '标准装', 500, 9.80, 160, 1, 0);
INSERT INTO `goods_sku` VALUES (67, 67, '标准装', 500, 6.60, 150, 1, 0);
INSERT INTO `goods_sku` VALUES (68, 68, '标准装', 500, 6.60, 150, 1, 0);
INSERT INTO `goods_sku` VALUES (69, 69, '标准装', 500, 6.60, 150, 1, 0);
INSERT INTO `goods_sku` VALUES (70, 70, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (71, 71, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (72, 72, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (73, 73, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (74, 74, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (75, 75, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (76, 76, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (77, 77, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (78, 78, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (79, 79, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (80, 80, '标准装', 500, 7.80, 200, 1, 0);
INSERT INTO `goods_sku` VALUES (81, 81, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (82, 82, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (83, 83, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (84, 84, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (85, 85, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (86, 86, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (87, 87, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (88, 88, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (89, 89, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (90, 90, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (91, 91, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (92, 92, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (93, 93, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (94, 94, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (95, 95, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (96, 96, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (97, 97, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (98, 98, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (99, 99, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (100, 100, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (101, 101, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (102, 102, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (103, 103, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (104, 104, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (105, 105, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (106, 106, '标准装', 500, 5.80, 180, 1, 0);
INSERT INTO `goods_sku` VALUES (107, 107, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (108, 108, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (109, 109, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (110, 110, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (111, 111, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (112, 112, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (113, 113, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (114, 114, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (115, 115, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (116, 116, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (117, 117, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (118, 118, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (119, 119, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (120, 120, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (121, 121, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (122, 122, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (123, 123, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (124, 124, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (125, 125, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (126, 126, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (127, 127, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (128, 128, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (129, 129, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (130, 130, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (131, 131, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (132, 132, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (133, 133, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (134, 134, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (135, 135, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (136, 136, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (137, 137, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (138, 138, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (139, 139, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (140, 140, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (141, 141, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (142, 142, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (143, 143, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (144, 144, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (145, 145, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (146, 146, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (147, 147, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (148, 148, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (149, 149, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (150, 150, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (151, 151, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (152, 152, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (153, 153, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (154, 154, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (155, 155, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (156, 156, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (157, 157, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (158, 158, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (159, 159, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (160, 160, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (161, 161, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (162, 162, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (163, 163, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (164, 164, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (165, 165, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (166, 166, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (167, 167, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (168, 168, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (169, 169, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (170, 170, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (171, 171, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (172, 172, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (173, 173, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (174, 174, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (175, 175, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (176, 176, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (177, 177, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (178, 178, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (179, 179, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (180, 180, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (181, 181, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (182, 182, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (183, 183, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (184, 184, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (185, 185, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (186, 186, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (187, 187, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (188, 188, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (189, 189, '标准装', 500, 12.80, 120, 1, 0);
INSERT INTO `goods_sku` VALUES (190, 190, '标准装', 500, 12.80, 120, 1, 0);

-- ----------------------------
-- Table structure for goods_tag
-- ----------------------------
DROP TABLE IF EXISTS `goods_tag`;
CREATE TABLE `goods_tag`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `goods_id` bigint(20) NOT NULL,
  `tag_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_goods_tag_goods_tag`(`goods_id`, `tag_id`) USING BTREE,
  INDEX `fk_goods_tag_tag`(`tag_id`) USING BTREE,
  CONSTRAINT `fk_goods_tag_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_goods_tag_tag` FOREIGN KEY (`tag_id`) REFERENCES `tag` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 296 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of goods_tag
-- ----------------------------
INSERT INTO `goods_tag` VALUES (1, 1, 101);
INSERT INTO `goods_tag` VALUES (291, 1, 102);
INSERT INTO `goods_tag` VALUES (276, 2, 101);
INSERT INTO `goods_tag` VALUES (9, 2, 102);
INSERT INTO `goods_tag` VALUES (277, 3, 101);
INSERT INTO `goods_tag` VALUES (292, 3, 102);
INSERT INTO `goods_tag` VALUES (17, 3, 103);
INSERT INTO `goods_tag` VALUES (2, 4, 101);
INSERT INTO `goods_tag` VALUES (278, 5, 101);
INSERT INTO `goods_tag` VALUES (18, 5, 103);
INSERT INTO `goods_tag` VALUES (279, 6, 101);
INSERT INTO `goods_tag` VALUES (10, 6, 102);
INSERT INTO `goods_tag` VALUES (280, 7, 101);
INSERT INTO `goods_tag` VALUES (281, 8, 101);
INSERT INTO `goods_tag` VALUES (282, 9, 101);
INSERT INTO `goods_tag` VALUES (19, 9, 103);
INSERT INTO `goods_tag` VALUES (3, 10, 101);
INSERT INTO `goods_tag` VALUES (283, 11, 101);
INSERT INTO `goods_tag` VALUES (20, 11, 103);
INSERT INTO `goods_tag` VALUES (284, 12, 101);
INSERT INTO `goods_tag` VALUES (11, 12, 102);
INSERT INTO `goods_tag` VALUES (4, 13, 101);
INSERT INTO `goods_tag` VALUES (294, 13, 103);
INSERT INTO `goods_tag` VALUES (285, 14, 101);
INSERT INTO `goods_tag` VALUES (21, 14, 103);
INSERT INTO `goods_tag` VALUES (286, 15, 101);
INSERT INTO `goods_tag` VALUES (295, 15, 103);
INSERT INTO `goods_tag` VALUES (287, 16, 101);
INSERT INTO `goods_tag` VALUES (22, 16, 103);
INSERT INTO `goods_tag` VALUES (288, 17, 101);
INSERT INTO `goods_tag` VALUES (289, 18, 101);
INSERT INTO `goods_tag` VALUES (12, 18, 102);
INSERT INTO `goods_tag` VALUES (23, 19, 101);
INSERT INTO `goods_tag` VALUES (150, 19, 102);
INSERT INTO `goods_tag` VALUES (213, 19, 103);
INSERT INTO `goods_tag` VALUES (24, 20, 101);
INSERT INTO `goods_tag` VALUES (151, 20, 102);
INSERT INTO `goods_tag` VALUES (214, 20, 103);
INSERT INTO `goods_tag` VALUES (25, 21, 101);
INSERT INTO `goods_tag` VALUES (152, 21, 102);
INSERT INTO `goods_tag` VALUES (215, 21, 103);
INSERT INTO `goods_tag` VALUES (26, 22, 101);
INSERT INTO `goods_tag` VALUES (153, 22, 102);
INSERT INTO `goods_tag` VALUES (216, 22, 103);
INSERT INTO `goods_tag` VALUES (27, 23, 101);
INSERT INTO `goods_tag` VALUES (154, 23, 102);
INSERT INTO `goods_tag` VALUES (217, 23, 103);
INSERT INTO `goods_tag` VALUES (28, 24, 101);
INSERT INTO `goods_tag` VALUES (155, 24, 102);
INSERT INTO `goods_tag` VALUES (218, 24, 103);
INSERT INTO `goods_tag` VALUES (29, 25, 101);
INSERT INTO `goods_tag` VALUES (219, 25, 103);
INSERT INTO `goods_tag` VALUES (30, 26, 101);
INSERT INTO `goods_tag` VALUES (220, 26, 103);
INSERT INTO `goods_tag` VALUES (31, 27, 101);
INSERT INTO `goods_tag` VALUES (221, 27, 103);
INSERT INTO `goods_tag` VALUES (32, 28, 101);
INSERT INTO `goods_tag` VALUES (222, 28, 103);
INSERT INTO `goods_tag` VALUES (33, 29, 101);
INSERT INTO `goods_tag` VALUES (223, 29, 103);
INSERT INTO `goods_tag` VALUES (34, 30, 101);
INSERT INTO `goods_tag` VALUES (224, 30, 103);
INSERT INTO `goods_tag` VALUES (35, 31, 101);
INSERT INTO `goods_tag` VALUES (225, 31, 103);
INSERT INTO `goods_tag` VALUES (36, 32, 101);
INSERT INTO `goods_tag` VALUES (226, 32, 103);
INSERT INTO `goods_tag` VALUES (37, 33, 101);
INSERT INTO `goods_tag` VALUES (227, 33, 103);
INSERT INTO `goods_tag` VALUES (38, 34, 101);
INSERT INTO `goods_tag` VALUES (228, 34, 103);
INSERT INTO `goods_tag` VALUES (39, 35, 101);
INSERT INTO `goods_tag` VALUES (229, 35, 103);
INSERT INTO `goods_tag` VALUES (40, 36, 101);
INSERT INTO `goods_tag` VALUES (230, 36, 103);
INSERT INTO `goods_tag` VALUES (41, 37, 101);
INSERT INTO `goods_tag` VALUES (231, 37, 103);
INSERT INTO `goods_tag` VALUES (42, 38, 101);
INSERT INTO `goods_tag` VALUES (232, 38, 103);
INSERT INTO `goods_tag` VALUES (43, 39, 101);
INSERT INTO `goods_tag` VALUES (233, 39, 103);
INSERT INTO `goods_tag` VALUES (44, 40, 101);
INSERT INTO `goods_tag` VALUES (234, 40, 103);
INSERT INTO `goods_tag` VALUES (45, 41, 101);
INSERT INTO `goods_tag` VALUES (235, 41, 103);
INSERT INTO `goods_tag` VALUES (46, 42, 101);
INSERT INTO `goods_tag` VALUES (236, 42, 103);
INSERT INTO `goods_tag` VALUES (47, 43, 101);
INSERT INTO `goods_tag` VALUES (237, 43, 103);
INSERT INTO `goods_tag` VALUES (48, 44, 101);
INSERT INTO `goods_tag` VALUES (238, 44, 103);
INSERT INTO `goods_tag` VALUES (49, 45, 101);
INSERT INTO `goods_tag` VALUES (239, 45, 103);
INSERT INTO `goods_tag` VALUES (50, 46, 101);
INSERT INTO `goods_tag` VALUES (240, 46, 103);
INSERT INTO `goods_tag` VALUES (51, 47, 101);
INSERT INTO `goods_tag` VALUES (241, 47, 103);
INSERT INTO `goods_tag` VALUES (52, 48, 101);
INSERT INTO `goods_tag` VALUES (242, 48, 103);
INSERT INTO `goods_tag` VALUES (53, 49, 101);
INSERT INTO `goods_tag` VALUES (243, 49, 103);
INSERT INTO `goods_tag` VALUES (54, 50, 101);
INSERT INTO `goods_tag` VALUES (244, 50, 103);
INSERT INTO `goods_tag` VALUES (55, 51, 101);
INSERT INTO `goods_tag` VALUES (245, 51, 103);
INSERT INTO `goods_tag` VALUES (56, 52, 101);
INSERT INTO `goods_tag` VALUES (246, 52, 103);
INSERT INTO `goods_tag` VALUES (57, 53, 101);
INSERT INTO `goods_tag` VALUES (247, 53, 103);
INSERT INTO `goods_tag` VALUES (58, 54, 101);
INSERT INTO `goods_tag` VALUES (248, 54, 103);
INSERT INTO `goods_tag` VALUES (59, 55, 101);
INSERT INTO `goods_tag` VALUES (249, 55, 103);
INSERT INTO `goods_tag` VALUES (60, 56, 101);
INSERT INTO `goods_tag` VALUES (250, 56, 103);
INSERT INTO `goods_tag` VALUES (61, 57, 101);
INSERT INTO `goods_tag` VALUES (251, 57, 103);
INSERT INTO `goods_tag` VALUES (62, 58, 101);
INSERT INTO `goods_tag` VALUES (156, 58, 102);
INSERT INTO `goods_tag` VALUES (63, 59, 101);
INSERT INTO `goods_tag` VALUES (157, 59, 102);
INSERT INTO `goods_tag` VALUES (64, 60, 101);
INSERT INTO `goods_tag` VALUES (158, 60, 102);
INSERT INTO `goods_tag` VALUES (65, 61, 101);
INSERT INTO `goods_tag` VALUES (159, 61, 102);
INSERT INTO `goods_tag` VALUES (66, 62, 101);
INSERT INTO `goods_tag` VALUES (160, 62, 102);
INSERT INTO `goods_tag` VALUES (67, 63, 101);
INSERT INTO `goods_tag` VALUES (161, 63, 102);
INSERT INTO `goods_tag` VALUES (68, 64, 101);
INSERT INTO `goods_tag` VALUES (162, 64, 102);
INSERT INTO `goods_tag` VALUES (69, 65, 101);
INSERT INTO `goods_tag` VALUES (163, 65, 102);
INSERT INTO `goods_tag` VALUES (70, 66, 101);
INSERT INTO `goods_tag` VALUES (164, 66, 102);
INSERT INTO `goods_tag` VALUES (71, 67, 101);
INSERT INTO `goods_tag` VALUES (165, 67, 102);
INSERT INTO `goods_tag` VALUES (72, 68, 101);
INSERT INTO `goods_tag` VALUES (166, 68, 102);
INSERT INTO `goods_tag` VALUES (73, 69, 101);
INSERT INTO `goods_tag` VALUES (167, 69, 102);
INSERT INTO `goods_tag` VALUES (74, 70, 101);
INSERT INTO `goods_tag` VALUES (252, 70, 103);
INSERT INTO `goods_tag` VALUES (75, 71, 101);
INSERT INTO `goods_tag` VALUES (253, 71, 103);
INSERT INTO `goods_tag` VALUES (76, 72, 101);
INSERT INTO `goods_tag` VALUES (254, 72, 103);
INSERT INTO `goods_tag` VALUES (77, 73, 101);
INSERT INTO `goods_tag` VALUES (255, 73, 103);
INSERT INTO `goods_tag` VALUES (78, 74, 101);
INSERT INTO `goods_tag` VALUES (256, 74, 103);
INSERT INTO `goods_tag` VALUES (79, 75, 101);
INSERT INTO `goods_tag` VALUES (257, 75, 103);
INSERT INTO `goods_tag` VALUES (80, 76, 101);
INSERT INTO `goods_tag` VALUES (258, 76, 103);
INSERT INTO `goods_tag` VALUES (81, 77, 101);
INSERT INTO `goods_tag` VALUES (259, 77, 103);
INSERT INTO `goods_tag` VALUES (82, 78, 101);
INSERT INTO `goods_tag` VALUES (260, 78, 103);
INSERT INTO `goods_tag` VALUES (83, 79, 101);
INSERT INTO `goods_tag` VALUES (261, 79, 103);
INSERT INTO `goods_tag` VALUES (84, 80, 101);
INSERT INTO `goods_tag` VALUES (262, 80, 103);
INSERT INTO `goods_tag` VALUES (85, 81, 101);
INSERT INTO `goods_tag` VALUES (168, 81, 102);
INSERT INTO `goods_tag` VALUES (86, 82, 101);
INSERT INTO `goods_tag` VALUES (169, 82, 102);
INSERT INTO `goods_tag` VALUES (87, 83, 101);
INSERT INTO `goods_tag` VALUES (170, 83, 102);
INSERT INTO `goods_tag` VALUES (88, 84, 101);
INSERT INTO `goods_tag` VALUES (171, 84, 102);
INSERT INTO `goods_tag` VALUES (89, 85, 101);
INSERT INTO `goods_tag` VALUES (172, 85, 102);
INSERT INTO `goods_tag` VALUES (90, 86, 101);
INSERT INTO `goods_tag` VALUES (173, 86, 102);
INSERT INTO `goods_tag` VALUES (91, 87, 101);
INSERT INTO `goods_tag` VALUES (174, 87, 102);
INSERT INTO `goods_tag` VALUES (92, 88, 101);
INSERT INTO `goods_tag` VALUES (175, 88, 102);
INSERT INTO `goods_tag` VALUES (93, 89, 101);
INSERT INTO `goods_tag` VALUES (176, 89, 102);
INSERT INTO `goods_tag` VALUES (94, 90, 101);
INSERT INTO `goods_tag` VALUES (177, 90, 102);
INSERT INTO `goods_tag` VALUES (95, 91, 101);
INSERT INTO `goods_tag` VALUES (178, 91, 102);
INSERT INTO `goods_tag` VALUES (96, 92, 101);
INSERT INTO `goods_tag` VALUES (179, 92, 102);
INSERT INTO `goods_tag` VALUES (97, 93, 101);
INSERT INTO `goods_tag` VALUES (180, 93, 102);
INSERT INTO `goods_tag` VALUES (98, 94, 101);
INSERT INTO `goods_tag` VALUES (181, 94, 102);
INSERT INTO `goods_tag` VALUES (99, 95, 101);
INSERT INTO `goods_tag` VALUES (182, 95, 102);
INSERT INTO `goods_tag` VALUES (100, 96, 101);
INSERT INTO `goods_tag` VALUES (183, 96, 102);
INSERT INTO `goods_tag` VALUES (101, 97, 101);
INSERT INTO `goods_tag` VALUES (184, 97, 102);
INSERT INTO `goods_tag` VALUES (102, 98, 101);
INSERT INTO `goods_tag` VALUES (185, 98, 102);
INSERT INTO `goods_tag` VALUES (103, 99, 101);
INSERT INTO `goods_tag` VALUES (186, 99, 102);
INSERT INTO `goods_tag` VALUES (104, 100, 101);
INSERT INTO `goods_tag` VALUES (187, 100, 102);
INSERT INTO `goods_tag` VALUES (105, 101, 101);
INSERT INTO `goods_tag` VALUES (188, 101, 102);
INSERT INTO `goods_tag` VALUES (106, 102, 101);
INSERT INTO `goods_tag` VALUES (189, 102, 102);
INSERT INTO `goods_tag` VALUES (107, 103, 101);
INSERT INTO `goods_tag` VALUES (190, 103, 102);
INSERT INTO `goods_tag` VALUES (108, 104, 101);
INSERT INTO `goods_tag` VALUES (191, 104, 102);
INSERT INTO `goods_tag` VALUES (109, 105, 101);
INSERT INTO `goods_tag` VALUES (192, 105, 102);
INSERT INTO `goods_tag` VALUES (110, 106, 101);
INSERT INTO `goods_tag` VALUES (193, 106, 102);

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
INSERT INTO `home_nav` VALUES (1, 'couponZone', '领券专区', '券', 'goods', 'coupon', 1, 1, '2026-05-09 17:08:18');
INSERT INTO `home_nav` VALUES (2, 'seasonalFresh', '时令蔬果', '时', 'search', '时令', 2, 1, '2026-05-09 17:08:18');
INSERT INTO `home_nav` VALUES (3, 'smallPortion', '小份量专区', '小', 'scene', '小份量', 3, 1, '2026-05-09 17:08:18');
INSERT INTO `home_nav` VALUES (4, 'comboMix', '蔬果搭配', '搭', 'scene', '搭配', 4, 1, '2026-05-09 17:08:18');

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
-- Table structure for order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '订单ID',
  `order_no` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '订单号',
  `user_id` bigint(20) NOT NULL COMMENT '用户ID',
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
  INDEX `idx_status`(`status`) USING BTREE,
  INDEX `fk_order_coupon`(`coupon_id`) USING BTREE,
  CONSTRAINT `fk_order_coupon` FOREIGN KEY (`coupon_id`) REFERENCES `coupon` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order
-- ----------------------------
INSERT INTO `order` VALUES (1, 'FT17788346660040A8048', 1, 9.80, 0.00, 9.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-05-15 16:44:26');
INSERT INTO `order` VALUES (2, 'FT177883466960103E967', 1, 9.80, 0.00, 9.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-05-15 16:44:29');
INSERT INTO `order` VALUES (3, 'FT177883495475080706A', 1, 9.80, 0.00, 9.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-05-15 16:49:14');
INSERT INTO `order` VALUES (4, 'FT177883500958740787E', 1, 9.80, 0.00, 9.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-05-15 16:50:09');
INSERT INTO `order` VALUES (5, 'FT1778835010926AF8EEF', 1, 9.80, 0.00, 9.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '', NULL, 4, NULL, NULL, 0, NULL, NULL, NULL, NULL, '2026-05-15 16:50:10');
INSERT INTO `order` VALUES (6, 'FT177883519163396082B', 1, 9.80, 0.00, 9.80, '张三', '18229656601', '湖南省长沙市天心区中南林业科技大学', '', NULL, 5, 'mock_wechat', 'MOCK177883519169020CE2C24', 2, '2026-05-15 16:53:16', NULL, NULL, NULL, '2026-05-15 16:53:11');

-- ----------------------------
-- Table structure for order_item
-- ----------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '明细ID',
  `order_id` bigint(20) NOT NULL COMMENT '订单ID',
  `goods_id` bigint(20) NOT NULL COMMENT '商品ID',
  `sku_id` bigint(20) NULL DEFAULT NULL,
  `goods_name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '商品名称（快照）',
  `goods_image` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '商品图片（快照）',
  `sku_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `sku_weight_g` int(11) NULL DEFAULT NULL,
  `price` decimal(10, 2) NOT NULL COMMENT '购买时单价',
  `quantity` int(11) NOT NULL COMMENT '购买数量',
  `total_price` decimal(10, 2) NOT NULL COMMENT '小计金额',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_order_id`(`order_id`) USING BTREE,
  INDEX `idx_order_item_goods_id`(`goods_id`) USING BTREE,
  CONSTRAINT `fk_order_item_goods` FOREIGN KEY (`goods_id`) REFERENCES `goods` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_order_item_order` FOREIGN KEY (`order_id`) REFERENCES `order` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '订单明细表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of order_item
-- ----------------------------
INSERT INTO `order_item` VALUES (1, 1, 13, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '标准装', 500, 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (2, 2, 13, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '标准装', 500, 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (3, 3, 13, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '标准装', 500, 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (4, 4, 13, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '标准装', 500, 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (5, 5, 13, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '标准装', 500, 9.80, 1, 9.80);
INSERT INTO `order_item` VALUES (6, 6, 13, 13, '红富士苹果', 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/分类展示图片/fruits/仁果类/红富士苹果.jpg', '标准装', 500, 9.80, 1, 9.80);

-- ----------------------------
-- Table structure for seasonal_config
-- ----------------------------
DROP TABLE IF EXISTS `seasonal_config`;
CREATE TABLE `seasonal_config`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `config_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '配置键',
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '配置值',
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_config_key`(`config_key`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 20 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '当季精选运营配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of seasonal_config
-- ----------------------------
INSERT INTO `seasonal_config` VALUES (1, 'weight.season', '0.26', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (2, 'weight.freshness', '0.18', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (3, 'weight.sales', '0.18', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (4, 'weight.margin', '0.14', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (5, 'weight.stock', '0.14', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (6, 'weight.budget', '0.10', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (7, 'title.template', '{seasonText}当季精选', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (8, 'subtitle.template', '优先新鲜度、当季适配和库存稳定性', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (9, 'keywords.spring', '春,草莓,香椿,豌豆,春笋', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (10, 'keywords.summer', '夏,西瓜,黄瓜,番茄,苦瓜', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (11, 'keywords.autumn', '秋,南瓜,梨,柿子,莲藕', '2026-05-16 21:19:52');
INSERT INTO `seasonal_config` VALUES (12, 'keywords.winter', '冬,白菜,萝卜,橙,柚,菌菇', '2026-05-16 21:19:52');

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `tag_name` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '标签名称',
  `type` tinyint(4) NULL DEFAULT 1 COMMENT '类型 1产地 2属性 3营销',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 105 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tag
-- ----------------------------
INSERT INTO `tag` VALUES (101, '时令', 2);
INSERT INTO `tag` VALUES (102, '小份量', 2);
INSERT INTO `tag` VALUES (103, '搭配', 3);
INSERT INTO `tag` VALUES (104, '领券专区', 3);

-- ----------------------------
-- Table structure for track_event_log
-- ----------------------------
DROP TABLE IF EXISTS `track_event_log`;
CREATE TABLE `track_event_log`  (
  `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键ID',
  `user_id` bigint(20) NULL DEFAULT 0 COMMENT '用户ID（未登录记0）',
  `event_name` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '事件名',
  `payload` text CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL COMMENT '事件参数',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_event_name`(`event_name`) USING BTREE,
  INDEX `idx_create_time`(`create_time`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 69 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '前端埋点事件日志' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of track_event_log
-- ----------------------------
INSERT INTO `track_event_log` VALUES (1, 0, 'flash_add', '{goodsId=13}', '2026-05-13 17:51:40');
INSERT INTO `track_event_log` VALUES (2, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-14 17:09:24');
INSERT INTO `track_event_log` VALUES (3, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-14 17:09:41');
INSERT INTO `track_event_log` VALUES (4, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-14 17:10:04');
INSERT INTO `track_event_log` VALUES (5, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-15 17:16:47');
INSERT INTO `track_event_log` VALUES (6, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-15 17:22:02');
INSERT INTO `track_event_log` VALUES (7, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-15 17:38:16');
INSERT INTO `track_event_log` VALUES (8, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-15 20:41:28');
INSERT INTO `track_event_log` VALUES (9, 0, 'scene_click', '{sceneType=seasonalFresh, linkType=scene, linkValue=时令}', '2026-05-15 20:41:42');
INSERT INTO `track_event_log` VALUES (10, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-15 20:41:45');
INSERT INTO `track_event_log` VALUES (11, 0, 'scene_click', '{sceneType=couponZone, linkType=coupon, linkValue=couponZone}', '2026-05-15 21:04:24');
INSERT INTO `track_event_log` VALUES (12, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-15 21:04:40');
INSERT INTO `track_event_log` VALUES (13, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-15 21:04:48');
INSERT INTO `track_event_log` VALUES (14, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-15 21:12:44');
INSERT INTO `track_event_log` VALUES (15, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-15 21:12:53');
INSERT INTO `track_event_log` VALUES (16, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:13:30');
INSERT INTO `track_event_log` VALUES (17, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-16 15:13:35');
INSERT INTO `track_event_log` VALUES (18, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:27:03');
INSERT INTO `track_event_log` VALUES (19, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-16 15:27:10');
INSERT INTO `track_event_log` VALUES (20, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:40:30');
INSERT INTO `track_event_log` VALUES (21, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-16 15:40:36');
INSERT INTO `track_event_log` VALUES (22, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:44:01');
INSERT INTO `track_event_log` VALUES (23, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-16 15:44:17');
INSERT INTO `track_event_log` VALUES (24, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:45:56');
INSERT INTO `track_event_log` VALUES (25, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:53:14');
INSERT INTO `track_event_log` VALUES (26, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:53:32');
INSERT INTO `track_event_log` VALUES (27, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 15:54:01');
INSERT INTO `track_event_log` VALUES (28, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 17:29:26');
INSERT INTO `track_event_log` VALUES (29, 0, 'plan_generate_success', '{planType=meal, planId=1778923775924, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:29:35');
INSERT INTO `track_event_log` VALUES (30, 0, 'plan_regenerate', '{planType=meal}', '2026-05-16 17:29:58');
INSERT INTO `track_event_log` VALUES (31, 0, 'plan_generate_success', '{planType=meal, planId=1778923798977, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:29:58');
INSERT INTO `track_event_log` VALUES (32, 0, 'plan_regenerate', '{planType=meal}', '2026-05-16 17:30:00');
INSERT INTO `track_event_log` VALUES (33, 0, 'plan_generate_success', '{planType=meal, planId=1778923800064, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:30:00');
INSERT INTO `track_event_log` VALUES (34, 0, 'plan_regenerate', '{planType=meal}', '2026-05-16 17:30:00');
INSERT INTO `track_event_log` VALUES (35, 0, 'plan_generate_success', '{planType=meal, planId=1778923800514, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:30:00');
INSERT INTO `track_event_log` VALUES (36, 0, 'plan_generate_success', '{planType=meal, planId=1778923854086, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:30:54');
INSERT INTO `track_event_log` VALUES (37, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-16 17:31:54');
INSERT INTO `track_event_log` VALUES (38, 0, 'plan_generate_success', '{planType=combo, planId=1778923924701, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:32:04');
INSERT INTO `track_event_log` VALUES (39, 0, 'plan_add_cart_success', '{planType=combo, planId=1778923924701, resultType=SUCCESS, itemCount=3, fallbackUsed=true, errorCode=接口不存在}', '2026-05-16 17:32:10');
INSERT INTO `track_event_log` VALUES (40, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 17:42:53');
INSERT INTO `track_event_log` VALUES (41, 0, 'scene_click', '{sceneType=smallPortion, linkType=scene, linkValue=小份量}', '2026-05-16 17:44:12');
INSERT INTO `track_event_log` VALUES (42, 0, 'plan_generate_success', '{planType=meal, planId=177892466706570, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:44:27');
INSERT INTO `track_event_log` VALUES (43, 0, 'plan_item_replace', '{planType=meal, planId=177892466706570, role=side, fallbackUsed=false, errorCode=}', '2026-05-16 17:44:34');
INSERT INTO `track_event_log` VALUES (44, 0, 'plan_add_cart_success', '{planType=meal, planId=177892466706570, resultType=SUCCESS, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:44:37');
INSERT INTO `track_event_log` VALUES (45, 0, 'scene_click', '{sceneType=comboMix, linkType=scene, linkValue=搭配}', '2026-05-16 17:44:52');
INSERT INTO `track_event_log` VALUES (46, 0, 'plan_generate_success', '{planType=combo, planId=177892469863518, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:44:58');
INSERT INTO `track_event_log` VALUES (47, 0, 'plan_regenerate', '{planType=combo}', '2026-05-16 17:45:08');
INSERT INTO `track_event_log` VALUES (48, 0, 'plan_generate_success', '{planType=combo, planId=177892470835263, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:45:08');
INSERT INTO `track_event_log` VALUES (49, 0, 'plan_regenerate', '{planType=combo}', '2026-05-16 17:45:09');
INSERT INTO `track_event_log` VALUES (50, 0, 'plan_generate_success', '{planType=combo, planId=177892470984332, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:45:09');
INSERT INTO `track_event_log` VALUES (51, 0, 'plan_regenerate', '{planType=combo}', '2026-05-16 17:45:10');
INSERT INTO `track_event_log` VALUES (52, 0, 'plan_generate_success', '{planType=combo, planId=177892471115596, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:45:11');
INSERT INTO `track_event_log` VALUES (53, 0, 'plan_regenerate', '{planType=combo}', '2026-05-16 17:45:12');
INSERT INTO `track_event_log` VALUES (54, 0, 'plan_generate_success', '{planType=combo, planId=177892471245779, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:45:12');
INSERT INTO `track_event_log` VALUES (55, 0, 'plan_generate_success', '{planType=combo, planId=177892531415567, itemCount=3, fallbackUsed=false, errorCode=}', '2026-05-16 17:55:14');
INSERT INTO `track_event_log` VALUES (56, 0, 'scene_click', '{sceneType=seasonalFresh, linkType=scene, linkValue=时令}', '2026-05-16 21:05:26');
INSERT INTO `track_event_log` VALUES (57, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:05:30');
INSERT INTO `track_event_log` VALUES (58, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:08:11');
INSERT INTO `track_event_log` VALUES (59, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:08:30');
INSERT INTO `track_event_log` VALUES (60, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:13:47');
INSERT INTO `track_event_log` VALUES (61, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:14:12');
INSERT INTO `track_event_log` VALUES (62, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:20:04');
INSERT INTO `track_event_log` VALUES (63, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:20:05');
INSERT INTO `track_event_log` VALUES (64, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:20:05');
INSERT INTO `track_event_log` VALUES (65, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:20:11');
INSERT INTO `track_event_log` VALUES (66, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:20:13');
INSERT INTO `track_event_log` VALUES (67, 0, 'seasonal_list_loaded', '{season=spring, itemCount=12}', '2026-05-16 21:20:18');
INSERT INTO `track_event_log` VALUES (68, 0, 'seasonal_list_loaded', '{season=spring, itemCount=2}', '2026-05-16 21:20:22');

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
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'oD8Ny3YAuYe5GrXjpik9WS-Ij0VM', '睡到自然醒', 'https://unashamed-cursor-drainable.ngrok-free.dev/uploads/d0f991c36f7041d7a295f6b8f69bba27.jpg', NULL, 1, '2026-05-11 22:57:08');

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
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `fk_user_coupon_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户优惠券表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user_coupon
-- ----------------------------
INSERT INTO `user_coupon` VALUES (1, 1, '满39减5', '新人专享', 39.00, 5.00, '2026-12-31', 1, '2026-05-15 17:21:37');
INSERT INTO `user_coupon` VALUES (2, 1, '满50减8', '满50元可用', 50.00, 8.00, '2026-12-31', 1, '2026-05-16 10:00:00');
INSERT INTO `user_coupon` VALUES (3, 1, '满99减15', '生鲜专区可用', 99.00, 15.00, '2026-12-31', 1, '2026-05-16 10:05:00');

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
  UNIQUE INDEX `uk_user_id`(`user_id`) USING BTREE,
  CONSTRAINT `fk_user_setting_user` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户设置表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user_setting
-- ----------------------------
INSERT INTO `user_setting` VALUES (2, 1, 1, 0, '2026-05-11 22:57:15');

-- ----------------------------
-- Procedure structure for refresh_flash_pool
-- ----------------------------
DROP PROCEDURE IF EXISTS `refresh_flash_pool`;
delimiter ;;
CREATE PROCEDURE `refresh_flash_pool`(IN p_target_count INT)
BEGIN
  DECLARE v_count INT DEFAULT 0;
  DECLARE v_target INT DEFAULT 18;
  DECLARE v_need INT DEFAULT 0;

  IF p_target_count IS NOT NULL AND p_target_count >= 6 THEN
    SET v_target = p_target_count;
  END IF;

  UPDATE `goods`
  SET `is_flash` = 0, `flash_price` = NULL, `flash_start_time` = NULL, `flash_end_time` = NULL, `flash_stock` = 0
  WHERE `status` = 1;

  DROP TEMPORARY TABLE IF EXISTS `tmp_flash_candidates`;
  CREATE TEMPORARY TABLE `tmp_flash_candidates` AS
  SELECT g.`id`, g.`price`, g.`stock`, g.`sales_volume`,
         ((CASE WHEN g.`is_recommend` = 1 THEN 18 ELSE 0 END) +
          (CASE WHEN g.`price` BETWEEN 6 AND 36 THEN 20 ELSE 0 END) +
          (CASE WHEN g.`stock` BETWEEN 70 AND 360 THEN 24 ELSE 0 END) +
          (CASE WHEN g.`sales_volume` BETWEEN 180 AND 2200 THEN 22 ELSE 0 END) +
          (CASE WHEN g.`keywords` LIKE '%时令%' OR g.`keywords` LIKE '%夏季%' OR g.`keywords` LIKE '%清甜%' THEN 10 ELSE 0 END)) AS `score`
  FROM `goods` g
  WHERE g.`status` = 1 AND g.`stock` > 0 AND g.`price` BETWEEN 5 AND 42 AND g.`sales_volume` >= 80
    AND g.`category_id` IN (3,4,5,6,7,8,9,11,12,13,14,15);

  DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pick`;
  CREATE TEMPORARY TABLE `tmp_flash_pick` AS
  SELECT c.* FROM `tmp_flash_candidates` c ORDER BY c.`score` DESC, RAND() LIMIT 1000;

  DELETE p FROM `tmp_flash_pick` p
  JOIN (
    SELECT y.`id` FROM (
      SELECT x.`id`, (@rn := @rn + 1) AS rn
      FROM `tmp_flash_pick` x, (SELECT @rn := 0) t
      ORDER BY x.`score` DESC, RAND()
    ) y
    WHERE y.rn > v_target
  ) z ON z.`id` = p.`id`;

  SELECT COUNT(1) INTO v_count FROM `tmp_flash_pick`;
  SET v_need = GREATEST(v_target - v_count, 0);

  IF v_need > 0 THEN
    INSERT INTO `tmp_flash_pick` (`id`,`price`,`stock`,`sales_volume`,`score`)
    SELECT w.`id`, w.`price`, w.`stock`, w.`sales_volume`, w.`score`
    FROM (
      SELECT g.`id`, g.`price`, g.`stock`, g.`sales_volume`, 5 AS `score`, (@rn2 := @rn2 + 1) AS rn
      FROM `goods` g, (SELECT @rn2 := 0) t2
      WHERE g.`status` = 1 AND g.`stock` > 0 AND g.`price` BETWEEN 4 AND 48
        AND g.`id` NOT IN (SELECT `id` FROM `tmp_flash_pick`)
      ORDER BY g.`sales_volume` DESC, RAND()
    ) w
    WHERE w.rn <= v_need;
  END IF;

  DROP TEMPORARY TABLE IF EXISTS `tmp_flash_rank`;
  CREATE TEMPORARY TABLE `tmp_flash_rank` AS
  SELECT q.`id`, (@rnk := @rnk + 1) AS rn
  FROM (SELECT `id` FROM `tmp_flash_pick` ORDER BY `score` DESC, RAND()) q, (SELECT @rnk := 0) x;

  UPDATE `goods` g
  JOIN `tmp_flash_rank` t ON t.`id` = g.`id`
  SET g.`is_flash` = 1,
      g.`flash_price` = ROUND(g.`price` * (CASE WHEN g.`price` <= 10 THEN 0.92 WHEN g.`price` <= 20 THEN 0.89 WHEN g.`price` <= 35 THEN 0.86 ELSE 0.84 END), 2),
      g.`flash_stock` = LEAST(GREATEST(FLOOR(g.`stock` * 0.25), 10), g.`stock`),
      g.`flash_start_time` = CASE WHEN t.`rn` <= CEIL(v_target / 2) THEN CONCAT(CURDATE(), ' 09:00:00') ELSE CONCAT(CURDATE(), ' 19:00:00') END,
      g.`flash_end_time` = CASE WHEN t.`rn` <= CEIL(v_target / 2) THEN CONCAT(CURDATE(), ' 12:00:00') ELSE CONCAT(CURDATE(), ' 22:00:00') END;

  UPDATE `goods`
  SET `is_flash` = 0, `flash_price` = NULL, `flash_start_time` = NULL, `flash_end_time` = NULL, `flash_stock` = 0
  WHERE `is_flash` = 1 AND (
    `flash_price` IS NULL OR `flash_price` <= 0 OR `flash_price` >= `price`
    OR `flash_stock` IS NULL OR `flash_stock` <= 0 OR `flash_stock` > `stock`
    OR `flash_start_time` IS NULL OR `flash_end_time` IS NULL OR `flash_end_time` <= `flash_start_time`
  );

  DROP TEMPORARY TABLE IF EXISTS `tmp_flash_candidates`;
  DROP TEMPORARY TABLE IF EXISTS `tmp_flash_pick`;
  DROP TEMPORARY TABLE IF EXISTS `tmp_flash_rank`;
END
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
