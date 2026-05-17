SET NAMES utf8mb4;

SET FOREIGN_KEY_CHECKS = 0;

DELETE FROM `track_event_log`;
DELETE FROM `comment`;
DELETE FROM `order_item`;
DELETE FROM `order`;
DELETE FROM `cart`;
DELETE FROM `address`;
DELETE FROM `user_coupon`;
DELETE FROM `user_setting`;
DELETE FROM `user`;

ALTER TABLE `track_event_log` AUTO_INCREMENT = 1;
ALTER TABLE `comment` AUTO_INCREMENT = 1;
ALTER TABLE `order_item` AUTO_INCREMENT = 1;
ALTER TABLE `order` AUTO_INCREMENT = 1;
ALTER TABLE `cart` AUTO_INCREMENT = 1;
ALTER TABLE `address` AUTO_INCREMENT = 1;
ALTER TABLE `user_coupon` AUTO_INCREMENT = 1;
ALTER TABLE `user_setting` AUTO_INCREMENT = 1;
ALTER TABLE `user` AUTO_INCREMENT = 1;

SET FOREIGN_KEY_CHECKS = 1;

SELECT 'user' AS tbl, COUNT(*) AS cnt FROM `user`
UNION ALL
SELECT 'user_setting' AS tbl, COUNT(*) AS cnt FROM `user_setting`
UNION ALL
SELECT 'user_coupon' AS tbl, COUNT(*) AS cnt FROM `user_coupon`
UNION ALL
SELECT 'address' AS tbl, COUNT(*) AS cnt FROM `address`
UNION ALL
SELECT 'cart' AS tbl, COUNT(*) AS cnt FROM `cart`
UNION ALL
SELECT 'order' AS tbl, COUNT(*) AS cnt FROM `order`
UNION ALL
SELECT 'order_item' AS tbl, COUNT(*) AS cnt FROM `order_item`
UNION ALL
SELECT 'comment' AS tbl, COUNT(*) AS cnt FROM `comment`
UNION ALL
SELECT 'track_event_log' AS tbl, COUNT(*) AS cnt FROM `track_event_log`;
