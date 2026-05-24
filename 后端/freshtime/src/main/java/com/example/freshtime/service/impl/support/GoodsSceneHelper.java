package com.example.freshtime.service.impl.support;

import com.example.freshtime.entity.Goods;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;

@Component
public class GoodsSceneHelper {

    public String resolveSceneType(String scene, Goods goods) {
        if ("小份量".equals(scene)) {
            return resolvePackType(scene, goods);
        }
        if ("搭配".equals(scene)) {
            return resolveComboMode(scene, goods);
        }
        return "all";
    }

    public String resolvePackType(String scene, Goods goods) {
        if (!"小份量".equals(scene)) {
            return "single";
        }
        String text = safeText(goods.getName()) + "," + safeText(goods.getKeywords()) + "," + safeText(goods.getDetail());
        if (containsAny(text, "随机", "盲盒", "自选")) return "random";
        if (containsAny(text, "拼盘", "组合", "礼盒", "果切", "菜谱", "净菜", "免洗", "预处理", "加工")) return "platter";
        return "single";
    }

    public String resolveComboMode(String scene, Goods goods) {
        if (!"搭配".equals(scene)) {
            return "fixed";
        }
        String text = safeText(goods.getName()) + "," + safeText(goods.getKeywords()) + "," + safeText(goods.getDetail());
        if (containsAny(text, "随机", "任选", "自选", "2蔬", "两蔬", "一果", "1果")) return "random";
        return "fixed";
    }

    public String resolveCouponThresholdHint(String scene, Goods goods) {
        BigDecimal price = goods.getPrice() == null ? BigDecimal.ZERO : goods.getPrice();
        if ("搭配".equals(scene)) {
            if (price.compareTo(new BigDecimal("99")) >= 0) return "满99可用大额券";
            if (price.compareTo(new BigDecimal("50")) >= 0) return "满50可用满减券";
            return "建议凑单到满50更划算";
        }
        if ("小份量".equals(scene)) {
            if (price.compareTo(new BigDecimal("39")) >= 0) return "满足新人券门槛";
            return "建议凑单到满39更划算";
        }
        return "";
    }

    public String resolveSceneFallbackKeyword(String scene) {
        if ("小份量".equals(scene)) {
            return "小份";
        }
        if ("搭配".equals(scene)) {
            return "搭配";
        }
        if ("时令".equals(scene)) {
            return "时令";
        }
        return scene;
    }

    private boolean containsAny(String text, String... keywords) {
        for (String keyword : keywords) {
            if (text.contains(keyword)) return true;
        }
        return false;
    }

    private String safeText(String text) {
        return text == null ? "" : text;
    }
}
