-- 方案规则补充：查漏补缺高频误入项

UPDATE `plan_rule_config`
SET `rule_value` = '鲜切即食,果切杯,即食水果杯,草莓,蓝莓,桑葚,圣女果,香蕉,牛油果,杨桃,树莓,黑莓,青柠,柠檬,橙子,樱桃,葡萄,梨,香梨,皇冠梨,秋月梨,柚子,西瓜,哈密瓜,香瓜,菠萝,枇杷'
WHERE `rule_key` = 'plan.hotpot_blacklist_keywords';

UPDATE `plan_rule_config`
SET `rule_value` = '蒜,洋葱,大葱,香葱,韭菜,辣椒,苦瓜,芹菜,香菜,茴香,子姜,南姜,蒜苔,茼蒿,娃娃菜,黄心白,平菇,海鲜菇,凤尾菇,金针菇,木耳,花椰菜,西兰花,香茅'
WHERE `rule_key` = 'plan.juice_blacklist_keywords';

UPDATE `plan_rule_config`
SET `rule_value` = '榴莲,菠萝蜜,蒜苗,大葱,洋葱,土豆,红薯,山药,芋头,南瓜,四季豆,长豆角,荷兰豆,茄子,冬瓜,大蒜,生姜,南姜,玉米,莲藕,紫薯,芋艿,独头蒜,子姜,香葱,蒜苔,香茅,平菇,海鲜菇,凤尾菇,金针菇,木耳,茼蒿,黄心白,娃娃菜'
WHERE `rule_key` = 'plan.salad_blacklist_keywords';

UPDATE `plan_rule_config`
SET `rule_value` = '西瓜,哈密瓜,香瓜,椰青,柚子,橙子,莲雾,梨,皇冠梨,香梨,秋月梨,葡萄,巨峰葡萄,夏黑葡萄,杨桃,草莓,黄瓜,青柠,柠檬,枇杷'
WHERE `rule_key` = 'plan.watery_fruit_keywords';
