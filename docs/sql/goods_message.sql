-- =====================================================
-- 商品数据全面修正脚本
-- 包含：价格、秒杀价、产地、关键词、详情描述
-- 执行前请备份数据
-- =====================================================

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

START TRANSACTION;

-- =====================================================
-- 一、水果类商品修正
-- =====================================================

-- 1. 草莓
UPDATE `goods` SET 
`price` = 29.80,
`original_price` = 39.80,
`flash_price` = 22.80,
`flash_start_time` = '2026-05-18 09:00:00',
`flash_end_time` = '2026-05-18 12:00:00',
`flash_stock` = 20,
`keywords` = '草莓,丹东,奶油草莓,红颜草莓,春季水果,VC水果,酸甜,鲜食,冷藏保存',
`origin` = '辽宁丹东,江苏南京,安徽合肥',
`detail` = '草莓：丹东红颜品种，果面光泽鲜红，果蒂翠绿，口感酸甜多汁，香气浓郁。适合鲜食、制作酸奶杯、轻食沙拉、草莓蛋糕。收到后请冷藏2-4度保存，建议24小时内食用风味最佳。单颗重量约15-20克，甜度约12-14度。'
WHERE `id` = 1;

-- 2. 蓝莓
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 22.80,
`flash_price` = 11.80,
`flash_start_time` = '2026-05-18 19:00:00',
`flash_end_time` = '2026-05-18 22:00:00',
`flash_stock` = 15,
`unit` = '盒',
`keywords` = '蓝莓,云南蓝莓,高原蓝莓,花青素,护眼水果,浆果,酸甜,烘焙,鲜食,冷藏保存',
`origin` = '云南红河,吉林长春,山东青岛',
`detail` = '蓝莓：云南高原露天种植，果粉完整，手感干爽紧实，甜度高酸度低，单颗直径约14-16毫米。适合直接食用、烘焙、制作奶昔或果酱。建议冷藏保鲜，食用前轻轻冲洗沥干。125克/盒装，约50-60颗。'
WHERE `id` = 2;

-- 3. 巨峰葡萄
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-05-18 09:00:00',
`flash_end_time` = '2026-05-18 12:00:00',
`flash_stock` = 30,
`keywords` = '巨峰葡萄,新疆葡萄,夏黑,鲜食葡萄,多汁,清甜,夏季水果,冷藏保存',
`origin` = '新疆吐鲁番,辽宁北镇,河北秦皇岛',
`detail` = '巨峰葡萄：果粒饱满圆润，果皮紫黑带白霜，果肉软嫩多汁，甜度约16-18度，带有淡淡草莓香气。适合鲜食、冷泡果饮、制作葡萄冰沙。冷藏后口感更佳，建议收货后2-3天内食用完毕。'
WHERE `id` = 3;

-- 4. 橙子
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 9.90,
`flash_price` = 5.90,
`flash_start_time` = '2026-05-19 09:00:00',
`flash_end_time` = '2026-05-19 12:00:00',
`flash_stock` = 50,
`keywords` = '橙子,赣南脐橙,秭归脐橙,柑橘类,维C水果,榨汁,鲜食,清甜,冷藏保存',
`origin` = '江西赣州,湖北秭归,湖南怀化',
`detail` = '橙子：赣南脐橙品种，果形椭圆，果皮橙黄光滑，果肉细嫩化渣，酸甜适口，果汁含量约55%。适合鲜食、榨汁、制作水果茶。置于阴凉通风处可存5-7天，冷藏可存2-3周。'
WHERE `id` = 4;

-- 5. 丑橘
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 8.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-05-19 19:00:00',
`flash_end_time` = '2026-05-19 22:00:00',
`flash_stock` = 40,
`keywords` = '丑橘,不知火,柑橘,四川丑橘,凸顶柑,清甜,多汁,冷藏保存',
`origin` = '四川蒲江,四川丹棱,重庆奉节',
`detail` = '丑橘：又名不知火，果形顶部凸起，果皮粗糙但易剥，果肉脆嫩，甜度约14-16度，酸度极低。适合鲜食、制作水果沙拉。建议阴凉通风处保存，可存放7-10天。'
WHERE `id` = 5;

-- 6. 柠檬
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 7.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-05-20 09:00:00',
`flash_end_time` = '2026-05-20 12:00:00',
`flash_stock` = 60,
`keywords` = '柠檬,安岳柠檬,海南柠檬,维C,泡水,调味,清香,冷藏保存',
`origin` = '四川安岳,海南海口,云南瑞丽',
`detail` = '柠檬：果皮鲜黄，香气浓郁，果酸含量约5-6%。适合泡柠檬水、调味海鲜、制作柠檬茶、烘焙甜点。建议冷藏保存，切片后可冷冻备用。榨汁前揉搓果皮可释放更多香气。'
WHERE `id` = 6;

-- 7. 西瓜
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 3.80,
`flash_price` = 1.99,
`flash_start_time` = '2026-05-20 19:00:00',
`flash_end_time` = '2026-05-20 22:00:00',
`flash_stock` = 80,
`unit` = '个',
`keywords` = '西瓜,麒麟瓜,8424,夏季水果,解暑,清甜,多汁,冷藏保存',
`origin` = '河南夏邑,江苏东台,宁夏中卫',
`detail` = '西瓜：麒麟瓜品种，果形圆润，果皮翠绿带深绿条纹，果肉鲜红沙脆，甜度约11-13度，中心糖度可达13度以上。适合夏季鲜食、制作果盘、西瓜汁。切开后请冷藏并覆盖保鲜膜，建议2天内食用完毕。单果重约4-6斤。'
WHERE `id` = 7;

-- 8. 哈密瓜
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-05-21 09:00:00',
`flash_end_time` = '2026-05-21 12:00:00',
`flash_stock` = 30,
`unit` = '个',
`keywords` = '哈密瓜,西州蜜,新疆哈密瓜,甜瓜,夏季水果,清甜,冷藏保存',
`origin` = '新疆哈密,甘肃瓜州,内蒙古阿拉善',
`detail` = '哈密瓜：西州蜜25号品种，果形椭圆，果皮金黄带网纹，果肉橙黄酥脆，甜度约15-18度，香气馥郁。适合鲜食、制作果盘、水果沙拉。单果重约3-4斤。切开后去籽冷藏，建议3天内食用完毕。'
WHERE `id` = 8;

-- 9. 香瓜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 7.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-05-21 19:00:00',
`flash_end_time` = '2026-05-21 22:00:00',
`flash_stock` = 35,
`keywords` = '香瓜,甜瓜,白兰瓜,夏季水果,清甜,脆嫩,冷藏保存',
`origin` = '海南乐东,山东潍坊,陕西大荔',
`detail` = '香瓜：果皮洁白光滑，果肉淡绿或白色，肉质脆嫩，汁水丰富，甜度约12-14度，香气清雅。适合鲜食、制作水果拼盘。建议冷藏保存，食用前冰镇口感更佳。'
WHERE `id` = 9;

-- 10. 水蜜桃
UPDATE `goods` SET 
`price` = 16.80,
`original_price` = 22.80,
`flash_price` = 12.80,
`flash_start_time` = '2026-05-22 09:00:00',
`flash_end_time` = '2026-05-22 12:00:00',
`flash_stock` = 25,
`keywords` = '水蜜桃,奉化水蜜桃,阳山水蜜桃,夏季水果,软糯多汁,鲜食,冷藏保存',
`origin` = '浙江奉化,江苏无锡,河北深州',
`detail` = '水蜜桃：奉化品种，果形圆润饱满，果皮粉红带绒毛，果肉乳白细嫩，汁水丰沛，甜度约14-16度，软糯香甜。适合鲜食、制作桃子冰沙、蜜桃乌龙茶。成熟果建议冷藏并尽快食用，手感稍硬的可常温催熟。'
WHERE `id` = 10;

-- 11. 黑布李
UPDATE `goods` SET 
`price` = 11.80,
`original_price` = 15.80,
`flash_price` = 8.90,
`flash_start_time` = '2026-05-22 19:00:00',
`flash_end_time` = '2026-05-22 22:00:00',
`flash_stock` = 20,
`keywords` = '黑布李,黑李子,加州李,夏季水果,酸甜,脆李,冷藏保存',
`origin` = '广东翁源,福建古田,四川汉源',
`detail` = '黑布李：果皮紫黑光亮，果肉橙黄，肉质爽脆，酸甜适口，甜度约12-14度，酸度适中。适合鲜食、制作李子酱、水果沙拉。手感较硬的可常温放置2-3天回软后食用更甜。'
WHERE `id` = 11;

-- 12. 樱桃
UPDATE `goods` SET 
`price` = 58.80,
`original_price` = 79.80,
`flash_price` = 45.80,
`flash_start_time` = '2026-05-23 09:00:00',
`flash_end_time` = '2026-05-23 12:00:00',
`flash_stock` = 10,
`unit` = '斤',
`keywords` = '樱桃,车厘子,大樱桃,红灯,美早,春季水果,酸甜,冷藏保存',
`origin` = '山东烟台,辽宁大连,陕西铜川',
`detail` = '樱桃：美早品种，果形心形，果皮紫红至深红，果肉厚实脆甜，单果重约10-12克，甜度约18-22度。适合鲜食、制作蛋糕装饰、水果拼盘。冷藏可保存3-5天，食用前取出回温风味更佳。'
WHERE `id` = 12;

-- 13. 红富士苹果
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.80,
`flash_start_time` = '2026-05-23 19:00:00',
`flash_end_time` = '2026-05-23 22:00:00',
`flash_stock` = 60,
`keywords` = '红富士苹果,烟台苹果,陕西苹果,秋季水果,清甜,脆甜,榨汁,冷藏保存',
`origin` = '山东烟台,陕西洛川,甘肃静宁',
`detail` = '红富士苹果：果形端正，果皮红色条纹，果肉黄白细脆，汁水充足，甜度约13-15度，酸甜黄金比例。适合鲜食、榨汁、制作苹果派、早餐拼盘。阴凉通风处可存2-3周，冷藏可存1-2个月。'
WHERE `id` = 13;

-- 14. 皇冠梨
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 8.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-05-24 09:00:00',
`flash_end_time` = '2026-05-24 12:00:00',
`flash_stock` = 45,
`keywords` = '皇冠梨,河北梨,雪花梨,秋季水果,清甜,脆嫩,润肺,冷藏保存',
`origin` = '河北赵县,山东莱阳,安徽砀山',
`detail` = '皇冠梨：果形椭圆，果皮金黄，果肉雪白细嫩，酥脆多汁，甜度约11-13度，清甜无渣。适合鲜食、煮梨汤、制作冰糖雪梨。常温可存1周，冷藏可存3-4周。'
WHERE `id` = 14;

-- 15. 枇杷
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 19.80,
`flash_price` = 11.80,
`flash_start_time` = '2026-05-24 19:00:00',
`flash_end_time` = '2026-05-24 22:00:00',
`flash_stock` = 25,
`keywords` = '枇杷,云霄枇杷,塘栖枇杷,春季水果,润肺,清甜,鲜食,冷藏保存',
`origin` = '福建云霄,浙江塘栖,四川龙泉驿',
`detail` = '枇杷：果形圆润，果皮金黄，果肉橙黄细腻，汁水丰富，甜度约12-14度，香气清雅。适合鲜食、制作枇杷膏、枇杷糖水。成熟果建议冷藏并尽快食用，避免挤压。'
WHERE `id` = 15;

-- 16. 菠萝
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 12.80,
`flash_price` = 7.80,
`flash_start_time` = '2026-05-25 09:00:00',
`flash_end_time` = '2026-05-25 12:00:00',
`flash_stock` = 30,
`unit` = '个',
`keywords` = '菠萝,凤梨,徐闻菠萝,海南菠萝,春季水果,酸甜,榨汁,冷藏保存',
`origin` = '广东徐闻,海南万宁,广西南宁',
`detail` = '菠萝：巴厘品种，果形圆柱，果皮金黄带绿，果肉金黄，酸甜多汁，香气浓郁。适合鲜食、制作菠萝饭、菠萝咕咾肉、榨汁。建议盐水浸泡10分钟后再食用，可减少涩感。单果重约2-3斤。'
WHERE `id` = 16;

-- 17. 无花果
UPDATE `goods` SET 
`price` = 22.80,
`original_price` = 29.80,
`flash_price` = 17.80,
`flash_start_time` = '2026-05-25 19:00:00',
`flash_end_time` = '2026-05-25 22:00:00',
`flash_stock` = 15,
`keywords` = '无花果,波姬红,青皮无花果,秋季水果,软糯香甜,鲜食,冷藏保存',
`origin` = '四川威远,山东威海,新疆阿图什',
`detail` = '无花果：波姬红品种，果形扁圆，果皮紫红，果肉粉红软糯，蜜甜多籽，甜度约18-22度。适合鲜食、制作无花果干、烘焙、沙拉。非常娇嫩，建议收货后立即冷藏，2天内食用完毕。'
WHERE `id` = 17;

-- 18. 桑葚
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-05-26 09:00:00',
`flash_end_time` = '2026-05-26 12:00:00',
`flash_stock` = 18,
`unit` = '盒',
`keywords` = '桑葚,桑果,桑椹,春季水果,酸甜,花青素,鲜食,冷藏保存',
`origin` = '广西来宾,四川攀枝花,浙江桐乡',
`detail` = '桑葚：果形长椭圆形，果皮紫黑油亮，果肉软嫩多汁，酸甜适口，富含花青素。适合鲜食、制作桑葚酱、桑葚酒、烘焙。非常娇嫩易破损，建议收货后立即冷藏，24小时内食用完毕。250克/盒装。'
WHERE `id` = 18;

-- 107. 白心芭乐
UPDATE `goods` SET 
`price` = 10.80,
`original_price` = 14.80,
`flash_price` = 7.80,
`flash_start_time` = '2026-05-26 19:00:00',
`flash_end_time` = '2026-05-26 22:00:00',
`flash_stock` = 20,
`keywords` = '芭乐,番石榴,白心芭乐,热带水果,清脆,酸梅粉,鲜食,冷藏保存',
`origin` = '云南西双版纳,广东广州,福建漳州',
`detail` = '白心芭乐：果形梨形，果皮青绿，果肉雪白，肉质清脆，香气独特，甜度约8-10度，适合沾酸梅粉食用。适合鲜食、制作芭乐汁、水果沙拉。常温可催熟变软，冷藏可保鲜。'
WHERE `id` = 107;

-- 108. 百香果
UPDATE `goods` SET 
`price` = 10.80,
`original_price` = 14.80,
`flash_price` = 7.80,
`flash_start_time` = '2026-05-27 09:00:00',
`flash_end_time` = '2026-05-27 12:00:00',
`flash_stock` = 40,
`keywords` = '百香果,鸡蛋果,热情果,热带水果,酸甜,榨汁,泡水,冷藏保存',
`origin` = '云南西双版纳,广西玉林,福建龙岩',
`detail` = '百香果：果形圆球形，果皮紫红，果肉金黄多籽，香气浓郁复杂，酸甜开胃，果汁含量约40%。适合制作百香果蜂蜜水、百香果蛋糕、调味。果皮变皱后更甜，可常温存放至表皮发皱再食用。'
WHERE `id` = 108;

-- 109. 脆柿
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 12.80,
`flash_price` = 6.90,
`flash_start_time` = '2026-05-27 19:00:00',
`flash_end_time` = '2026-05-27 22:00:00',
`flash_stock` = 35,
`keywords` = '脆柿,甜柿,次郎甜柿,秋季水果,清脆,鲜食,无需脱涩,冷藏保存',
`origin` = '云南石林,陕西渭南,山西运城',
`detail` = '脆柿：次郎甜柿品种，果形扁方，果皮橙黄，果肉橙黄脆甜，无需脱涩处理，口感像苹果一样脆。适合鲜食、制作水果拼盘。常温可存1-2周，冷藏可存更久。'
WHERE `id` = 109;

-- 110. 灯笼果
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 19.80,
`flash_price` = 11.80,
`flash_start_time` = '2026-05-28 09:00:00',
`flash_end_time` = '2026-05-28 12:00:00',
`flash_stock` = 20,
`keywords` = '灯笼果,姑娘果,酸浆,东北水果,酸甜,鲜食,特色水果,冷藏保存',
`origin` = '黑龙江齐齐哈尔,吉林长春,内蒙古呼伦贝尔',
`detail` = '灯笼果：果实包在灯笼状宿萼内，果色金黄，果肉软嫩多籽，酸甜开胃，带特殊香气。适合鲜食、制作果酱、甜点装饰。冷藏可保存1周左右。'
WHERE `id` = 110;

-- 111. 黑加仑
UPDATE `goods` SET 
`price` = 18.80,
`original_price` = 24.80,
`flash_price` = 14.80,
`flash_start_time` = '2026-05-28 19:00:00',
`flash_end_time` = '2026-05-28 22:00:00',
`flash_stock` = 15,
`keywords` = '黑加仑,黑醋栗,浆果,花青素,酸甜,烘焙,榨汁,冷冻保存',
`origin` = '黑龙江尚志,辽宁丹东,新疆伊犁',
`detail` = '黑加仑：果粒小圆球形，果皮紫黑，果肉酸甜浓郁，富含花青素和维C。适合制作果酱、果汁、烘焙蛋糕、酿酒。冷冻可长期保存。'
WHERE `id` = 111;

-- 112. 黑金刚莲雾
UPDATE `goods` SET 
`price` = 28.80,
`original_price` = 38.80,
`flash_price` = 22.80,
`flash_start_time` = '2026-05-29 09:00:00',
`flash_end_time` = '2026-05-29 12:00:00',
`flash_stock` = 10,
`keywords` = '莲雾,黑金刚莲雾,台湾水果,热带水果,清脆,清甜,解渴,冷藏保存',
`origin` = '海南海口,台湾屏东,广东湛江',
`detail` = '黑金刚莲雾：果形钟形，果皮紫红发亮，果肉雪白海绵状，清脆多汁，清甜解渴，含水量约90%。适合鲜食、制作水果拼盘、沙拉。冷藏后口感更佳，建议3-5天内食用完毕。'
WHERE `id` = 112;

-- 113. 黑莓
UPDATE `goods` SET 
`price` = 22.80,
`original_price` = 29.80,
`flash_price` = 17.80,
`flash_start_time` = '2026-05-29 19:00:00',
`flash_end_time` = '2026-05-29 22:00:00',
`flash_stock` = 12,
`keywords` = '黑莓,黑树莓,浆果,花青素,酸甜,烘焙,鲜食,冷冻保存',
`origin` = '江苏南京,山东青岛,贵州麻江',
`detail` = '黑莓：聚合果，果形长圆形，果皮紫黑，果肉软嫩多汁，酸甜浓郁，富含花青素和膳食纤维。适合鲜食、制作果酱、烘焙蛋糕、酸奶配料。非常娇嫩，建议冷藏并尽快食用，可冷冻保存。'
WHERE `id` = 113;

-- 114. 红宝石莲雾
UPDATE `goods` SET 
`price` = 26.80,
`original_price` = 35.80,
`flash_price` = 19.90,
`flash_start_time` = '2026-05-30 09:00:00',
`flash_end_time` = '2026-05-30 12:00:00',
`flash_stock` = 10,
`keywords` = '莲雾,红宝石莲雾,热带水果,清脆,清甜,解暑,冷藏保存',
`origin` = '海南三亚,台湾高雄,福建厦门',
`detail` = '红宝石莲雾：果形钟形，果皮鲜红亮丽，果肉雪白，清脆爽口，汁水丰富，清甜淡雅，含水量约90%。适合鲜食、制作水果拼盘。冷藏后口感更佳，建议3-5天内食用完毕。'
WHERE `id` = 114;

-- 115. 红提
UPDATE `goods` SET 
`price` = 14.80,
`original_price` = 19.80,
`flash_price` = 10.80,
`flash_start_time` = '2026-05-30 19:00:00',
`flash_end_time` = '2026-05-30 22:00:00',
`flash_stock` = 30,
`keywords` = '红提,红地球葡萄,美国红提,葡萄,清甜,脆甜,鲜食,冷藏保存',
`origin` = '新疆伊犁,陕西渭南,云南宾川',
`detail` = '红提：果粒大圆形，果皮紫红，果肉硬脆爽口，甜度约16-18度，无籽或少籽。适合鲜食、制作水果拼盘、葡萄冰沙。冷藏可保存1-2周，食用前用面粉水浸泡清洗更干净。'
WHERE `id` = 115;

-- 116. 红心芭乐
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-05-31 09:00:00',
`flash_end_time` = '2026-05-31 12:00:00',
`flash_stock` = 25,
`keywords` = '芭乐,红心芭乐,番石榴,热带水果,软糯香甜,鲜食,冷藏保存',
`origin` = '广东广州,福建漳州,海南琼海',
`detail` = '红心芭乐：果形梨形，果皮青绿，果肉粉红，肉质软糯，香气独特，甜度约10-12度，红心品种比白心更甜。适合鲜食、沾酸梅粉、制作芭乐汁。常温可催熟变软，变软后更香甜。'
WHERE `id` = 116;

-- 117. 红心火龙果
UPDATE `goods` SET 
`price` = 11.80,
`original_price` = 15.80,
`flash_price` = 8.90,
`flash_start_time` = '2026-05-31 19:00:00',
`flash_end_time` = '2026-05-31 22:00:00',
`flash_stock` = 40,
`keywords` = '火龙果,红心火龙果,哥斯达黎加火龙果,热带水果,清甜,通便,冷藏保存',
`origin` = '广西南宁,海南东方,广东湛江',
`detail` = '红心火龙果：果形椭圆，果皮紫红带鳞片，果肉紫红，清甜多汁，富含花青素和膳食纤维。适合鲜食、制作水果拼盘、火龙果奶昔。冷藏可保存1-2周。'
WHERE `id` = 117;

-- 118. 火龙果（白心）
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-01 09:00:00',
`flash_end_time` = '2026-06-01 12:00:00',
`flash_stock` = 50,
`keywords` = '火龙果,白心火龙果,火龙果,热带水果,清甜,通便,冷藏保存',
`origin` = '广西南宁,海南东方,云南西双版纳',
`detail` = '火龙果：果形椭圆，果皮紫红带鳞片，果肉雪白带黑籽，清甜淡雅，富含膳食纤维。适合鲜食、制作水果拼盘、火龙果沙拉。冷藏可保存1-2周。'
WHERE `id` = 118;

-- 119. 猕猴桃
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-06-01 19:00:00',
`flash_end_time` = '2026-06-01 22:00:00',
`flash_stock` = 40,
`keywords` = '猕猴桃,奇异果,徐香猕猴桃,翠香,秋季水果,维C之王,酸甜,冷藏保存',
`origin` = '陕西周至,四川蒲江,贵州修文',
`detail` = '猕猴桃：徐香品种，果形椭圆，果皮褐色带绒毛，果肉翠绿，酸甜适口，维C含量极高，甜度约14-16度。适合鲜食、制作水果沙拉、猕猴桃汁。手感稍硬的可与苹果香蕉一起催熟，变软后食用。'
WHERE `id` = 119;

-- 120. 木瓜
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-02 09:00:00',
`flash_end_time` = '2026-06-02 12:00:00',
`flash_stock` = 35,
`keywords` = '木瓜,番木瓜,热带水果,软糯,清甜,丰胸,鲜食,冷藏保存',
`origin` = '海南三亚,广东广州,广西南宁',
`detail` = '木瓜：夏威夷品种，果形长圆，果皮金黄，果肉橙红，软糯香甜，甜度约12-14度，富含木瓜蛋白酶。适合鲜食、制作木瓜牛奶、木瓜沙拉。青木瓜可凉拌或煲汤，熟木瓜适合鲜食。'
WHERE `id` = 120;

-- 121. 牛奶葡萄
UPDATE `goods` SET 
`price` = 16.80,
`original_price` = 22.80,
`flash_price` = 12.80,
`flash_start_time` = '2026-06-02 19:00:00',
`flash_end_time` = '2026-06-02 22:00:00',
`flash_stock` = 20,
`keywords` = '牛奶葡萄,马奶提,无核白,葡萄,清甜,脆嫩,鲜食,冷藏保存',
`origin` = '新疆吐鲁番,河北怀来,山西清徐',
`detail` = '牛奶葡萄：果粒长椭圆形，果皮黄绿透亮，果肉脆嫩，汁水丰富，有淡淡奶香，甜度约18-20度。适合鲜食、制作葡萄干。建议冷藏保存，食用前用面粉水浸泡清洗。'
WHERE `id` = 121;

-- 122. 牛油果
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-06-03 09:00:00',
`flash_end_time` = '2026-06-03 12:00:00',
`flash_stock` = 25,
`unit` = '个',
`keywords` = '牛油果,鳄梨,酪梨,健康脂肪,沙拉,轻食,西餐,常温催熟',
`origin` = '云南普洱,广东广州,福建漳州',
`detail` = '牛油果：哈斯品种，果形梨形或卵形，果皮紫黑粗糙，果肉黄绿软糯，富含健康不饱和脂肪酸，口感像黄油。适合制作牛油果沙拉、牛油果吐司、牛油果奶昔、墨西哥酱。手感稍硬的可常温催熟，变软变黑后食用。单果重约200-300克。'
WHERE `id` = 122;

-- 123. 青提
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.50,
`flash_start_time` = '2026-06-03 19:00:00',
`flash_end_time` = '2026-06-03 22:00:00',
`flash_stock` = 30,
`keywords` = '青提,无籽青提,玻璃脆,葡萄,清甜,脆爽,鲜食,冷藏保存',
`origin` = '新疆吐鲁番,陕西渭南,云南建水',
`detail` = '青提：无核品种，果粒圆形或椭圆形，果皮青绿透亮，果肉硬脆，甜度约18-22度，口感像冰糖。适合鲜食、制作水果拼盘。冷藏可保存1-2周，食用前用面粉水浸泡清洗。'
WHERE `id` = 123;

-- 124. 人参果
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.50,
`flash_start_time` = '2026-06-04 09:00:00',
`flash_end_time` = '2026-06-04 12:00:00',
`flash_stock` = 25,
`keywords` = '人参果,香瓜茄,茄瓜,特色水果,清甜,淡雅,鲜食,冷藏保存',
`origin` = '云南石林,甘肃武威,青海海东',
`detail` = '人参果：果形椭圆形，果皮金黄带紫条纹，果肉淡黄，肉质脆嫩，清甜淡雅，有哈密瓜和香瓜的混合香气。适合鲜食、制作水果拼盘。冷藏可保存1-2周。'
WHERE `id` = 124;

-- 125. 软柿子
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-04 19:00:00',
`flash_end_time` = '2026-06-04 22:00:00',
`flash_stock` = 30,
`keywords` = '柿子,软柿子,磨盘柿,秋季水果,软糯香甜,鲜食,冷藏保存',
`origin` = '陕西富平,广西恭城,河北满城',
`detail` = '软柿子：磨盘柿品种，果形扁圆，果皮橙红，果肉软糯多汁，蜜甜如糖，甜度约18-22度。适合鲜食、制作柿饼。常温可催熟变软，完全变软后需立即食用或冷藏。'
WHERE `id` = 125;

-- 126. 山竹
UPDATE `goods` SET 
`price` = 25.80,
`original_price` = 35.80,
`flash_price` = 19.80,
`flash_start_time` = '2026-06-05 09:00:00',
`flash_end_time` = '2026-06-05 12:00:00',
`flash_stock` = 15,
`unit` = '斤',
`keywords` = '山竹,水果皇后,热带水果,酸甜,清火,鲜食,冷藏保存',
`origin` = '海南三亚,广东茂名,泰国进口',
`detail` = '山竹：果形圆球形，果皮紫黑厚硬，果肉雪白蒜瓣状，酸甜适口，口感像荔枝和桃子的结合，有水果皇后美誉。适合鲜食、制作水果拼盘。按压果皮有弹性为佳，冷藏可保存3-5天。'
WHERE `id` = 126;

-- 127. 圣女果
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.80,
`flash_start_time` = '2026-06-05 19:00:00',
`flash_end_time` = '2026-06-05 22:00:00',
`flash_stock` = 50,
`keywords` = '圣女果,小番茄,樱桃番茄,千禧果,酸甜,鲜食,沙拉,冷藏保存',
`origin` = '海南陵水,山东寿光,广西田阳',
`detail` = '圣女果：千禧品种，果形椭圆形，果皮鲜红，果肉脆嫩多汁，酸甜可口，甜度约8-10度。适合鲜食、制作沙拉、便当配菜。冷藏可保存1周左右。'
WHERE `id` = 127;

-- 128. 石榴
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.50,
`flash_start_time` = '2026-06-06 09:00:00',
`flash_end_time` = '2026-06-06 12:00:00',
`flash_stock` = 30,
`keywords` = '石榴,突尼斯石榴,软籽石榴,秋季水果,清甜,多汁,冷藏保存',
`origin` = '四川会理,云南蒙自,河南荥阳',
`detail` = '石榴：突尼斯软籽品种，果形圆球形，果皮黄红，籽粒深红如宝石，汁水丰富，清甜可口，籽软可食用。适合鲜食、制作石榴汁、水果沙拉。冷藏可保存2-4周。'
WHERE `id` = 128;

-- 129. 树莓
UPDATE `goods` SET 
`price` = 24.80,
`original_price` = 32.80,
`flash_price` = 18.80,
`flash_start_time` = '2026-06-06 19:00:00',
`flash_end_time` = '2026-06-06 22:00:00',
`flash_stock` = 12,
`keywords` = '树莓,覆盆子,红树莓,浆果,酸甜,烘焙,鲜食,冷冻保存',
`origin` = '黑龙江尚志,江苏南京,山东青岛',
`detail` = '树莓：聚合果，果形半球形，果皮鲜红，果肉软嫩多汁，酸甜浓郁，香气独特。适合鲜食、制作果酱、烘焙蛋糕、酸奶配料。非常娇嫩，建议冷藏并尽快食用，可冷冻保存。'
WHERE `id` = 129;

-- 130. 无核白葡萄
UPDATE `goods` SET 
`price` = 14.80,
`original_price` = 19.80,
`flash_price` = 11.50,
`flash_start_time` = '2026-06-07 09:00:00',
`flash_end_time` = '2026-06-07 12:00:00',
`flash_stock` = 25,
`keywords` = '无核白葡萄,马奶提,葡萄,清甜,脆嫩,鲜食,冷藏保存',
`origin` = '新疆吐鲁番,甘肃敦煌,内蒙古乌海',
`detail` = '无核白葡萄：无核品种，果粒椭圆，果皮黄绿透亮，果肉脆嫩，汁水充足，甜度约20-24度，可制作葡萄干。适合鲜食、制作水果拼盘。冷藏可保存1-2周。'
WHERE `id` = 130;

-- 131. 夏黑葡萄
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 20.80,
`flash_price` = 12.50,
`flash_start_time` = '2026-06-07 19:00:00',
`flash_end_time` = '2026-06-07 22:00:00',
`flash_stock` = 25,
`keywords` = '夏黑葡萄,早黑宝,葡萄,清甜,脆嫩,无籽,夏季水果,冷藏保存',
`origin` = '江苏张家港,浙江金华,上海嘉定',
`detail` = '夏黑葡萄：三倍体无核品种，果粒圆形，果皮紫黑，果肉硬脆，甜度约18-22度，有淡淡草莓香气。适合鲜食、制作水果拼盘、葡萄冰沙。冷藏可保存1周左右。'
WHERE `id` = 131;

-- 132. 香蕉
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-06-08 09:00:00',
`flash_end_time` = '2026-06-08 12:00:00',
`flash_stock` = 80,
`unit` = '斤',
`keywords` = '香蕉,进口香蕉,都乐香蕉,高屏蕉,软糯,饱腹,能量水果,常温保存',
`origin` = '海南澄迈,广东高州,云南西双版纳',
`detail` = '香蕉：进口品种，果形长弯，果皮金黄，果肉软糯香甜，饱腹感强。适合鲜食、制作奶昔、香蕉蛋糕、早餐搭配。常温存放，勿冷藏（会变黑）。表皮出现芝麻黑点口感最佳。'
WHERE `id` = 132;

-- 133. 小米蕉
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-08 19:00:00',
`flash_end_time` = '2026-06-08 22:00:00',
`flash_stock` = 50,
`keywords` = '小米蕉,皇帝蕉,手指蕉,甜度高,软糯,鲜食,常温保存',
`origin` = '海南澄迈,广东高州,福建漳州',
`detail` = '小米蕉：迷你香蕉品种，果形短小，果皮薄，果肉金黄，甜度比普通香蕉高，口感更软糯香甜。适合鲜食、儿童零食。常温存放，勿冷藏。'
WHERE `id` = 133;

-- 134. 杨桃
UPDATE `goods` SET 
`price` = 10.80,
`original_price` = 14.80,
`flash_price` = 7.90,
`flash_start_time` = '2026-06-09 09:00:00',
`flash_end_time` = '2026-06-09 12:00:00',
`flash_stock` = 30,
`keywords` = '杨桃,五敛子,星果,热带水果,酸甜,解渴,鲜食,冷藏保存',
`origin` = '福建漳州,广东广州,海南三亚',
`detail` = '杨桃：果形五角星形，果皮半透明黄绿色，果肉脆嫩多汁，酸甜爽口，含水量约90%。适合鲜食、制作果汁、水果拼盘。横切呈星形，适合摆盘装饰。冷藏后口感更佳。'
WHERE `id` = 134;

-- =====================================================
-- 二、柑橘类商品修正（135-144）
-- =====================================================

-- 135. 白心蜜柚
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.80,
`flash_start_time` = '2026-06-09 19:00:00',
`flash_end_time` = '2026-06-09 22:00:00',
`flash_stock` = 40,
`keywords` = '蜜柚,白心蜜柚,平和柚,秋季水果,清甜,多汁,冷藏保存',
`origin` = '福建平和,广东梅州,江西赣州',
`detail` = '白心蜜柚：果形圆球形，果皮淡黄，果肉雪白，清甜多汁，略带苦味，有清热解毒功效。适合鲜食、制作柚子茶。常温可存1-2个月。'
WHERE `id` = 135;

-- 136. 红西柚
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.50,
`flash_start_time` = '2026-06-10 09:00:00',
`flash_end_time` = '2026-06-10 12:00:00',
`flash_stock` = 25,
`keywords` = '红西柚,葡萄柚,西柚,减脂水果,酸甜,维C,榨汁,冷藏保存',
`origin` = '福建漳州,广东广州,云南瑞丽',
`detail` = '红西柚：果形扁圆，果皮橙黄，果肉粉红至红色，酸甜苦三层口感，富含维C和番茄红素。适合榨汁、制作水果沙拉、减脂代餐。建议加蜂蜜调味更佳。'
WHERE `id` = 136;

-- 137. 红心柚
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-10 19:00:00',
`flash_end_time` = '2026-06-10 22:00:00',
`flash_stock` = 35,
`keywords` = '红心柚,三红柚,蜜柚,秋季水果,清甜,多汁,冷藏保存',
`origin` = '福建平和,江西赣州,广东梅州',
`detail` = '红心柚：三红品种（果皮淡粉、海绵层粉红、果肉红色），果肉红艳，甜度高，酸度低，富含番茄红素。适合鲜食、制作柚子沙拉。常温可存1-2个月。'
WHERE `id` = 137;

-- 138. 黄心柚
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-11 09:00:00',
`flash_end_time` = '2026-06-11 12:00:00',
`flash_stock` = 35,
`keywords` = '黄心柚,黄金柚,蜜柚,秋季水果,清甜,多汁,冷藏保存',
`origin` = '福建平和,广东韶关,广西容县',
`detail` = '黄心柚：果肉金黄色，介于白心和红心之间，甜度高，水分足，口感清爽。适合鲜食、制作柚子茶。常温可存1-2个月。'
WHERE `id` = 138;

-- 139. 金桔
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-06-11 19:00:00',
`flash_end_time` = '2026-06-11 22:00:00',
`flash_stock` = 30,
`keywords` = '金桔,金橘,连皮吃,维C,润喉,止咳,泡水,冷藏保存',
`origin` = '广西阳朔,江西遂川,浙江宁波',
`detail` = '金桔：果形椭圆形，果皮金黄光滑，皮厚肉少，带皮食用，酸甜清香，富含维C。适合鲜食、制作金桔蜜饯、金桔茶、止咳化痰。清洗干净后可连皮食用。'
WHERE `id` = 139;

-- 140. 橘子
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 7.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-06-12 09:00:00',
`flash_end_time` = '2026-06-12 12:00:00',
`flash_stock` = 60,
`keywords` = '橘子,柑橘,蜜橘,秋季水果,清甜,多汁,维C,冷藏保存',
`origin` = '江西南丰,浙江黄岩,湖北宜昌',
`detail` = '橘子：果形扁圆，果皮橙黄易剥，果肉细嫩化渣，酸甜适口，维C丰富。适合鲜食、榨汁、制作水果拼盘。阴凉通风处可存1-2周。'
WHERE `id` = 140;

-- 141. 青柠
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-12 19:00:00',
`flash_end_time` = '2026-06-12 22:00:00',
`flash_stock` = 40,
`keywords` = '青柠,柠檬青柠,泰国青柠,调酒,东南亚菜,酸味,冷藏保存',
`origin` = '海南海口,云南西双版纳,广东广州',
`detail` = '青柠：果形圆小，果皮青绿，香气比黄柠檬更清新，酸度更高。适合调制莫吉托鸡尾酒、制作泰式料理、柠檬水。冷藏可保存2-3周。'
WHERE `id` = 141;

-- 142. 砂糖橘
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-06-13 09:00:00',
`flash_end_time` = '2026-06-13 12:00:00',
`flash_stock` = 50,
`keywords` = '砂糖橘,四会砂糖橘,年货水果,清甜,无籽,鲜食,冷藏保存',
`origin` = '广东四会,广西荔浦,湖南永兴',
`detail` = '砂糖橘：果形小巧扁圆，果皮橙红薄脆，果肉极甜化渣，甜度约14-16度，几乎无酸，无籽或少籽。适合鲜食、春节年货。冷藏可保存2-3周。'
WHERE `id` = 142;

-- 143. 小青桔
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-06-13 19:00:00',
`flash_end_time` = '2026-06-13 22:00:00',
`flash_stock` = 35,
`keywords` = '小青桔,青桔,酸柑,越南菜,调味,酸爽,冷藏保存',
`origin` = '海南海口,广西南宁,云南瑞丽',
`detail` = '小青桔：果形圆小如弹珠，果皮青绿，酸度极高，香气强烈。适合制作越南米粉蘸料、泰国菜调味、青桔柠檬水。冷冻可长期保存，使用时直接取用。'
WHERE `id` = 143;

-- 144. 血橙
UPDATE `goods` SET 
`price` = 11.80,
`original_price` = 15.80,
`flash_price` = 8.90,
`flash_start_time` = '2026-06-14 09:00:00',
`flash_end_time` = '2026-06-14 12:00:00',
`flash_stock` = 25,
`keywords` = '血橙,红橙,塔罗科血橙,冬季水果,酸甜,花青素,榨汁,冷藏保存',
`origin` = '四川资中,重庆万州,湖南怀化',
`detail` = '血橙：果形椭圆，果皮橙黄带红晕，果肉深红色至紫红色，富含花青素，酸甜适口，有淡淡树莓香气。适合鲜食、榨汁、制作水果沙拉。'
WHERE `id` = 144;

-- =====================================================
-- 三、瓜类水果修正（145-147）
-- =====================================================

-- 145. 刺角瓜
UPDATE `goods` SET 
`price` = 18.80,
`original_price` = 25.80,
`flash_price` = 14.80,
`flash_start_time` = '2026-06-14 19:00:00',
`flash_end_time` = '2026-06-14 22:00:00',
`flash_stock` = 10,
`keywords` = '刺角瓜,非洲黄瓜,火参果,奇异水果,清甜,吸管吸食,冷藏保存',
`origin` = '海南三亚,云南元谋,进口',
`detail` = '刺角瓜：果形椭圆带刺角，果皮橙黄，果肉绿色凝胶状，像黄瓜和西葫芦的混合，清甜淡雅。适合切开用吸管吸食、制作水果拼盘。冷藏后口感更佳。'
WHERE `id` = 145;

-- 146. 黄瓤西瓜
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.80,
`flash_start_time` = '2026-06-15 09:00:00',
`flash_end_time` = '2026-06-15 12:00:00',
`flash_stock` = 50,
`unit` = '个',
`keywords` = '黄瓤西瓜,特小凤,黄心西瓜,夏季水果,清甜,小巧,冷藏保存',
`origin` = '河南夏邑,江苏东台,山东潍坊',
`detail` = '黄瓤西瓜：特小凤品种，果形小巧圆润，果皮翠绿带条纹，果肉金黄，清甜爽口，甜度约12-14度。适合鲜食、制作水果拼盘。单果重约2-3斤。'
WHERE `id` = 146;

-- 147. 羊角蜜
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-06-15 19:00:00',
`flash_end_time` = '2026-06-15 22:00:00',
`flash_stock` = 25,
`keywords` = '羊角蜜,羊角脆,甜瓜,薄皮甜瓜,清脆,夏季水果,冷藏保存',
`origin` = '山东潍坊,河北青县,辽宁新民',
`detail` = '羊角蜜：果形长锥形如羊角，果皮淡绿，果肉绿色，质地酥脆，汁水丰富，甜度约12-14度。适合鲜食、切块食用。皮薄可连皮食用，冷藏后口感更脆。'
WHERE `id` = 147;

-- =====================================================
-- 四、核果类商品修正（148-172）
-- =====================================================

-- 148. 脆李
UPDATE `goods` SET 
`price` = 10.80,
`original_price` = 14.80,
`flash_price` = 8.50,
`flash_start_time` = '2026-06-16 09:00:00',
`flash_end_time` = '2026-06-16 12:00:00',
`flash_stock` = 30,
`keywords` = '脆李,青脆李,脱骨李,夏季水果,清脆,酸甜,冷藏保存',
`origin` = '四川汶川,贵州六盘水,重庆巫山',
`detail` = '脆李：果形圆球形，果皮青绿带白霜，果肉翠绿，离核脆爽，酸甜适口。适合鲜食、制作李子果酱。口感脆硬，喜欢软糯的可常温放置几天。'
WHERE `id` = 148;

-- 149. 冬枣
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 22.80,
`flash_price` = 12.50,
`flash_start_time` = '2026-06-16 19:00:00',
`flash_end_time` = '2026-06-16 22:00:00',
`flash_stock` = 20,
`keywords` = '冬枣,沾化冬枣,大荔冬枣,秋季水果,脆甜,维C之王,冷藏保存',
`origin` = '山东沾化,陕西大荔,河北黄骅',
`detail` = '冬枣：果形圆润，果皮黄绿带红晕，果肉雪白细脆，甜度约20-25度，有天然冰糖甜。适合鲜食、制作水果拼盘。冷藏可保存2-3周。'
WHERE `id` = 149;

-- 150. 贵妃芒
UPDATE `goods` SET 
`price` = 16.80,
`original_price` = 22.80,
`flash_price` = 12.80,
`flash_start_time` = '2026-06-17 09:00:00',
`flash_end_time` = '2026-06-17 12:00:00',
`flash_stock` = 20,
`keywords` = '贵妃芒,红金龙芒,热带水果,软糯香甜,纤维少,鲜食,冷藏保存',
`origin` = '海南三亚,广西百色,云南元江',
`detail` = '贵妃芒：果形长卵形，果皮黄红艳丽，果肉金黄，软糯香甜，纤维极少，甜度约16-18度。适合鲜食、制作芒果糯米饭、芒果汁。'
WHERE `id` = 150;

-- 151. 红毛丹
UPDATE `goods` SET 
`price` = 22.80,
`original_price` = 29.80,
`flash_price` = 17.80,
`flash_start_time` = '2026-06-17 19:00:00',
`flash_end_time` = '2026-06-17 22:00:00',
`flash_stock` = 12,
`keywords` = '红毛丹,毛荔枝,热带水果,鲜食,软糯,酸甜,冷藏保存',
`origin` = '海南保亭,广东茂名,泰国进口',
`detail` = '红毛丹：果形圆球形，外壳密布红色软毛刺，果肉雪白半透明，软嫩多汁，酸甜适口，口感像荔枝但更Q弹。适合鲜食、制作水果拼盘。'
WHERE `id` = 151;

-- 152. 红枣
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.80,
`flash_start_time` = '2026-06-18 09:00:00',
`flash_end_time` = '2026-06-18 12:00:00',
`flash_stock` = 25,
`keywords` = '红枣,鲜枣,冬枣,脆甜,补血,鲜食,冷藏保存',
`origin` = '山西稷山,新疆若羌,河南新郑',
`detail` = '红枣：鲜食红枣品种，果形椭圆，果皮黄绿带红，果肉雪白，脆甜多汁，甜度约18-20度。适合鲜食、煲汤、制作红枣茶。鲜枣维C含量极高。'
WHERE `id` = 152;

-- 153. 黄杏
UPDATE `goods` SET 
`price` = 14.80,
`original_price` = 19.80,
`flash_price` = 11.50,
`flash_start_time` = '2026-06-18 19:00:00',
`flash_end_time` = '2026-06-18 22:00:00',
`flash_stock` = 20,
`keywords` = '黄杏,凯特杏,夏季水果,酸甜,软糯,鲜食,冷藏保存',
`origin` = '河北巨鹿,陕西礼泉,山东临沂',
`detail` = '黄杏：果形圆球形，果皮金黄带红晕，果肉橙黄，软糯多汁，酸甜适口。适合鲜食、制作杏酱、杏干。手感硬的可常温催熟变软。'
WHERE `id` = 153;

-- 154. 黄樱桃
UPDATE `goods` SET 
`price` = 68.80,
`original_price` = 89.80,
`flash_price` = 58.80,
`flash_start_time` = '2026-06-19 09:00:00',
`flash_end_time` = '2026-06-19 12:00:00',
`flash_stock` = 8,
`keywords` = '黄樱桃,黄蜜樱桃,水晶樱桃,甜度高,软嫩,鲜食,冷藏保存',
`origin` = '山东烟台,辽宁大连,陕西铜川',
`detail` = '黄樱桃：黄蜜品种，果形心形，果皮金黄带红晕，果肉淡黄，肉质软嫩，甜度可达22度以上，是樱桃中最甜的品种。适合鲜食、赠送礼品。非常娇嫩，建议冷藏并及时食用。'
WHERE `id` = 154;

-- 155. 金煌芒
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.50,
`flash_start_time` = '2026-06-19 19:00:00',
`flash_end_time` = '2026-06-19 22:00:00',
`flash_stock` = 25,
`keywords` = '金煌芒,大芒果,热带水果,清甜,肉质厚,纤维少,鲜食,冷藏保存',
`origin` = '海南昌江,广西田阳,云南华坪',
`detail` = '金煌芒：果形长肾形，个大，单果重约400-600克，果皮金黄，果肉淡黄，肉质厚实，甜度约16-18度，纤维极少。适合鲜食、制作芒果慕斯、芒果汁。'
WHERE `id` = 155;

-- 156. 荔枝
UPDATE `goods` SET 
`price` = 18.80,
`original_price` = 25.80,
`flash_price` = 14.80,
`flash_start_time` = '2026-06-20 09:00:00',
`flash_end_time` = '2026-06-20 12:00:00',
`flash_stock` = 20,
`keywords` = '荔枝,妃子笑,糯米糍,桂味,夏季水果,一骑红尘,鲜食,冷藏保存',
`origin` = '广东茂名,海南海口,福建莆田',
`detail` = '荔枝：妃子笑品种，果形心形，果皮红绿相间，果肉雪白半透明，软嫩多汁，香甜可口。适合鲜食、制作荔枝冰沙、荔枝饮料。谚语：一颗荔枝三把火，一次勿食过多。'
WHERE `id` = 156;

-- 157. 榴莲
UPDATE `goods` SET 
`price` = 39.80,
`original_price` = 59.80,
`flash_price` = 32.80,
`flash_start_time` = '2026-06-20 19:00:00',
`flash_end_time` = '2026-06-20 22:00:00',
`flash_stock` = 10,
`keywords` = '榴莲,金枕头,猫山王,水果之王,软糯,香气浓郁,冷冻保存',
`origin` = '海南三亚,广东茂名,泰国进口',
`detail` = '榴莲：金枕头品种，果形椭圆带尖刺，果壳金黄，果肉淡黄，软糯香甜，口感像奶油冰淇淋。适合鲜食、制作榴莲披萨、榴莲蛋糕。挑选窍门：摇动有响声、果壳开缝、香气浓郁为佳。'
WHERE `id` = 157;

-- 158. 龙眼
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.50,
`flash_start_time` = '2026-06-21 09:00:00',
`flash_end_time` = '2026-06-21 12:00:00',
`flash_stock` = 30,
`keywords` = '龙眼,桂圆,储良龙眼,夏季水果,香甜,滋补,鲜食,冷藏保存',
`origin` = '广东高州,广西平南,福建莆田',
`detail` = '龙眼：储良品种，果形圆球形，果皮黄褐，果肉雪白半透明，软韧多汁，香甜可口，可做中药材。适合鲜食、制作桂圆干、桂圆红枣茶。'
WHERE `id` = 158;

-- 159. 牛奶青枣
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.50,
`flash_start_time` = '2026-06-21 19:00:00',
`flash_end_time` = '2026-06-21 22:00:00',
`flash_stock` = 25,
`keywords` = '牛奶青枣,青枣,台湾青枣,冬季水果,清脆,清甜,冷藏保存',
`origin` = '福建漳州,广东广州,海南海口',
`detail` = '牛奶青枣：果形卵圆形，果皮青绿，果肉雪白，肉质清脆，汁水丰富，清甜淡雅。适合鲜食、制作水果拼盘。冷藏后口感更佳。'
WHERE `id` = 159;

-- 160. 蟠桃
UPDATE `goods` SET 
`price` = 19.80,
`original_price` = 26.80,
`flash_price` = 15.80,
`flash_start_time` = '2026-06-22 09:00:00',
`flash_end_time` = '2026-06-22 12:00:00',
`flash_stock` = 15,
`keywords` = '蟠桃,扁桃,仙桃,夏季水果,软糯,香甜,鲜食,冷藏保存',
`origin` = '新疆石河子,山东临沂,河北保定',
`detail` = '蟠桃：果形扁平如盘，果皮黄红，果肉金黄，软糯香甜，汁水丰富，传说中王母娘娘的仙桃。适合鲜食、制作水果拼盘。'
WHERE `id` = 160;

-- 161. 苹果李
UPDATE `goods` SET 
`price` = 14.80,
`original_price` = 19.80,
`flash_price` = 11.50,
`flash_start_time` = '2026-06-22 19:00:00',
`flash_end_time` = '2026-06-22 22:00:00',
`flash_stock` = 20,
`keywords` = '苹果李,李子,酸甜,清脆,夏季水果,鲜食,冷藏保存',
`origin` = '四川汉源,贵州镇宁,重庆巫山',
`detail` = '苹果李：果形圆球形似苹果，果皮紫红，果肉红黄，离核脆爽，酸甜适口，有苹果香气。适合鲜食、制作水果沙拉。'
WHERE `id` = 161;

-- 162. 青芒果
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-23 09:00:00',
`flash_end_time` = '2026-06-23 12:00:00',
`flash_stock` = 30,
`keywords` = '青芒果,生芒果,酸芒,东南亚料理,脆酸,凉拌,常温保存',
`origin` = '海南三亚,云南西双版纳,广西百色',
`detail` = '青芒果：未成熟的青皮芒果，果肉脆硬，酸度极高，适合制作泰式凉拌青木瓜沙拉、酸芒果蘸辣椒盐。常温存放，勿催熟。'
WHERE `id` = 162;

-- 163. 蛇皮果
UPDATE `goods` SET 
`price` = 28.80,
`original_price` = 38.80,
`flash_price` = 22.80,
`flash_start_time` = '2026-06-23 19:00:00',
`flash_end_time` = '2026-06-23 22:00:00',
`flash_stock` = 10,
`keywords` = '蛇皮果,沙叻,热带水果,酸甜,脆韧,特色水果,冷藏保存',
`origin` = '海南琼海,云南西双版纳,印尼进口',
`detail` = '蛇皮果：果形卵圆形，果皮棕褐色如蛇皮鳞片，果肉乳白或淡黄，分为3瓣，口感脆韧，酸甜适口。适合鲜食、制作水果拼盘。'
WHERE `id` = 163;

-- 164. 释迦果
UPDATE `goods` SET 
`price` = 26.80,
`original_price` = 35.80,
`flash_price` = 20.80,
`flash_start_time` = '2026-06-24 09:00:00',
`flash_end_time` = '2026-06-24 12:00:00',
`flash_stock` = 10,
`keywords` = '释迦果,番荔枝,佛头果,热带水果,甜度高,软糯,鲜食,冷藏保存',
`origin` = '海南三亚,台湾台东,广东广州',
`detail` = '释迦果：果形圆锥形如佛头，果皮翠绿，果肉雪白软糯，甜度可达20-25度，有百香果和香蕉混合香气。适合鲜食、制作冰淇淋。手感变软后食用，冷藏后口感更佳。'
WHERE `id` = 164;

-- 165. 西梅
UPDATE `goods` SET 
`price` = 22.80,
`original_price` = 29.80,
`flash_price` = 17.80,
`flash_start_time` = '2026-06-24 19:00:00',
`flash_end_time` = '2026-06-24 22:00:00',
`flash_stock` = 15,
`keywords` = '西梅,欧洲李,加州西梅,秋季水果,清甜,通便,鲜食,冷藏保存',
`origin` = '新疆喀什,陕西渭南,进口',
`detail` = '西梅：果形卵圆形，果皮紫红，果肉金黄，软糯多汁，甜度约16-18度，通便效果好。适合鲜食、制作西梅干、西梅汁。'
WHERE `id` = 165;

-- 166. 小台芒
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-06-25 09:00:00',
`flash_end_time` = '2026-06-25 12:00:00',
`flash_stock` = 35,
`keywords` = '小台芒,台农芒,热带水果,香甜,纤维多,鲜食,冷藏保存',
`origin` = '海南三亚,广西百色,云南元江',
`detail` = '小台芒：果形肾形，个头小巧，单果重约50-80克，果皮金黄，果肉橙黄，香气浓郁，甜度约16-18度。适合鲜食、制作甜品。'
WHERE `id` = 166;

-- 167. 杨梅
UPDATE `goods` SET 
`price` = 19.80,
`original_price` = 26.80,
`flash_price` = 15.80,
`flash_start_time` = '2026-06-25 19:00:00',
`flash_end_time` = '2026-06-25 22:00:00',
`flash_stock` = 15,
`keywords` = '杨梅,东魁杨梅,荸荠种,夏季水果,酸甜,多汁,冷藏保存',
`origin` = '浙江仙居,湖南靖州,云南富民',
`detail` = '杨梅：东魁品种，果形圆球形，表面密布细刺，果色紫红，果肉软嫩，酸甜多汁。适合鲜食、制作杨梅酒、冰镇杨梅汤。建议盐水浸泡10分钟再食用。'
WHERE `id` = 167;

-- 168. 椰子
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.50,
`flash_start_time` = '2026-06-26 09:00:00',
`flash_end_time` = '2026-06-26 12:00:00',
`flash_stock` = 25,
`unit` = '个',
`keywords` = '椰子,青椰,椰青,热带水果,解渴,椰汁,椰肉,冷藏保存',
`origin` = '海南文昌,海南琼海,越南进口',
`detail` = '椰子：青椰品种，果形圆球形，外壳青绿，内有一层厚椰肉和清甜椰汁。适合喝椰汁、挖椰肉食用、制作椰子鸡。冷藏后口感更佳，单果约2-3斤。'
WHERE `id` = 168;

-- 169. 樱桃李
UPDATE `goods` SET 
`price` = 18.80,
`original_price` = 25.80,
`flash_price` = 14.80,
`flash_start_time` = '2026-06-26 19:00:00',
`flash_end_time` = '2026-06-26 22:00:00',
`flash_stock` = 15,
`keywords` = '樱桃李,野酸梅,紫色水果,酸甜,花青素,鲜食,冷藏保存',
`origin` = '新疆伊犁,甘肃天水,四川阿坝',
`detail` = '樱桃李：果形小圆球形似樱桃，果皮紫红，果肉红黄，酸甜适口，富含花青素。适合鲜食、制作果酱。'
WHERE `id` = 169;

-- 170. 油柑子
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 20.80,
`flash_price` = 12.50,
`flash_start_time` = '2026-06-27 09:00:00',
`flash_end_time` = '2026-06-27 12:00:00',
`flash_stock` = 20,
`keywords` = '油柑子,余甘子,滇橄榄,先苦后甜,回甘,泡酒,冷藏保存',
`origin` = '云南普洱,福建安溪,广东潮州',
`detail` = '油柑子：果形扁圆，果皮青绿，果肉酸涩，初入口酸涩难忍，之后口腔会持续回甘生津。适合腌制、泡油柑酒、制作油柑汁。'
WHERE `id` = 170;

-- 171. 油奈
UPDATE `goods` SET 
`price` = 16.80,
`original_price` = 22.80,
`flash_price` = 13.50,
`flash_start_time` = '2026-06-27 19:00:00',
`flash_end_time` = '2026-06-27 22:00:00',
`flash_stock` = 15,
`keywords` = '油奈,李柰,青柰,福建特产,清脆,酸甜,鲜食,冷藏保存',
`origin` = '福建古田,福建屏南,福建建瓯',
`detail` = '油奈：福建特色水果，外形似桃形李，果皮青绿带黄，果肉金黄，离核脆爽，酸甜适口。适合鲜食、制作李柰果脯。'
WHERE `id` = 171;

-- 172. 油桃
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.50,
`flash_start_time` = '2026-06-28 09:00:00',
`flash_end_time` = '2026-06-28 12:00:00',
`flash_stock` = 25,
`keywords` = '油桃,光桃,无毛桃,夏季水果,脆甜,鲜食,冷藏保存',
`origin` = '山东临沂,陕西渭南,河北秦皇岛',
`detail` = '油桃：果形圆球形，果皮光滑无毛，颜色鲜红或金黄，果肉黄白，肉质脆甜或软糯。适合鲜食、制作水果拼盘。'
WHERE `id` = 172;

-- =====================================================
-- 五、仁果类商品修正（173-187）
-- =====================================================

-- 173. 阿克苏苹果
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.50,
`flash_start_time` = '2026-06-28 19:00:00',
`flash_end_time` = '2026-06-28 22:00:00',
`flash_stock` = 30,
`keywords` = '阿克苏苹果,冰糖心苹果,新疆苹果,清脆,甜度高,冷藏保存',
`origin` = '新疆阿克苏,新疆伊犁,甘肃天水',
`detail` = '阿克苏苹果：产自新疆阿克苏红旗坡，因昼夜温差大形成独特冰糖心，果形不规整，果皮红黄相间，果肉黄白酥脆，甜度约18-20度，冰糖心明显。'
WHERE `id` = 173;

-- 174. 丰水梨
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-06-29 09:00:00',
`flash_end_time` = '2026-06-29 12:00:00',
`flash_stock` = 30,
`keywords` = '丰水梨,日本梨,多汁,酥脆,清甜,秋季水果,冷藏保存',
`origin` = '山东莱阳,安徽砀山,河北赵县',
`detail` = '丰水梨：日本引进品种，果形圆球形，果皮黄褐带细点，果肉雪白酥脆，汁水极多，甜度约12-14度。适合鲜食、煮梨汤。'
WHERE `id` = 174;

-- 175. 嘎啦苹果
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-06-29 19:00:00',
`flash_end_time` = '2026-06-29 22:00:00',
`flash_stock` = 40,
`keywords` = '嘎啦苹果,早熟苹果,清脆,酸甜,鲜食,冷藏保存',
`origin` = '陕西洛川,山东烟台,山西临汾',
`detail` = '嘎啦苹果：早熟品种，果形端正，果皮红色条纹，果肉黄白，肉质细脆，酸甜适口，苹果香气浓郁。适合鲜食、榨汁。'
WHERE `id` = 175;

-- 176. 红地厘蛇果
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.80,
`flash_start_time` = '2026-06-30 09:00:00',
`flash_end_time` = '2026-06-30 12:00:00',
`flash_stock` = 20,
`keywords` = '蛇果,红地厘蛇果,美国苹果,全红,香甜,鲜食,冷藏保存',
`origin` = '山东烟台,陕西洛川,美国进口',
`detail` = '红地厘蛇果：果形圆锥形，通体鲜红发亮，果肉黄白，肉质松脆，甜度较高，香气独特。适合鲜食、送礼。'
WHERE `id` = 176;

-- 177. 红香酥梨
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-06-30 19:00:00',
`flash_end_time` = '2026-06-30 22:00:00',
`flash_stock` = 35,
`keywords` = '红香酥梨,红梨,酥梨,脆甜,多汁,冷藏保存',
`origin` = '河北晋州,山西隰县,陕西蒲城',
`detail` = '红香酥梨：果形葫芦形，果皮黄底红晕，果肉雪白酥脆，汁水丰富，甜度约13-15度，香气清雅。适合鲜食。'
WHERE `id` = 177;

-- 178. 黄元帅苹果
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 11.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-07-01 09:00:00',
`flash_end_time` = '2026-07-01 12:00:00',
`flash_stock` = 35,
`keywords` = '黄元帅苹果,金冠苹果,黄苹果,绵软,香甜,榨汁,冷藏保存',
`origin` = '辽宁大连,甘肃天水,新疆阿克苏',
`detail` = '黄元帅苹果：果形圆锥形，果皮金黄色，果肉淡黄，肉质松软，甜度约15-17度，适合牙口不好的人。适合鲜食、制作苹果泥、榨汁。'
WHERE `id` = 178;

-- 179. 库尔勒香梨
UPDATE `goods` SET 
`price` = 11.80,
`original_price` = 15.80,
`flash_price` = 8.90,
`flash_start_time` = '2026-07-01 19:00:00',
`flash_end_time` = '2026-07-01 22:00:00',
`flash_stock` = 30,
`keywords` = '库尔勒香梨,新疆香梨,无渣,脆甜,香气浓郁,冷藏保存',
`origin` = '新疆库尔勒,新疆阿克苏,甘肃张掖',
`detail` = '库尔勒香梨：果形小巧葫芦形，果皮黄绿带红晕，果肉雪白细嫩，无渣酥脆，香气浓郁，甜度约13-15度。适合鲜食，冷藏后口感更佳。'
WHERE `id` = 179;

-- 180. 奶油苹果
UPDATE `goods` SET 
`price` = 14.80,
`original_price` = 19.80,
`flash_price` = 11.50,
`flash_start_time` = '2026-07-02 09:00:00',
`flash_end_time` = '2026-07-02 12:00:00',
`flash_stock` = 25,
`keywords` = '奶油苹果,维纳斯黄金,黄色苹果,甜脆,奶香,冷藏保存',
`origin` = '山东烟台,陕西洛川,辽宁大连',
`detail` = '奶油苹果：维纳斯黄金品种，果形圆锥形，果皮金黄色，果肉淡黄，肉质脆甜，带淡淡奶油香气，甜度约16-18度。适合鲜食。'
WHERE `id` = 180;

-- 181. 青苹果
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-07-02 19:00:00',
`flash_end_time` = '2026-07-02 22:00:00',
`flash_stock` = 40,
`keywords` = '青苹果,澳洲青苹,酸苹果,清脆,酸甜,榨汁,烘焙,冷藏保存',
`origin` = '山东烟台,陕西渭南,甘肃天水',
`detail` = '青苹果：果形圆球形，通体青绿，果肉雪白，肉质硬脆，酸度较高，甜酸比约1:3。适合鲜食（喜酸者）、榨苹果汁、制作苹果派。'
WHERE `id` = 181;

-- 182. 秋月梨
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.80,
`flash_start_time` = '2026-07-03 09:00:00',
`flash_end_time` = '2026-07-03 12:00:00',
`flash_stock` = 25,
`keywords` = '秋月梨,日本梨,大果梨,酥脆,汁多,甜度高,冷藏保存',
`origin` = '山东莱阳,安徽砀山,河北威县',
`detail` = '秋月梨：日本引进品种，果形扁圆，果皮黄褐，果肉雪白，酥脆无渣，汁水极多，甜度约14-16度。被誉为梨中爱马仕，适合鲜食。'
WHERE `id` = 182;

-- 183. 山楂
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-03 19:00:00',
`flash_end_time` = '2026-07-03 22:00:00',
`flash_stock` = 30,
`keywords` = '山楂,红果,山里红,开胃,消食,冰糖葫芦,烘焙,冷藏保存',
`origin` = '山东青州,河北兴隆,辽宁葫芦岛',
`detail` = '山楂：果形圆球形，果皮鲜红带白点，果肉粉白，酸中带甜，消食健胃。适合制作冰糖葫芦、山楂糕、山楂茶、山楂片。'
WHERE `id` = 183;

-- 184. 香酥梨
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-04 09:00:00',
`flash_end_time` = '2026-07-04 12:00:00',
`flash_stock` = 30,
`keywords` = '香酥梨,酥梨,早酥梨,脆甜,多汁,冷藏保存',
`origin` = '山西隰县,陕西蒲城,河北深州',
`detail` = '香酥梨：果形圆球形，果皮黄绿，果肉雪白，酥脆多汁，甜度约12-14度，香气清雅。适合鲜食。'
WHERE `id` = 184;

-- 185. 雪花梨
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 8.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-04 19:00:00',
`flash_end_time` = '2026-07-04 22:00:00',
`flash_stock` = 45,
`keywords` = '雪花梨,河北梨,大梨,脆甜,润肺,煮汤,冷藏保存',
`origin` = '河北赵县,河北泊头,山东阳信',
`detail` = '雪花梨：果形大圆球形，果皮黄绿粗糙，果肉雪白细脆，汁多味甜，果肉切开后洁白如雪。适合鲜食、煮冰糖雪梨汤。'
WHERE `id` = 185;

-- 186. 鸭梨
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 7.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-05 09:00:00',
`flash_end_time` = '2026-07-05 12:00:00',
`flash_stock` = 50,
`keywords` = '鸭梨,白梨,河北鸭梨,脆甜,解渴,润肺,冷藏保存',
`origin` = '河北泊头,山东阳信,安徽砀山',
`detail` = '鸭梨：果形倒卵形似鸭头，果皮黄白，果肉雪白细脆，汁多清甜，是北方传统梨品种。适合鲜食、煮汤。'
WHERE `id` = 186;

-- 187. 早酥梨
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 8.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-05 19:00:00',
`flash_end_time` = '2026-07-05 22:00:00',
`flash_stock` = 40,
`keywords` = '早酥梨,早熟梨,酥梨,脆甜,多汁,夏季水果,冷藏保存',
`origin` = '陕西蒲城,山西隰县,安徽砀山',
`detail` = '早酥梨：早熟品种，果形圆球形，果皮黄绿，果肉雪白，酥脆多汁，甜度约11-13度。适合鲜食，是夏季最早上市的梨品种之一。'
WHERE `id` = 187;

-- =====================================================
-- 六、聚花果及其他水果修正（188-190）
-- =====================================================

-- 188. 菠萝蜜
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-07-06 09:00:00',
`flash_end_time` = '2026-07-06 12:00:00',
`flash_stock` = 25,
`unit` = '斤',
`keywords` = '菠萝蜜,木菠萝,热带水果,香甜,软糯,取肉食用,冷藏保存',
`origin` = '海南琼海,广东湛江,广西南宁',
`detail` = '菠萝蜜：热带巨型水果，单果重可达10-20斤，果肉金黄软糯，香甜浓郁，口感像香蕉和菠萝混合。适合取肉鲜食、制作菠萝蜜干果。种子可煮熟食用。'
WHERE `id` = 188;

-- 189. 甘蔗
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-07-06 19:00:00',
`flash_end_time` = '2026-07-06 22:00:00',
`flash_stock` = 60,
`keywords` = '甘蔗,黑皮甘蔗,糖蔗,清甜,榨汁,冬季水果,冷藏保存',
`origin` = '广西来宾,广东湛江,云南开远',
`detail` = '甘蔗：黑皮甘蔗品种，秆粗节长，皮黑肉白，汁水丰富，甜度极高。适合直接啃食、榨甘蔗汁、制作红糖。建议去皮后切段食用或榨汁。'
WHERE `id` = 189;

-- 190. 雪莲果
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-07 09:00:00',
`flash_end_time` = '2026-07-07 12:00:00',
`flash_stock` = 40,
`keywords` = '雪莲果,菊薯,地参果,脆甜,低聚果糖,生食,凉拌,冷藏保存',
`origin` = '云南昆明,四川西昌,福建龙岩',
`detail` = '雪莲果：形似红薯，果皮黄褐，果肉雪白透明，口感脆甜如雪梨，富含低聚果糖（不易被人体吸收的天然甜味剂）。适合生食、凉拌、榨汁。'
WHERE `id` = 190;

-- =====================================================
-- 七、蔬菜类商品修正（19-106）
-- =====================================================

-- 19. 豆芽
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 4.80,
`flash_price` = 1.90,
`flash_start_time` = '2026-07-07 19:00:00',
`flash_end_time` = '2026-07-07 22:00:00',
`flash_stock` = 80,
`keywords` = '豆芽,绿豆芽,黄豆芽,家常蔬菜,脆嫩,快炒,凉拌,冷藏保存',
`origin` = '湖南长沙,四川成都,山东寿光',
`detail` = '豆芽：绿豆芽品种，根茎雪白，豆瓣淡黄，脆嫩爽口。适合快炒、凉拌、做水煮鱼配菜。建议到货后尽快食用，冷藏可保存2-3天。'
WHERE `id` = 19;

-- 20. 荷兰豆
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-08 09:00:00',
`flash_end_time` = '2026-07-08 12:00:00',
`flash_stock` = 40,
`keywords` = '荷兰豆,蜜豆,豌豆荚,脆甜,快炒,便当配菜,冷藏保存',
`origin` = '云南通海,甘肃兰州,河北张北',
`detail` = '荷兰豆：豆荚扁平翠绿，豆粒隐约可见，脆嫩清甜。适合清炒、蒜蓉荷兰豆、沙拉。建议去筋后烹饪，焯水后过冷水可保持翠绿。'
WHERE `id` = 20;

-- 21. 毛豆
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-08 19:00:00',
`flash_end_time` = '2026-07-08 22:00:00',
`flash_stock` = 60,
`keywords` = '毛豆,大豆,盐水毛豆,下酒菜,高蛋白,水煮,冷冻保存',
`origin` = '江苏启东,黑龙江海伦,安徽亳州',
`detail` = '毛豆：新鲜大豆荚，豆荚青绿带绒毛，豆粒翠绿饱满。适合盐水煮毛豆、炒肉末、做配菜。剪掉豆荚两端更易入味。'
WHERE `id` = 21;

-- 22. 四季豆
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-09 09:00:00',
`flash_end_time` = '2026-07-09 12:00:00',
`flash_stock` = 50,
`keywords` = '四季豆,芸豆,菜豆,家常蔬菜,干煸,焖炖,需煮熟,冷藏保存',
`origin` = '山东寿光,河北永年,四川攀枝花',
`detail` = '四季豆：豆荚圆润饱满，颜色翠绿。适合干煸四季豆、焖面、炒肉末。务必须彻底煮熟（10-15分钟），否则可能引起不适。'
WHERE `id` = 22;

-- 23. 豌豆
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-07-09 19:00:00',
`flash_end_time` = '2026-07-09 22:00:00',
`flash_stock` = 45,
`keywords` = '豌豆,青豆,小豌豆,甜嫩,炒饭,配菜,冷冻保存',
`origin` = '江苏无锡,浙江温州,四川成都',
`detail` = '豌豆：豆粒圆润翠绿，甜嫩可口。适合豌豆炒饭、豌豆炒虾仁、豌豆浓汤。可以冷冻长期保存。'
WHERE `id` = 23;

-- 24. 长豆角
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-10 09:00:00',
`flash_end_time` = '2026-07-10 12:00:00',
`flash_stock` = 60,
`keywords` = '长豆角,豇豆,豆角,家常蔬菜,炒制,腌酸豆角,冷藏保存',
`origin` = '湖南湘潭,广西合浦,江西南昌',
`detail` = '长豆角：豆荚细长翠绿，质地脆嫩。适合蒜蓉炒长豆角、干煸豆角、腌酸豆角。切段烹饪更易入味。'
WHERE `id` = 24;

-- 25. 白萝卜
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 4.80,
`flash_price` = 1.80,
`flash_start_time` = '2026-07-10 19:00:00',
`flash_end_time` = '2026-07-10 22:00:00',
`flash_stock` = 100,
`keywords` = '白萝卜,萝卜,炖汤,腌萝卜,顺气,冬季蔬菜,冷藏保存',
`origin` = '山东潍坊,河南南阳,湖北荆州',
`detail` = '白萝卜：根茎类蔬菜，外皮雪白，肉质脆嫩，略带辛辣。适合炖排骨汤、腌萝卜条、红烧萝卜、羊肉炖萝卜。'
WHERE `id` = 25;

-- 26. 大蒜头
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-07-11 09:00:00',
`flash_end_time` = '2026-07-11 12:00:00',
`flash_stock` = 80,
`keywords` = '大蒜头,大蒜,调味,杀菌,爆香,阴凉保存',
`origin` = '河南杞县,山东金乡,云南大理',
`detail` = '大蒜头：每头由多个蒜瓣组成，外皮白或紫，辛辣味浓。适合做调味料（爆香）、制作蒜泥酱、糖蒜。阴凉通风处保存，可存放数月。'
WHERE `id` = 26;

-- 27. 独头蒜
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-07-11 19:00:00',
`flash_end_time` = '2026-07-11 22:00:00',
`flash_stock` = 50,
`keywords` = '独头蒜,独瓣蒜,辣度更高,调味,蒜泥,阴凉保存',
`origin` = '云南大理,四川温江,山东苍山',
`detail` = '独头蒜：不分瓣，整个蒜头为一瓣，辣度更高，蒜香更浓郁。适合制作蒜泥、黑蒜、糖醋蒜。'
WHERE `id` = 27;

-- 28. 红薯
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-07-12 09:00:00',
`flash_end_time` = '2026-07-12 12:00:00',
`flash_stock` = 100,
`keywords` = '红薯,地瓜,红心薯,烤红薯,蒸煮,甜糯,阴凉保存',
`origin` = '河南开封,河北卢龙,福建连城',
`detail` = '红薯：红皮黄心或红心品种，肉质软糯香甜。适合烤红薯、蒸红薯、红薯粥、拔丝红薯、红薯干。阴凉通风处可存1-2个月。'
WHERE `id` = 28;

-- 29. 胡萝卜
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-07-12 19:00:00',
`flash_end_time` = '2026-07-12 22:00:00',
`flash_stock` = 120,
`keywords` = '胡萝卜,红萝卜,胡萝卜素,炖汤,炒菜,榨汁,冷藏保存',
`origin` = '山东寿光,河南通许,河北围场',
`detail` = '胡萝卜：根茎类蔬菜，外皮橙红，肉质脆甜。适合炒胡萝卜丝、炖牛腩、榨胡萝卜汁、做沙拉。油炒后胡萝卜素更易吸收。'
WHERE `id` = 29;

-- 30. 茭白
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-13 09:00:00',
`flash_end_time` = '2026-07-13 12:00:00',
`flash_stock` = 40,
`keywords` = '茭白,茭笋,水生蔬菜,清炒,油焖,脆嫩,冷藏保存',
`origin` = '江苏苏州,浙江嘉兴,安徽芜湖',
`detail` = '茭白：水生蔬菜，外皮青绿，肉质雪白脆嫩，口感像笋。适合油焖茭白、茭白炒肉丝、凉拌茭白。'
WHERE `id` = 30;

-- 31. 莲藕
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-07-13 19:00:00',
`flash_end_time` = '2026-07-13 22:00:00',
`flash_stock` = 60,
`keywords` = '莲藕,藕,煲汤,凉拌,藕夹,粉糯,脆嫩,冷藏保存',
`origin` = '湖北洪湖,江苏宝应,广西贵港',
`detail` = '莲藕：根茎类蔬菜，藕节肥大，切面有孔，有七孔糯藕和九孔脆藕之分。适合炖排骨汤、凉拌藕片、炸藕合、桂花糯米藕。'
WHERE `id` = 31;

-- 32. 芦笋
UPDATE `goods` SET 
`price` = 14.80,
`original_price` = 19.80,
`flash_price` = 11.50,
`flash_start_time` = '2026-07-14 09:00:00',
`flash_end_time` = '2026-07-14 12:00:00',
`flash_stock` = 30,
`keywords` = '芦笋,绿芦笋,抗癌蔬菜,高纤维,清炒,焯水,冷藏保存',
`origin` = '山东曹县,河北丰宁,浙江长兴',
`detail` = '芦笋：嫩茎类蔬菜，茎秆青绿挺拔，笋尖紧实。适合清炒芦笋、焯水淋酱、芦笋培根卷。建议去掉根部老皮再烹饪。'
WHERE `id` = 32;

-- 33. 南姜
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-07-14 19:00:00',
`flash_end_time` = '2026-07-14 22:00:00',
`flash_stock` = 40,
`keywords` = '南姜,高良姜,潮汕调味,去腥,卤水,东南亚菜,冷冻保存',
`origin` = '广东潮州,广西玉林,云南西双版纳',
`detail` = '南姜：姜科植物，外皮红褐，比普通生姜更辛辣芳香。适合潮汕卤水、东南亚咖喱、去腥调味。可切片冷冻长期保存。'
WHERE `id` = 33;

-- 34. 山药
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-07-15 09:00:00',
`flash_end_time` = '2026-07-15 12:00:00',
`flash_stock` = 50,
`keywords` = '山药,铁棍山药,淮山,健脾,煲汤,蒸食,冷藏保存',
`origin` = '河南焦作,山东菏泽,河北保定',
`detail` = '山药：铁棍山药品种，根茎细长，外皮带须，肉质雪白粘滑。适合煲汤、清炒、蒸食、制作蓝莓山药。削皮时建议戴手套防痒。'
WHERE `id` = 34;

-- 35. 生姜
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-15 19:00:00',
`flash_end_time` = '2026-07-15 22:00:00',
`flash_stock` = 80,
`keywords` = '生姜,姜,调味,去腥,暖身,炒菜,煲汤,阴凉保存',
`origin` = '山东莱芜,湖南永州,四川乐山',
`detail` = '生姜：根茎类调味品，外皮黄褐，肉质黄白，辛辣味浓。适合去腥调味、姜茶、姜撞奶、泡姜。阴凉通风处保存，冰箱冷藏可延长保鲜。'
WHERE `id` = 35;

-- 36. 土豆
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 4.80,
`flash_price` = 1.80,
`flash_start_time` = '2026-07-16 09:00:00',
`flash_end_time` = '2026-07-16 12:00:00',
`flash_stock` = 150,
`keywords` = '土豆,马铃薯,洋芋,淀粉主食,炒丝,炖煮,炸薯条,阴凉避光',
`origin` = '甘肃定西,内蒙古乌兰察布,黑龙江克山',
`detail` = '土豆：根茎类主食蔬菜，外皮淡黄，肉质淡黄。适合炒土豆丝、炖牛肉、炸薯条、土豆泥。发芽或变绿的土豆不可食用。'
WHERE `id` = 36;

-- 37. 莴笋
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-07-16 19:00:00',
`flash_end_time` = '2026-07-16 22:00:00',
`flash_stock` = 70,
`keywords` = '莴笋,茎用莴苣,青笋,脆嫩,清炒,凉拌,冷藏保存',
`origin` = '四川彭州,山东寿光,云南通海',
`detail` = '莴笋：茎用莴苣，茎秆青绿挺拔，肉质脆嫩。适合清炒莴笋片、凉拌莴笋丝、莴笋炒肉。叶子也可食用，营养价值高。'
WHERE `id` = 37;

-- 38. 洋葱
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-07-17 09:00:00',
`flash_end_time` = '2026-07-17 12:00:00',
`flash_stock` = 100,
`keywords` = '洋葱,葱头,圆葱,爆香,凉拌,炒菜,阴凉保存',
`origin` = '甘肃酒泉,山东金乡,云南元谋',
`detail` = '洋葱：球形鳞茎，外皮紫红或黄白，肉质脆嫩辛辣。适合炒菜爆香、凉拌洋葱、洋葱圈、罗宋汤。切洋葱可放冰箱冷藏后切，减少流泪。'
WHERE `id` = 38;

-- 39. 樱桃萝卜
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-07-17 19:00:00',
`flash_end_time` = '2026-07-17 22:00:00',
`flash_stock` = 50,
`keywords` = '樱桃萝卜,小萝卜,迷你萝卜,脆甜,凉拌,沙拉,冷藏保存',
`origin` = '山东寿光,河北固安,四川彭州',
`detail` = '樱桃萝卜：小型萝卜品种，形似樱桃，外皮红艳，肉质雪白，脆甜微辣。适合凉拌、沙拉、蘸酱生食、摆盘装饰。'
WHERE `id` = 39;

-- 40. 芋艿
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-18 09:00:00',
`flash_end_time` = '2026-07-18 12:00:00',
`flash_stock` = 60,
`keywords` = '芋艿,小芋头,毛芋,软糯,蒸食,炖汤,葱油芋艿,阴凉保存',
`origin` = '浙江奉化,江西铅山,广西荔浦',
`detail` = '芋艿：小型芋头，外皮毛状，肉质软糯滑粘。适合蒸食蘸糖、葱油芋艿、芋艿排骨汤、烧芋艿。'
WHERE `id` = 40;

-- 41. 芋头
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-18 19:00:00',
`flash_end_time` = '2026-07-18 22:00:00',
`flash_stock` = 50,
`keywords` = '芋头,荔浦芋头,槟榔芋,粉糯,蒸肉,甜品,阴凉保存',
`origin` = '广西荔浦,湖南江永,福建福鼎',
`detail` = '芋头：大型芋头品种，肉质粉糯，香气浓郁。适合芋头扣肉、香芋蒸排骨、芋泥甜品、香芋奶茶。'
WHERE `id` = 41;

-- 42. 竹笋
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-07-19 09:00:00',
`flash_end_time` = '2026-07-19 12:00:00',
`flash_stock` = 35,
`keywords` = '竹笋,春笋,冬笋,脆嫩,焯水,炒肉,腌笃鲜,冷藏保存',
`origin` = '浙江安吉,福建建瓯,江西井冈山',
`detail` = '竹笋：竹子的嫩芽，外有笋壳，肉质洁白脆嫩。适合油焖笋、笋烧肉、腌笃鲜、凉拌笋丝。烹饪前务必焯水去除草酸和涩味。'
WHERE `id` = 42;

-- 43. 子姜
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-19 19:00:00',
`flash_end_time` = '2026-07-19 22:00:00',
`flash_stock` = 40,
`keywords` = '子姜,嫩姜,仔姜,脆嫩,微辣,泡姜,炒牛肉,冷藏保存',
`origin` = '四川威远,湖南永州,山东莱芜',
`detail` = '子姜：生姜的嫩芽，外皮淡黄带粉尖，肉质脆嫩，辣味较轻。适合子姜炒牛肉、泡子姜、糖醋子姜。'
WHERE `id` = 43;

-- 44. 紫薯
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-20 09:00:00',
`flash_end_time` = '2026-07-20 12:00:00',
`flash_stock` = 60,
`keywords` = '紫薯,紫色甘薯,花青素,甜糯,蒸食,烘焙,甜点,阴凉保存',
`origin` = '广东恩平,海南澄迈,福建连城',
`detail` = '紫薯：薯肉紫色，富含花青素，口感甜糯。适合蒸食、紫薯粥、紫薯泥、紫薯面包、紫薯芋圆。'
WHERE `id` = 44;

-- 45. 八角丝瓜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-20 19:00:00',
`flash_end_time` = '2026-07-20 22:00:00',
`flash_stock` = 60,
`keywords` = '八角丝瓜,有棱丝瓜,广东丝瓜,脆甜,清炒,煮汤,冷藏保存',
`origin` = '广东广州,广西南宁,海南海口',
`detail` = '八角丝瓜：丝瓜的棱角品种，瓜身有8条棱，皮薄肉厚。适合蒜蓉炒丝瓜、丝瓜蛋汤、丝瓜炒虾仁。'
WHERE `id` = 45;

-- 46. 贝贝南瓜
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-21 09:00:00',
`flash_end_time` = '2026-07-21 12:00:00',
`flash_stock` = 50,
`unit` = '个',
`keywords` = '贝贝南瓜,迷你南瓜,板栗味南瓜,粉糯,蒸食,宝宝辅食,阴凉保存',
`origin` = '山东潍坊,河北承德,内蒙古赤峰',
`detail` = '贝贝南瓜：小型南瓜品种，单果重约300-500克，肉质粉糯香甜，带板栗香气。适合蒸食、南瓜粥、宝宝辅食、南瓜甜品。'
WHERE `id` = 46;

-- 47. 冬瓜
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 4.80,
`flash_price` = 1.80,
`flash_start_time` = '2026-07-21 19:00:00',
`flash_end_time` = '2026-07-21 22:00:00',
`flash_stock` = 100,
`keywords` = '冬瓜,夏季蔬菜,利尿,煲汤,红烧,清热解暑,冷藏保存',
`origin` = '河南扶沟,湖南益阳,广西扶绥',
`detail` = '冬瓜：大型瓜类蔬菜，外皮青绿带白霜，肉质雪白水分多。适合冬瓜排骨汤、红烧冬瓜、冬瓜盅、冬瓜茶。切开后冷藏并尽快食用。'
WHERE `id` = 47;

-- 48. 佛手瓜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-22 09:00:00',
`flash_end_time` = '2026-07-22 12:00:00',
`flash_stock` = 50,
`keywords` = '佛手瓜,合掌瓜,龙须菜,清脆,清炒,凉拌,煮汤,冷藏保存',
`origin` = '云南保山,福建龙岩,四川雅安',
`detail` = '佛手瓜：瓜形如双掌合十，外皮青绿，肉质脆嫩。适合清炒佛手瓜、凉拌佛手瓜、佛手瓜排骨汤。嫩芽龙须菜亦可食用。'
WHERE `id` = 48;

-- 49. 黄瓜
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-07-22 19:00:00',
`flash_end_time` = '2026-07-22 22:00:00',
`flash_stock` = 100,
`keywords` = '黄瓜,青瓜,凉拌,美容,清脆,拍黄瓜,冷藏保存',
`origin` = '山东寿光,河南周口,河北永年',
`detail` = '黄瓜：果实长圆柱形，外皮青绿带刺，肉质脆嫩多汁。适合拍黄瓜、凉拌黄瓜、炒鸡蛋、敷脸美容。冷藏后口感更脆。'
WHERE `id` = 49;

-- 50. 苦瓜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-23 09:00:00',
`flash_end_time` = '2026-07-23 12:00:00',
`flash_stock` = 60,
`keywords` = '苦瓜,凉瓜,清热,降火,苦味,炒蛋,煲汤,冷藏保存',
`origin` = '广西南宁,广东江门,福建漳州',
`detail` = '苦瓜：果实纺锤形，外皮青绿带瘤状突起，味苦性凉。适合苦瓜炒蛋、苦瓜酿肉、苦瓜排骨汤。焯水可减轻苦味。'
WHERE `id` = 50;

-- 51. 南瓜
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-07-23 19:00:00',
`flash_end_time` = '2026-07-23 22:00:00',
`flash_stock` = 80,
`keywords` = '南瓜,金瓜,老南瓜,甜糯,煮粥,南瓜饼,阴凉保存',
`origin` = '湖南岳阳,山西长治,甘肃金昌',
`detail` = '南瓜：大型瓜类，外皮金黄或墨绿，肉质橙黄软糯。适合南瓜粥、南瓜饼、蒸南瓜、南瓜汤。'
WHERE `id` = 51;

-- 52. 嫩南瓜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-07-24 09:00:00',
`flash_end_time` = '2026-07-24 12:00:00',
`flash_stock` = 60,
`keywords` = '嫩南瓜,青南瓜,清脆,清炒,鲜嫩,冷藏保存',
`origin` = '山东寿光,河南周口,四川成都',
`detail` = '嫩南瓜：未完全成熟的南瓜，外皮青绿，肉质脆嫩。适合清炒嫩南瓜、嫩南瓜炒肉丝、嫩南瓜饼。'
WHERE `id` = 52;

-- 53. 丝瓜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-24 19:00:00',
`flash_end_time` = '2026-07-24 22:00:00',
`flash_stock` = 60,
`keywords` = '丝瓜,水瓜,清热,滑嫩,煮汤,蒜蓉炒,冷藏保存',
`origin` = '广西南宁,湖南湘潭,广东广州',
`detail` = '丝瓜：果实长圆柱形，外皮青绿，肉质滑嫩多汁。适合丝瓜蛋汤、蒜蓉炒丝瓜、丝瓜炒油条。'
WHERE `id` = 53;

-- 54. 小黄瓜
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-25 09:00:00',
`flash_end_time` = '2026-07-25 12:00:00',
`flash_stock` = 50,
`keywords` = '小黄瓜,迷你黄瓜,水果黄瓜,清脆,生吃,沙拉,冷藏保存',
`origin` = '山东寿光,海南三亚,云南元谋',
`detail` = '小黄瓜：小型黄瓜品种，表皮光滑无刺，肉质脆嫩清甜。适合生吃、蘸酱、沙拉、便当配菜。'
WHERE `id` = 54;

-- 55. 花椰菜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-25 19:00:00',
`flash_end_time` = '2026-07-25 22:00:00',
`flash_stock` = 60,
`keywords` = '花椰菜,菜花,花菜,爽脆,干锅,炒制,焯水,冷藏保存',
`origin` = '河北邯郸,江苏徐州,云南通海',
`detail` = '花椰菜：花球白色紧实，质地脆嫩。适合干锅花菜、番茄炒花菜、凉拌花椰菜。烹饪前焯水可去除草酸。'
WHERE `id` = 55;

-- 56. 黄花菜
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 22.80,
`flash_price` = 12.50,
`flash_start_time` = '2026-07-26 09:00:00',
`flash_end_time` = '2026-07-26 12:00:00',
`flash_stock` = 30,
`keywords` = '黄花菜,金针菜,萱草,炒制,煲汤,需煮熟,干制保存',
`origin` = '湖南祁东,陕西大荔,四川渠县',
`detail` = '黄花菜：花蕾金黄色，口感滑嫩，干品常用。适合炒肉、煲汤、凉拌。新鲜黄花菜含秋水仙碱，必须充分煮熟后方可食用。'
WHERE `id` = 56;

-- 57. 西兰花
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-07-26 19:00:00',
`flash_end_time` = '2026-07-26 22:00:00',
`flash_stock` = 60,
`keywords` = '西兰花,青花菜,绿花菜,抗癌,脆嫩,焯水,清炒,沙拉,冷藏保存',
`origin` = '云南通海,河北邯郸,江苏徐州',
`detail` = '西兰花：花球深绿色紧实，茎脆嫩，营养丰富。适合蒜蓉西兰花、西兰花炒虾仁、凉拌西兰花。焯水时加盐和油可保持翠绿。'
WHERE `id` = 57;

-- 58. 茨菇
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-07-27 09:00:00',
`flash_end_time` = '2026-07-27 12:00:00',
`flash_stock` = 40,
`keywords` = '茨菇,慈姑,水生蔬菜,粉糯,烧肉,炖煮,冷藏保存',
`origin` = '江苏苏州,广东肇庆,云南大理',
`detail` = '茨菇：水生球茎，形似蒜头，肉质粉糯，带独特香气。适合茨菇烧肉、茨菇排骨汤。'
WHERE `id` = 58;

-- 59. 凤尾菇
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-27 19:00:00',
`flash_end_time` = '2026-07-27 22:00:00',
`flash_stock` = 40,
`keywords` = '凤尾菇,平菇,蚝菇,鲜嫩,清炒,煮汤,火锅,冷藏保存',
`origin` = '福建古田,河北平泉,山东聊城',
`detail` = '凤尾菇：菌盖扇形灰褐色，形似凤尾，肉质鲜嫩。适合清炒凤尾菇、凤尾菇蛋汤、涮火锅。'
WHERE `id` = 59;

-- 60. 海鲜菇
UPDATE `goods` SET 
`price` = 11.80,
`original_price` = 15.80,
`flash_price` = 8.90,
`flash_start_time` = '2026-07-28 09:00:00',
`flash_end_time` = '2026-07-28 12:00:00',
`flash_stock` = 35,
`keywords` = '海鲜菇,蟹味菇,鲜味,清炒,煮汤,火锅,冷藏保存',
`origin` = '上海崇明,山东青岛,湖北随州',
`detail` = '海鲜菇：菌柄细长，菌盖小，白色或灰褐色，口感脆嫩，有海鲜鲜味。适合清炒、煮汤、涮火锅、凉拌。'
WHERE `id` = 60;

-- 61. 花菇
UPDATE `goods` SET 
`price` = 22.80,
`original_price` = 32.80,
`flash_price` = 18.80,
`flash_start_time` = '2026-07-28 19:00:00',
`flash_end_time` = '2026-07-28 22:00:00',
`flash_stock` = 20,
`keywords` = '花菇,香菇,冬菇,香浓,炖汤,红烧,干货泡发,干制保存',
`origin` = '浙江庆元,河南西峡,湖北随州',
`detail` = '花菇：香菇上品，菌盖裂纹开如花，肉质肥厚，香气浓郁。适合红烧花菇、花菇鸡汤、花菇焖鸡。干品需提前泡发。'
WHERE `id` = 61;

-- 62. 金针菇
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-07-29 09:00:00',
`flash_end_time` = '2026-07-29 12:00:00',
`flash_stock` = 60,
`keywords` = '金针菇,金菇,火锅,烧烤,脆嫩,塞牙,冷藏保存',
`origin` = '河北灵寿,江苏连云港,四川金堂',
`detail` = '金针菇：菌柄细长，菌盖小，白色或淡黄色，口感脆嫩，易塞牙。适合涮火锅、烧烤、金针菇培根卷、凉拌。'
WHERE `id` = 62;

-- 63. 木耳
UPDATE `goods` SET 
`price` = 48.80,
`original_price` = 68.80,
`flash_price` = 39.80,
`flash_start_time` = '2026-07-29 19:00:00',
`flash_end_time` = '2026-07-29 22:00:00',
`flash_stock` = 15,
`unit` = '斤',
`keywords` = '木耳,黑木耳,胶质,清肺,凉拌,炒菜,火锅,干制保存',
`origin` = '黑龙江尚志,吉林蛟河,湖北房县',
`detail` = '木耳：干制品，泡发后呈黑褐色胶质状，口感脆爽。适合凉拌木耳、木耳炒鸡蛋、木耳炒肉、涮火锅。'
WHERE `id` = 63;

-- 64. 平菇
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-07-30 09:00:00',
`flash_end_time` = '2026-07-30 12:00:00',
`flash_stock` = 45,
`keywords` = '平菇,蚝菇,鲜嫩,清炒,煮汤,火锅,冷藏保存',
`origin` = '河南夏邑,山东聊城,河北平泉',
`detail` = '平菇：菌盖扇形灰白或灰褐色，肉质鲜嫩。适合清炒平菇、平菇蛋汤、椒盐平菇、涮火锅。'
WHERE `id` = 64;

-- 65. 香菇
UPDATE `goods` SET 
`price` = 13.80,
`original_price` = 18.80,
`flash_price` = 10.50,
`flash_start_time` = '2026-07-30 19:00:00',
`flash_end_time` = '2026-07-30 22:00:00',
`flash_stock` = 35,
`keywords` = '香菇,冬菇,香信,菌香,红烧,炖汤,素食,冷藏保存',
`origin` = '浙江庆元,河南西峡,福建古田',
`detail` = '香菇：菌盖灰褐色圆润，菌肉肥厚，香气浓郁。适合红烧香菇、香菇鸡汤、香菇油菜、素食餐。'
WHERE `id` = 65;

-- 66. 杏鲍菇
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-07-31 09:00:00',
`flash_end_time` = '2026-07-31 12:00:00',
`flash_stock` = 40,
`keywords` = '杏鲍菇,鸡腿菇,肉感,口感像鲍鱼,手撕,香煎,冷藏保存',
`origin` = '福建漳州,上海崇明,河南夏邑',
`detail` = '杏鲍菇：菌柄粗壮，菌盖小，肉质肥厚，口感像鲍鱼有嚼劲。适合手撕杏鲍菇、香煎杏鲍菇、杏鲍菇炒肉片。'
WHERE `id` = 66;

-- 67. 蒜苗
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-07-31 19:00:00',
`flash_end_time` = '2026-07-31 22:00:00',
`flash_stock` = 50,
`keywords` = '蒜苗,青蒜,大蒜苗,香辛,炒回锅肉,调味,冷藏保存',
`origin` = '山东苍山,河南杞县,四川温江',
`detail` = '蒜苗：大蒜的嫩苗，叶扁平青绿，有蒜香但比大蒜清淡。适合回锅肉、蒜苗炒肉、蒜苗炒鸡蛋。'
WHERE `id` = 67;

-- 68. 香葱
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-08-01 09:00:00',
`flash_end_time` = '2026-08-01 12:00:00',
`flash_stock` = 50,
`keywords` = '香葱,小葱,调味,撒葱,提香,葱花,冷藏保存',
`origin` = '湖南岳阳,山东寿光,云南建水',
`detail` = '香葱：小型葱，叶细管状翠绿，香味浓而不辣。适合撒葱花提香、葱油拌面、葱爆肉、煲汤最后撒葱。'
WHERE `id` = 68;

-- 69. 香茅
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-08-01 19:00:00',
`flash_end_time` = '2026-08-01 22:00:00',
`flash_stock` = 30,
`keywords` = '香茅,柠檬草,东南亚菜,香茅茶,去腥,调味,冷冻保存',
`origin` = '海南琼海,云南西双版纳,广东湛江',
`detail` = '香茅：茎秆灰绿色，有浓郁柠檬香气。适合冬阴功汤、香茅烤鸡、香茅茶、去腥调味。'
WHERE `id` = 69;

-- 70. 彩椒
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-08-02 09:00:00',
`flash_end_time` = '2026-08-02 12:00:00',
`flash_stock` = 45,
`keywords` = '彩椒,甜椒,红黄椒,VC之王,沙拉,配菜,冷藏保存',
`origin` = '山东寿光,河北乐亭,内蒙古宁城',
`detail` = '彩椒：红、黄、橙等颜色的甜椒，肉厚脆甜，无辣味。适合沙拉、配菜、彩椒炒肉、彩椒盅。'
WHERE `id` = 70;

-- 71. 灯笼彩椒
UPDATE `goods` SET 
`price` = 10.80,
`original_price` = 14.80,
`flash_price` = 8.50,
`flash_start_time` = '2026-08-02 19:00:00',
`flash_end_time` = '2026-08-02 22:00:00',
`flash_stock` = 40,
`keywords` = '灯笼彩椒,甜椒,彩色甜椒,肉厚,脆甜,沙拉,冷藏保存',
`origin` = '山东寿光,河北乐亭,辽宁朝阳',
`detail` = '灯笼彩椒：灯笼形甜椒，肉厚形美，色泽鲜艳。适合沙拉、酿肉、烤甜椒、配菜装饰。'
WHERE `id` = 71;

-- 72. 湖南椒
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-08-03 09:00:00',
`flash_end_time` = '2026-08-03 12:00:00',
`flash_stock` = 50,
`keywords` = '湖南椒,青尖椒,辣椒,辣味足,小炒肉,剁椒,冷藏保存',
`origin` = '湖南长沙,江西萍乡,贵州遵义',
`detail` = '湖南椒：细长形青椒，辣度较高，香气浓。适合小炒肉、辣椒炒蛋、剁椒鱼头、炒腊肉。'
WHERE `id` = 72;

-- 73. 螺丝椒
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-08-03 19:00:00',
`flash_end_time` = '2026-08-03 22:00:00',
`flash_stock` = 45,
`keywords` = '螺丝椒,螺旋椒,皱皮椒,辣味浓,炒肉,虎皮青椒,冷藏保存',
`origin` = '湖南岳阳,江西赣州,四川成都',
`detail` = '螺丝椒：青椒品种，果形扭曲如螺丝，皮薄肉脆，辣味浓。适合虎皮青椒、青椒炒肉、辣椒炒蛋。'
WHERE `id` = 73;

-- 74. 茄子
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-04 09:00:00',
`flash_end_time` = '2026-08-04 12:00:00',
`flash_stock` = 80,
`keywords` = '茄子,紫茄子,落苏,红烧,油焖,鱼香,冷藏保存',
`origin` = '山东寿光,河南周口,四川彭州',
`detail` = '茄子：长条形紫皮，肉质海绵状，易吸油。适合红烧茄子、油焖茄子、鱼香茄子、蒜泥茄子、地三鲜。'
WHERE `id` = 74;

-- 75. 青辣椒
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-04 19:00:00',
`flash_end_time` = '2026-08-04 22:00:00',
`flash_stock` = 70,
`keywords` = '青辣椒,青椒,菜椒,辣味轻,虎皮青椒,炒肉,冷藏保存',
`origin` = '山东寿光,河北乐亭,内蒙古宁城',
`detail` = '青辣椒：常见菜椒，果形较大，皮厚肉脆，辣味较轻或基本不辣。适合虎皮青椒、青椒炒肉、青椒土豆丝。'
WHERE `id` = 75;

-- 76. 秋葵
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-08-05 09:00:00',
`flash_end_time` = '2026-08-05 12:00:00',
`flash_stock` = 40,
`keywords` = '秋葵,羊角豆,绿色人参,滑腻,凉拌,蘸酱,冷藏保存',
`origin` = '湖南常德,山东寿光,福建漳州',
`detail` = '秋葵：果形羊角形五棱，外皮翠绿带细毛，切开有粘液。适合凉拌秋葵、白灼秋葵蘸酱、秋葵炒蛋、秋葵汤。'
WHERE `id` = 76;

-- 77. 西红柿
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-05 19:00:00',
`flash_end_time` = '2026-08-05 22:00:00',
`flash_stock` = 100,
`keywords` = '西红柿,番茄,番茄炒蛋,酸甜,维C,生吃,熟食,冷藏保存',
`origin` = '山东寿光,河南新乡,新疆昌吉',
`detail` = '西红柿：果形圆润，果皮鲜红，肉质软嫩多汁，酸甜可口。适合番茄炒蛋、番茄蛋汤、凉拌番茄、番茄牛腩。'
WHERE `id` = 77;

-- 78. 小米椒
UPDATE `goods` SET 
`price` = 15.80,
`original_price` = 22.80,
`flash_price` = 12.50,
`flash_start_time` = '2026-08-06 09:00:00',
`flash_end_time` = '2026-08-06 12:00:00',
`flash_stock` = 30,
`keywords` = '小米椒,朝天椒,野山椒,特辣,调味,剁椒,冷冻保存',
`origin` = '云南文山,贵州遵义,海南文昌',
`detail` = '小米椒：细小锥形辣椒，鲜红色，辣度很高。适合剁椒、泡椒、调味增辣、蘸水。建议戴手套处理。'
WHERE `id` = 78;

-- 79. 玉米
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-06 19:00:00',
`flash_end_time` = '2026-08-06 22:00:00',
`flash_stock` = 80,
`unit` = '个',
`keywords` = '玉米,甜玉米,水果玉米,甜糯,煮食,煲汤,冷藏保存',
`origin` = '广西横县,云南西双版纳,黑龙江绥化',
`detail` = '玉米：甜玉米品种，颗粒饱满金黄，甜度高，多汁。适合煮玉米、玉米排骨汤、玉米粒炒菜、玉米沙拉。'
WHERE `id` = 79;

-- 80. 圆椒
UPDATE `goods` SET 
`price` = 7.80,
`original_price` = 10.80,
`flash_price` = 5.90,
`flash_start_time` = '2026-08-07 09:00:00',
`flash_end_time` = '2026-08-07 12:00:00',
`flash_stock` = 50,
`keywords` = '圆椒,青圆椒,灯笼椒,不辣,肉厚,配菜,冷藏保存',
`origin` = '山东寿光,河北乐亭,辽宁朝阳',
`detail` = '圆椒：球形青椒，肉厚壁硬，不辣。适合炒肉、酿肉、沙拉、披萨配料。'
WHERE `id` = 80;

-- =====================================================
-- 八、叶菜类商品修正（81-106）
-- =====================================================

-- 81. 包菜
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 4.80,
`flash_price` = 1.80,
`flash_start_time` = '2026-08-07 19:00:00',
`flash_end_time` = '2026-08-07 22:00:00',
`flash_stock` = 120,
`keywords` = '包菜,卷心菜,圆白菜,手撕包菜,脆甜,冷藏保存',
`origin` = '山东寿光,河北张家口,云南通海',
`detail` = '包菜：叶球圆球形，叶片绿白脆嫩。适合手撕包菜、炒包菜丝、包菜炒粉丝、包菜沙拉。'
WHERE `id` = 81;

-- 82. 菠菜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-08 09:00:00',
`flash_end_time` = '2026-08-08 12:00:00',
`flash_stock` = 80,
`keywords` = '菠菜,赤根菜,补铁,焯水,清炒,凉拌,冷藏保存',
`origin` = '山东寿光,河北沽源,云南昆明',
`detail` = '菠菜：叶色深绿，根部带红，富含铁质。适合清炒菠菜、菠菜蛋汤、凉拌菠菜、蒜蓉菠菜。烹饪前建议焯水去草酸。'
WHERE `id` = 82;

-- 83. 菜心
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-08 19:00:00',
`flash_end_time` = '2026-08-08 22:00:00',
`flash_stock` = 70,
`keywords` = '菜心,油菜心,广东菜心,脆嫩,白灼,蒜蓉炒,冷藏保存',
`origin` = '广东增城,云南通海,福建漳州',
`detail` = '菜心：花茎类蔬菜，茎青绿，花蕾黄色，脆嫩清甜。适合白灼菜心、蒜蓉炒菜心、蚝油菜心。'
WHERE `id` = 83;

-- 84. 大白菜
UPDATE `goods` SET 
`price` = 2.80,
`original_price` = 4.80,
`flash_price` = 1.80,
`flash_start_time` = '2026-08-09 09:00:00',
`flash_end_time` = '2026-08-09 12:00:00',
`flash_stock` = 150,
`keywords` = '大白菜,黄芽菜,白菜,炖菜,酸菜,韩国泡菜,冷藏保存',
`origin` = '山东青岛,河北玉田,辽宁沈阳',
`detail` = '大白菜：叶球长筒形，叶片黄白脆嫩。适合炖粉条、做酸菜、辣白菜、白菜炖豆腐。'
WHERE `id` = 84;

-- 85. 红菜薹
UPDATE `goods` SET 
`price` = 8.80,
`original_price` = 12.80,
`flash_price` = 6.50,
`flash_start_time` = '2026-08-09 19:00:00',
`flash_end_time` = '2026-08-09 22:00:00',
`flash_stock` = 40,
`keywords` = '红菜薹,紫菜薹,洪山菜薹,脆甜,清炒,腊肉,冷藏保存',
`origin` = '湖北武汉,湖南长沙,四川成都',
`detail` = '红菜薹：茎紫红色带白霜，花金黄，脆嫩清甜。适合清炒红菜薹、腊肉炒红菜薹。'
WHERE `id` = 85;

-- 86. 黄心白
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-08-10 09:00:00',
`flash_end_time` = '2026-08-10 12:00:00',
`flash_stock` = 100,
`keywords` = '黄心白,黄心白菜,白菜,鲜嫩,炖煮,火锅,冷藏保存',
`origin` = '山东青岛,河北玉田,辽宁沈阳',
`detail` = '黄心白：白菜的改良品种，菜心更黄，口感更嫩甜。适合炖菜、涮火锅、煮汤。'
WHERE `id` = 86;

-- 87. 茴香
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-08-10 19:00:00',
`flash_end_time` = '2026-08-10 22:00:00',
`flash_stock` = 35,
`keywords` = '茴香,小茴香,茴香苗,包饺子,独特香气,冷藏保存',
`origin` = '河北张家口,内蒙古乌兰察布,山西大同',
`detail` = '茴香：叶细羽状，有特殊香气，类似八角味。适合茴香猪肉饺子、茴香炒鸡蛋、凉拌茴香。'
WHERE `id` = 87;

-- 88. 芥蓝
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-08-11 09:00:00',
`flash_end_time` = '2026-08-11 12:00:00',
`flash_stock` = 50,
`keywords` = '芥蓝,芥兰,广东菜,脆甜,白灼,蒜蓉炒,腊肉,冷藏保存',
`origin` = '广东广州,福建漳州,云南通海',
`detail` = '芥蓝：茎粗壮青绿，叶片深绿，脆嫩清甜。适合白灼芥蓝、蒜蓉炒芥蓝、腊肉炒芥蓝。'
WHERE `id` = 88;

-- 89. 韭菜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-11 19:00:00',
`flash_end_time` = '2026-08-11 22:00:00',
`flash_stock` = 60,
`keywords` = '韭菜,壮阳草,韭香,包饺子,炒鸡蛋,冷藏保存',
`origin` = '河北保定,山东寿光,四川成都',
`detail` = '韭菜：叶扁平宽大翠绿，气味浓烈。适合韭菜猪肉饺子、韭菜炒鸡蛋、烤韭菜、韭菜盒子。'
WHERE `id` = 89;

-- 90. 韭黄
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-08-12 09:00:00',
`flash_end_time` = '2026-08-12 12:00:00',
`flash_stock` = 40,
`keywords` = '韭黄,黄韭菜,软化韭菜,柔嫩,清香,炒蛋,冷藏保存',
`origin` = '河北保定,四川成都,湖南长沙',
`detail` = '韭黄：韭菜经遮光软化栽培，叶色嫩黄，质地更柔嫩，气味更清香。适合韭黄炒蛋、韭黄肉丝。'
WHERE `id` = 90;

-- 91. 蕨菜
UPDATE `goods` SET 
`price` = 12.80,
`original_price` = 16.80,
`flash_price` = 9.90,
`flash_start_time` = '2026-08-12 19:00:00',
`flash_end_time` = '2026-08-12 22:00:00',
`flash_stock` = 30,
`keywords` = '蕨菜,蕨,山野菜,滑嫩,焯水,凉拌,炒腊肉,冷藏保存',
`origin` = '黑龙江伊春,湖南张家界,四川雅安',
`detail` = '蕨菜：蕨类嫩茎，带卷头，口感滑嫩。适合蕨菜炒腊肉、凉拌蕨菜、蕨菜汤。含有原蕨苷，建议适量食用，烹饪前焯水。'
WHERE `id` = 91;

-- 92. 空心菜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-13 09:00:00',
`flash_end_time` = '2026-08-13 12:00:00',
`flash_stock` = 80,
`keywords` = '空心菜,通菜,蕹菜,清脆,腐乳炒,蒜蓉炒,冷藏保存',
`origin` = '广东广州,广西南宁,海南海口',
`detail` = '空心菜：茎中空，叶翠绿，口感脆嫩。适合腐乳空心菜、蒜蓉空心菜、清炒空心菜。'
WHERE `id` = 92;

-- 93. 苦麦菜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-13 19:00:00',
`flash_end_time` = '2026-08-13 22:00:00',
`flash_stock` = 50,
`keywords` = '苦麦菜,苦菜,苦苣,清热,微苦,清炒,煮汤,冷藏保存',
`origin` = '广西南宁,广东广州,福建福州',
`detail` = '苦麦菜：叶绿色长形，口感微苦，清热败火。适合清炒、煮汤、凉拌。'
WHERE `id` = 93;

-- 94. 木耳菜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-14 09:00:00',
`flash_end_time` = '2026-08-14 12:00:00',
`flash_stock` = 50,
`keywords` = '木耳菜,落葵,滑菜,滑腻,清炒,煮汤,营养价值高,冷藏保存',
`origin` = '广东广州,广西南宁,福建福州',
`detail` = '木耳菜：叶肉质肥厚，口感滑腻，类似木耳。适合清炒木耳菜、木耳菜蛋汤。'
WHERE `id` = 94;

-- 95. 芹菜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-14 19:00:00',
`flash_end_time` = '2026-08-14 22:00:00',
`flash_stock` = 70,
`keywords` = '芹菜,西芹,脆爽,降压,炒肉,凉拌,香干,冷藏保存',
`origin` = '山东寿光,河北邯郸,云南通海',
`detail` = '芹菜：茎翠绿脆嫩，香气浓。适合芹菜炒香干、芹菜炒肉、凉拌芹菜、芹菜汁。'
WHERE `id` = 95;

-- 96. 上海青
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-08-15 09:00:00',
`flash_end_time` = '2026-08-15 12:00:00',
`flash_stock` = 100,
`keywords` = '上海青,小油菜,青菜,鲜嫩,清炒,白灼,冷藏保存',
`origin` = '上海崇明,江苏南京,云南通海',
`detail` = '上海青：叶片青绿，叶柄肥厚洁白，形似汤匙。适合清炒上海青、白灼上海青、香菇油菜。'
WHERE `id` = 96;

-- 97. 生菜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-15 19:00:00',
`flash_end_time` = '2026-08-15 22:00:00',
`flash_stock` = 80,
`keywords` = '生菜,叶用莴苣,蚝油生菜,脆嫩,生食,沙拉,冷藏保存',
`origin` = '山东寿光,河北张家口,云南通海',
`detail` = '生菜：叶脆嫩多汁，清爽。适合蚝油生菜、蒜蓉生菜、烤肉包生菜、蔬菜沙拉。'
WHERE `id` = 97;

-- 98. 塔菜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-16 09:00:00',
`flash_end_time` = '2026-08-16 12:00:00',
`flash_stock` = 45,
`keywords` = '塔菜,乌塌菜,菊花菜,冬季蔬菜,清炒,鲜嫩,冷藏保存',
`origin` = '江苏南京,上海崇明,安徽合肥',
`detail` = '塔菜：叶色墨绿，叶片多层重叠如塔，口感脆嫩。适合清炒塔菜、蒜蓉塔菜。'
WHERE `id` = 98;

-- 99. 茼蒿
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-08-16 19:00:00',
`flash_end_time` = '2026-08-16 22:00:00',
`flash_stock` = 50,
`keywords` = '茼蒿,皇帝菜,蓬蒿,涮火锅,清炒,凉拌,冷藏保存',
`origin` = '山东寿光,河北沽源,云南通海',
`detail` = '茼蒿：叶羽状深裂，有特殊清香。适合涮火锅、清炒茼蒿、凉拌茼蒿。'
WHERE `id` = 99;

-- 100. 娃娃菜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-17 09:00:00',
`flash_end_time` = '2026-08-17 12:00:00',
`flash_stock` = 80,
`unit` = '棵',
`keywords` = '娃娃菜,微型白菜,鲜嫩,蒜蓉粉丝,上汤,冷藏保存',
`origin` = '云南通海,山东寿光,甘肃兰州',
`detail` = '娃娃菜：大白菜的微型品种，叶片嫩黄，口感甜嫩。适合上汤娃娃菜、蒜蓉粉丝娃娃菜、涮火锅。'
WHERE `id` = 100;

-- 101. 西洋菜
UPDATE `goods` SET 
`price` = 6.80,
`original_price` = 9.80,
`flash_price` = 4.90,
`flash_start_time` = '2026-08-17 19:00:00',
`flash_end_time` = '2026-08-17 22:00:00',
`flash_stock` = 45,
`keywords` = '西洋菜,豆瓣菜,水菜,煲汤,清炒,清热,冷藏保存',
`origin` = '广东广州,广西南宁,海南海口',
`detail` = '西洋菜：水生蔬菜，茎叶翠绿，口感脆嫩。适合西洋菜猪骨汤、清炒西洋菜。'
WHERE `id` = 101;

-- 102. 苋菜
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-18 09:00:00',
`flash_end_time` = '2026-08-18 12:00:00',
`flash_stock` = 60,
`keywords` = '苋菜,红苋菜,汗菜,蒜蓉炒,上汤,夏季蔬菜,冷藏保存',
`origin` = '广东广州,江苏南京,湖南长沙',
`detail` = '苋菜：叶绿色或紫红，软嫩。适合蒜蓉炒苋菜、上汤苋菜、凉拌苋菜。'
WHERE `id` = 102;

-- 103. 香菜
UPDATE `goods` SET 
`price` = 9.80,
`original_price` = 13.80,
`flash_price` = 7.50,
`flash_start_time` = '2026-08-18 19:00:00',
`flash_end_time` = '2026-08-18 22:00:00',
`flash_stock` = 40,
`keywords` = '香菜,芫荽,调味,提香,撒香菜,凉拌,冷藏保存',
`origin` = '山东寿光,河北邯郸,云南通海',
`detail` = '香菜：叶羽状翠绿，香气浓，有人爱有人恨。适合撒香菜提香、凉拌、煮汤最后放。'
WHERE `id` = 103;

-- 104. 小白菜
UPDATE `goods` SET 
`price` = 3.80,
`original_price` = 5.80,
`flash_price` = 2.50,
`flash_start_time` = '2026-08-19 09:00:00',
`flash_end_time` = '2026-08-19 12:00:00',
`flash_stock` = 100,
`keywords` = '小白菜,青菜,鲜嫩,清炒,便当配菜,冷藏保存',
`origin` = '山东寿光,江苏南京,云南通海',
`detail` = '小白菜：叶青绿，叶柄雪白，脆嫩清甜。适合清炒小白菜、蒜蓉小白菜、便当配菜。'
WHERE `id` = 104;

-- 105. 油麦菜
UPDATE `goods` SET 
`price` = 4.80,
`original_price` = 6.80,
`flash_price` = 3.50,
`flash_start_time` = '2026-08-19 19:00:00',
`flash_end_time` = '2026-08-19 22:00:00',
`flash_stock` = 80,
`keywords` = '油麦菜,莴笋叶,清脆,豆豉鲮鱼,清炒,凉拌,冷藏保存',
`origin` = '山东寿光,云南通海,河北沽源',
`detail` = '油麦菜：叶长形翠绿，脆嫩爽口。适合豆豉鲮鱼油麦菜、清炒油麦菜、凉拌油麦菜。'
WHERE `id` = 105;

-- 106. 紫甘蓝
UPDATE `goods` SET 
`price` = 5.80,
`original_price` = 8.80,
`flash_price` = 3.90,
`flash_start_time` = '2026-08-20 09:00:00',
`flash_end_time` = '2026-08-20 12:00:00',
`flash_stock` = 60,
`keywords` = '紫甘蓝,红甘蓝,紫色包菜,沙拉,凉拌,花青素,冷藏保存',
`origin` = '山东寿光,河北张家口,云南通海',
`detail` = '紫甘蓝：叶球紫红色，脆嫩，富含花青素。适合沙拉、凉拌、榨汁。'
WHERE `id` = 106;

COMMIT;

SET FOREIGN_KEY_CHECKS = 1;