<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">运营配置中心</h2>
          <p class="section-desc">统一维护一人食/搭配规则与当季精选权重、文案模板，减少频繁改代码与手工跑脚本。</p>
        </div>
        <button class="ghost-btn" @click="loadAll" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <div class="section-card" style="margin-top: 0;">
        <div class="section-head">
          <div>
            <h3 class="section-title">方案规则</h3>
            <p class="section-desc">用于调整一人食、搭配、榨汁、沙拉等推荐逻辑。</p>
          </div>
        </div>
        <div class="form-grid">
          <label v-for="item in planRuleFields" :key="item.key" class="field-block input-wide">
            <span class="field-label">{{ item.label }}</span>
            <textarea
              v-model.trim="planRuleForm[item.key]"
              class="textarea input-wide"
              :placeholder="item.placeholder"
            ></textarea>
            <span class="field-hint">{{ item.hint }}</span>
          </label>
        </div>
        <div class="toolbar">
          <button class="primary-btn" @click="savePlanRules" :disabled="savingPlanRules">
            {{ savingPlanRules ? '保存中...' : '保存方案规则' }}
          </button>
        </div>
      </div>

      <div class="section-card">
        <div class="section-head">
          <div>
            <h3 class="section-title">当季精选配置</h3>
            <p class="section-desc">用于调整时令权重与前台展示文案。</p>
          </div>
        </div>
        <div class="form-grid">
          <label v-for="item in seasonalFields" :key="item.key" class="field-block">
            <span class="field-label">{{ item.label }}</span>
            <input
              v-model.trim="seasonalForm[item.key]"
              class="input"
              :placeholder="item.placeholder"
            />
            <span class="field-hint">{{ item.hint }}</span>
          </label>
        </div>
        <div class="toolbar">
          <button class="primary-btn" @click="saveSeasonalConfig" :disabled="savingSeasonal">
            {{ savingSeasonal ? '保存中...' : '保存当季配置' }}
          </button>
        </div>
      </div>

      <div class="section-card">
        <div class="section-head">
          <div>
            <h3 class="section-title">套餐优惠配置</h3>
            <p class="section-desc">统一维护一人食与蔬果搭配的折扣率、最低优惠额和最高优惠额。</p>
          </div>
        </div>
        <div class="form-grid">
          <label v-for="item in packPricingFields" :key="item.key" class="field-block">
            <span class="field-label">{{ item.label }}</span>
            <input
              v-model.trim="packPricingForm[item.key]"
              class="input"
              :placeholder="item.placeholder"
            />
            <span class="field-hint">{{ item.hint }}</span>
          </label>
        </div>
        <div class="toolbar">
          <button class="primary-btn" @click="savePackPricingRules" :disabled="savingPackPricing">
            {{ savingPackPricing ? '保存中...' : '保存套餐优惠' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const savingPlanRules = ref(false);
const savingSeasonal = ref(false);
const savingPackPricing = ref(false);
const error = ref('');
const successMessage = ref('');

const planRuleForm = reactive({});
const seasonalForm = reactive({});
const packPricingForm = reactive({});

const planRuleFields = [
  { key: 'plan.strong_flavor_keywords', label: '强味型关键词', placeholder: '如：洋葱,大葱,蒜', hint: '逗号分隔，用于限制重口味食材' },
  { key: 'plan.juice_blacklist_keywords', label: '榨汁黑名单', placeholder: '如：蒜,洋葱,辣椒', hint: '这些食材不会进入榨汁候选池' },
  { key: 'plan.salad_blacklist_keywords', label: '沙拉黑名单', placeholder: '如：榴莲,菠萝蜜,洋葱', hint: '这些食材不会进入沙拉候选池' },
  { key: 'plan.hotpot_blacklist_keywords', label: '火锅黑名单', placeholder: '如：鲜切即食,果切杯', hint: '这些商品不会进入火锅搭配候选池' },
  { key: 'plan.starchy_keywords', label: '高淀粉关键词', placeholder: '如：土豆,南瓜,玉米', hint: '用于限制高淀粉堆叠' },
  { key: 'plan.watery_fruit_keywords', label: '高含水水果关键词', placeholder: '如：西瓜,哈密瓜,香瓜', hint: '用于限制不适合热食搭配的水果' },
  { key: 'plan.juice_conflict_pairs', label: '榨汁冲突对', placeholder: '如：黄瓜|香蕉,番茄|香蕉', hint: '格式：食材A|食材B，多组逗号分隔' },
  { key: 'plan.salad_conflict_pairs', label: '沙拉冲突对', placeholder: '如：土豆|西瓜,洋葱|草莓', hint: '格式：食材A|食材B，多组逗号分隔' },
  { key: 'plan.general_conflict_pairs', label: '通用冲突对', placeholder: '如：榴莲|柠檬', hint: '用于所有场景的基础冲突规避' }
];

const seasonalFields = [
  { key: 'weight.season', label: '当季权重', placeholder: '如：0.26', hint: '越高越偏向时令适配' },
  { key: 'weight.freshness', label: '新鲜度权重', placeholder: '如：0.18', hint: '越高越偏向库存与新鲜度表现' },
  { key: 'weight.sales', label: '销量权重', placeholder: '如：0.18', hint: '越高越偏向热销表现' },
  { key: 'weight.margin', label: '价差权重', placeholder: '如：0.14', hint: '越高越偏向原价/售价差' },
  { key: 'weight.stock', label: '库存权重', placeholder: '如：0.14', hint: '越高越偏向稳定库存' },
  { key: 'weight.budget', label: '预算权重', placeholder: '如：0.10', hint: '越高越偏向价格匹配度' },
  { key: 'title.template', label: '标题模板', placeholder: '如：{seasonText}当季精选', hint: '支持 {seasonText} 占位符' },
  { key: 'subtitle.template', label: '副标题模板', placeholder: '如：优先新鲜度、当季适配和库存稳定性', hint: '支持 {seasonText} 占位符' }
];

const packPricingFields = [
  { key: 'pack.combo.discount_rate', label: '搭配折扣率', placeholder: '如：0.05', hint: '蔬果搭配基础折扣率' },
  { key: 'pack.combo.min_discount', label: '搭配最低优惠额', placeholder: '如：2.00', hint: '蔬果搭配至少优惠多少' },
  { key: 'pack.combo.max_discount', label: '搭配最高优惠额', placeholder: '如：12.00', hint: '蔬果搭配最多优惠多少' },
  { key: 'pack.meal.discount_rate', label: '一人食折扣率', placeholder: '如：0.03', hint: '一人食基础折扣率' },
  { key: 'pack.meal.min_discount', label: '一人食最低优惠额', placeholder: '如：1.00', hint: '一人食至少优惠多少' },
  { key: 'pack.meal.max_discount', label: '一人食最高优惠额', placeholder: '如：8.00', hint: '一人食最多优惠多少' }
];

for (const item of planRuleFields) {
  planRuleForm[item.key] = '';
}
for (const item of seasonalFields) {
  seasonalForm[item.key] = '';
}
for (const item of packPricingFields) {
  packPricingForm[item.key] = '';
}

async function loadPlanRules() {
  const res = await http.get('/plan-rules');
  const rows = Array.isArray(res.data) ? res.data : [];
  const next = {};
  rows.forEach((row) => {
    next[row.ruleKey] = row.ruleValue || '';
  });
  planRuleFields.forEach((item) => {
    planRuleForm[item.key] = next[item.key] || '';
  });
}

async function loadSeasonalConfig() {
  const res = await http.get('/seasonal-config');
  const data = res.data || {};
  seasonalFields.forEach((item) => {
    seasonalForm[item.key] = data[item.key] || '';
  });
}

async function loadPackPricingRules() {
  const res = await http.get('/pack-pricing-rules');
  const rows = Array.isArray(res.data) ? res.data : [];
  const next = {};
  rows.forEach((row) => {
    next[row.ruleKey] = row.ruleValue || '';
  });
  packPricingFields.forEach((item) => {
    packPricingForm[item.key] = next[item.key] || '';
  });
}

async function loadAll() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    await Promise.all([loadPlanRules(), loadSeasonalConfig(), loadPackPricingRules()]);
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

async function savePlanRules() {
  savingPlanRules.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const payload = {};
    planRuleFields.forEach((item) => {
      payload[item.key] = planRuleForm[item.key] || '';
    });
    await http.post('/plan-rules/save', payload);
    successMessage.value = '方案规则已保存';
    await loadPlanRules();
  } catch (err) {
    error.value = err.message;
  } finally {
    savingPlanRules.value = false;
  }
}

async function saveSeasonalConfig() {
  savingSeasonal.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const payload = {};
    seasonalFields.forEach((item) => {
      payload[item.key] = seasonalForm[item.key] || '';
    });
    await http.post('/seasonal-config/save', payload);
    successMessage.value = '当季配置已保存';
    await loadSeasonalConfig();
  } catch (err) {
    error.value = err.message;
  } finally {
    savingSeasonal.value = false;
  }
}

async function savePackPricingRules() {
  savingPackPricing.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const payload = {};
    packPricingFields.forEach((item) => {
      payload[item.key] = packPricingForm[item.key] || '';
    });
    await http.post('/pack-pricing-rules/save', payload);
    successMessage.value = '套餐优惠规则已保存';
    await loadPackPricingRules();
  } catch (err) {
    error.value = err.message;
  } finally {
    savingPackPricing.value = false;
  }
}

onMounted(loadAll);
</script>
