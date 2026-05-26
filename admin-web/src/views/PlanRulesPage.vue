<template>
  <div class="page-grid plan-rules-page">
    <div class="section-card plan-rules-card">
      <div class="section-head plan-rules-hero">
        <div class="plan-rules-hero__copy">
          <h2 class="section-title plan-rules-hero__title">方案规则配置</h2>
          <p class="section-desc plan-rules-hero__desc">集中维护小份优选、场景搭配、榨汁、沙拉等场景下的推荐规则关键词。</p>
        </div>
        <button class="ghost-btn" @click="loadRules" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <div class="rule-section" v-for="section in ruleSections" :key="section.title">
        <div class="section-head rule-section-head">
          <div class="rule-section-head__copy">
            <h3 class="section-title rule-section-head__title">{{ section.title }}</h3>
            <p class="section-desc rule-section-head__desc">{{ section.desc }}</p>
          </div>
        </div>
        <div class="form-grid">
          <label v-for="item in section.fields" :key="item.key" class="field-block input-wide">
            <span class="field-label">{{ item.label }}</span>
            <textarea
              v-model.trim="form[item.key]"
              class="textarea input-wide"
              :placeholder="item.placeholder"
            ></textarea>
            <span class="field-hint">{{ item.hint }}</span>
          </label>
        </div>
      </div>

      <div class="toolbar">
        <button class="primary-btn" @click="saveRules" :disabled="saving">
          {{ saving ? '保存中...' : '保存规则' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const saving = ref(false);
const error = ref('');
const successMessage = ref('');
const form = reactive({});

const ruleSections = [
  {
    title: '通用规则',
    desc: '用于统一维护整个推荐系统的基础约束，所有推荐都会优先经过这一层。',
    fields: [
      { key: 'plan.global_blacklist_keywords', label: '全局黑名单关键词', placeholder: '如：特殊下架品,不参与推荐商品', hint: '填写后，这些商品将不再出现在推荐结果中' },
      { key: 'plan.general_conflict_pairs', label: '全局冲突对', placeholder: '如：榴莲|柠檬', hint: '用于统一规避不适合同时推荐的商品组合，格式：食材A|食材B' },
      { key: 'plan.global_exclude_tags', label: '全局排除标签', placeholder: '如：exclude_plan,exclude_cold_food', hint: '带有这些标签的商品会被统一排除在推荐之外' }
    ]
  },
  {
    title: '小份优选规则',
    desc: '用于控制小份优选的偏好方向，重点体现饱腹、高纤、清爽和强味降权。',
    fields: [
      { key: 'plan.meal_satiety_keywords', label: '饱腹优先关键词', placeholder: '如：土豆,南瓜,玉米,红薯', hint: '这些食材会更偏向出现在饱腹导向的小份优选中' },
      { key: 'plan.meal_high_fiber_keywords', label: '高纤优先关键词', placeholder: '如：西兰花,芹菜,秋葵', hint: '这些食材会更偏向出现在高纤均衡方向的推荐中' },
      { key: 'plan.meal_refreshing_keywords', label: '清爽优先关键词', placeholder: '如：黄瓜,番茄,生菜', hint: '这些食材会更偏向出现在轻负担、清爽方向的小份优选中' },
      { key: 'plan.meal_strong_flavor_keywords', label: '强味降权关键词', placeholder: '如：洋葱,大葱,蒜,韭菜', hint: '这些食材会适当降低优先级，避免整体口感过重' },
      { key: 'plan.meal_conflict_pairs', label: '小份优选冲突对', placeholder: '如：黄瓜|香蕉,榴莲|柠檬', hint: '用于规避不适合同时进入小份优选的商品组合，格式：食材A|食材B' }
    ]
  },
  {
    title: '场景搭配规则',
    desc: '用于控制榨汁、沙拉、火锅、便当等场景下的优先词、黑名单和冲突规避。',
    fields: [
      { key: 'plan.juice_priority_keywords', label: '榨汁优先关键词', placeholder: '如：橙,苹果,胡萝卜,番茄', hint: '这些食材会更偏向出现在榨汁场景的推荐中' },
      { key: 'plan.juice_blacklist_keywords', label: '榨汁黑名单', placeholder: '如：蒜,洋葱,辣椒', hint: '填写后，这些食材将不再出现在榨汁推荐中' },
      { key: 'plan.juice_conflict_pairs', label: '榨汁冲突对', placeholder: '如：黄瓜|香蕉,番茄|香蕉', hint: '用于规避不适合同时推荐的榨汁组合，格式：食材A|食材B' },
      { key: 'plan.salad_priority_keywords', label: '沙拉优先关键词', placeholder: '如：生菜,黄瓜,番茄,苹果', hint: '这些食材会更偏向出现在沙拉轻食场景的推荐中' },
      { key: 'plan.salad_blacklist_keywords', label: '沙拉黑名单', placeholder: '如：榴莲,菠萝蜜,洋葱', hint: '填写后，这些食材将不再出现在沙拉推荐中' },
      { key: 'plan.salad_conflict_pairs', label: '沙拉冲突对', placeholder: '如：土豆|西瓜,洋葱|草莓', hint: '用于规避不适合同时推荐的沙拉组合，格式：食材A|食材B' },
      { key: 'plan.hotpot_priority_keywords', label: '火锅优先关键词', placeholder: '如：菠菜,金针菇,土豆,玉米', hint: '这些食材会更偏向出现在火锅配菜场景的推荐中' },
      { key: 'plan.hotpot_blacklist_keywords', label: '火锅黑名单', placeholder: '如：鲜切即食,果切杯', hint: '填写后，这些商品将不再出现在火锅配菜推荐中' },
      { key: 'plan.hotpot_conflict_pairs', label: '火锅冲突对', placeholder: '如：西瓜|土豆,榴莲|菠菜', hint: '用于规避不适合同时进入火锅配菜的组合，格式：食材A|食材B' },
      { key: 'plan.bento_priority_keywords', label: '便当优先关键词', placeholder: '如：西兰花,胡萝卜,玉米,秋葵', hint: '这些食材会更偏向出现在便当配菜场景的推荐中' },
      { key: 'plan.bento_blacklist_keywords', label: '便当黑名单', placeholder: '如：鲜切即食,果切杯', hint: '填写后，这些商品将不再出现在便当配菜推荐中' },
      { key: 'plan.bento_conflict_pairs', label: '便当冲突对', placeholder: '如：西瓜|土豆,榴莲|西兰花', hint: '用于规避不适合同时进入便当配菜的组合，格式：食材A|食材B' },
      { key: 'plan.watery_fruit_keywords', label: '高含水水果关键词', placeholder: '如：西瓜,哈密瓜,香瓜', hint: '用于减少不适合火锅或热食场景的高含水水果推荐' }
    ]
  }
];

const ruleFields = ruleSections.flatMap((section) => section.fields);

for (const item of ruleFields) {
  form[item.key] = '';
}

async function loadRules() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await http.get('/plan-rules');
    const rows = Array.isArray(res.data) ? res.data : [];
    const next = {};
    rows.forEach((row) => {
      next[row.ruleKey] = row.ruleValue || '';
    });
    ruleFields.forEach((item) => {
      form[item.key] = next[item.key] || '';
    });
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

async function saveRules() {
  saving.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const payload = {};
    ruleFields.forEach((item) => {
      payload[item.key] = form[item.key] || '';
    });
    await http.post('/plan-rules/save', payload);
    successMessage.value = '规则配置已保存';
    await loadRules();
  } catch (err) {
    error.value = err.message;
  } finally {
    saving.value = false;
  }
}

onMounted(loadRules);
</script>

<style scoped>
.plan-rules-page {
  gap: 24px;
}

.plan-rules-card {
  padding: 30px 32px;
}

.plan-rules-hero {
  align-items: center;
  padding-bottom: 18px;
  border-bottom: 1px solid #edf2e5;
  margin-bottom: 8px;
}

.plan-rules-hero__copy {
  max-width: 720px;
}

.plan-rules-hero__title {
  font-size: 28px;
  line-height: 1.15;
  letter-spacing: -0.02em;
}

.plan-rules-hero__desc {
  margin-top: 12px;
  font-size: 15px;
  line-height: 1.8;
  color: #6f7e62;
}

.rule-section {
  margin-top: 22px;
  padding: 22px 22px 18px;
  border-radius: 22px;
  background: linear-gradient(180deg, #fbfdf8 0%, #f4f8ee 100%);
  border: 1px solid #e5ecdb;
}

.rule-section-head {
  margin-bottom: 14px;
}

.rule-section-head__copy {
  max-width: 760px;
}

.rule-section-head__title {
  font-size: 24px;
  line-height: 1.2;
}

.rule-section-head__desc {
  margin-top: 10px;
  font-size: 14px;
  line-height: 1.85;
  color: #718063;
}

.rule-section :deep(.form-grid) {
  margin-top: 0;
  gap: 16px;
}

.rule-section :deep(.field-block) {
  padding: 16px 18px;
  border-radius: 18px;
  background: rgba(255, 255, 255, 0.92);
  border: 1px solid #e3ead8;
}

.rule-section :deep(.field-label) {
  font-size: 14px;
  color: #40562c;
}

.rule-section :deep(.field-hint) {
  font-size: 12px;
  line-height: 1.75;
}

.rule-section :deep(.textarea) {
  min-height: 108px;
  line-height: 1.75;
  background: #f8fbf4;
}

@media (max-width: 900px) {
  .plan-rules-card {
    padding: 24px 20px;
  }

  .rule-section {
    padding: 18px 16px 16px;
  }

  .plan-rules-hero__title {
    font-size: 24px;
  }

  .rule-section-head__title {
    font-size: 21px;
  }
}
</style>
