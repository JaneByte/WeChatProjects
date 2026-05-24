package com.example.freshtime.service.impl.support;

import org.springframework.stereotype.Component;

@Component
public class AdminConfigHelper {

    public String resolvePackPricingDescription(String ruleKey) {
        if (ruleKey == null || ruleKey.isEmpty()) {
            return "套餐优惠配置";
        }
        if (ruleKey.startsWith("pack.combo.")) {
            if (ruleKey.endsWith("discount_rate")) return "蔬果搭配基础折扣率";
            if (ruleKey.endsWith("min_discount")) return "蔬果搭配最低优惠额";
            if (ruleKey.endsWith("max_discount")) return "蔬果搭配最高优惠额";
        }
        if (ruleKey.startsWith("pack.meal.")) {
            if (ruleKey.endsWith("discount_rate")) return "小份优选基础折扣率";
            if (ruleKey.endsWith("min_discount")) return "小份优选最低优惠额";
            if (ruleKey.endsWith("max_discount")) return "小份优选最高优惠额";
        }
        return "套餐优惠配置";
    }
}
