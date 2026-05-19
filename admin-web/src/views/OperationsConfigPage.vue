<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">运营配置中心</h2>
          <p class="section-desc">统一维护首页展示、当季精选与套餐优惠等运营配置。</p>
        </div>
        <button class="ghost-btn" @click="loadAll" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

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
            <span class="field-hint">当前值：{{ formatCurrentValue(seasonalForm[item.key]) }}</span>
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
            <p class="section-desc">统一维护小份优选与蔬果搭配的折扣率、最低优惠额和最高优惠额。</p>
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
            <span class="field-hint">当前值：{{ formatCurrentValue(packPricingForm[item.key]) }}</span>
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
const savingSeasonal = ref(false);
const savingPackPricing = ref(false);
const error = ref('');
const successMessage = ref('');

const seasonalForm = reactive({});
const packPricingForm = reactive({});

const DEFAULT_CONFIG_VALUES = {
  'weight.season': '0.30',
  'weight.freshness': '0.08',
  'weight.sales': '0.16',
  'weight.margin': '0.10',
  'weight.stock': '0.20',
  'weight.budget': '0.16',
  'title.template': '{seasonText}当季精选',
  'subtitle.template': '优先新鲜度、当季适配和库存稳定性',
  'home.hero.image': '',
  'home.hero.linkType': 'none',
  'home.hero.linkValue': '',
  'pack.combo.discount_rate': '0.05',
  'pack.combo.min_discount': '2.00',
  'pack.combo.max_discount': '12.00',
  'pack.meal.discount_rate': '0.03',
  'pack.meal.min_discount': '1.00',
  'pack.meal.max_discount': '8.00'
};

const seasonalFields = [
  { key: 'weight.season', label: '当季权重', placeholder: '如：0.30', hint: '仅用于当季精选排序，值越高越偏向时令适配' },
  { key: 'weight.freshness', label: '供应状态权重', placeholder: '如：0.08', hint: '仅用于当季精选排序，反映可售状态和综合供应表现，不是入库时间新鲜度' },
  { key: 'weight.sales', label: '销量权重', placeholder: '如：0.16', hint: '仅用于当季精选排序，值越高越偏向热销表现' },
  { key: 'weight.margin', label: '价差权重', placeholder: '如：0.10', hint: '仅用于当季精选排序，值越高越偏向原价/售价差' },
  { key: 'weight.stock', label: '库存权重', placeholder: '如：0.20', hint: '仅用于当季精选排序，值越高越偏向库存稳定商品' },
  { key: 'weight.budget', label: '预算权重', placeholder: '如：0.16', hint: '仅用于当季精选排序，值越高越偏向价格匹配度' },
  { key: 'title.template', label: '标题模板', placeholder: '如：{seasonText}当季精选', hint: '支持 {seasonText} 占位符' },
  { key: 'subtitle.template', label: '副标题模板', placeholder: '如：优先新鲜度、当季适配和库存稳定性', hint: '支持 {seasonText} 占位符' },
  { key: 'home.hero.image', label: '首页主视觉图', placeholder: '填写图片地址或 cloud 文件地址', hint: '首页顶部固定展示的主视觉图片' },
  { key: 'home.hero.linkType', label: '主视觉跳转类型', placeholder: '如：none / scene / goods / coupon', hint: '不跳转可填写 none' },
  { key: 'home.hero.linkValue', label: '主视觉跳转值', placeholder: '如：时令 / 123 / 空', hint: '根据跳转类型填写对应值' }
];

const packPricingFields = [
  { key: 'pack.combo.discount_rate', label: '搭配折扣率', placeholder: '如：0.05', hint: '蔬果搭配基础折扣率' },
  { key: 'pack.combo.min_discount', label: '搭配最低优惠额', placeholder: '如：2.00', hint: '蔬果搭配至少优惠多少' },
  { key: 'pack.combo.max_discount', label: '搭配最高优惠额', placeholder: '如：12.00', hint: '蔬果搭配最多优惠多少' },
  { key: 'pack.meal.discount_rate', label: '小份优选折扣率', placeholder: '如：0.03', hint: '小份优选基础折扣率' },
  { key: 'pack.meal.min_discount', label: '小份优选最低优惠额', placeholder: '如：1.00', hint: '小份优选至少优惠多少' },
  { key: 'pack.meal.max_discount', label: '小份优选最高优惠额', placeholder: '如：8.00', hint: '小份优选最多优惠多少' }
];

for (const item of seasonalFields) {
  seasonalForm[item.key] = '';
}
for (const item of packPricingFields) {
  packPricingForm[item.key] = '';
}

function mapRowsToConfig(rows = []) {
  const next = {};
  (Array.isArray(rows) ? rows : []).forEach((row) => {
    const key = row?.ruleKey || row?.configKey || '';
    const value = row?.ruleValue ?? row?.configValue ?? '';
    if (key) {
      next[key] = value;
    }
  });
  return next;
}

function resolveValue(key, value) {
  if (value !== undefined && value !== null && String(value).trim() !== '') {
    return String(value);
  }
  if (Object.prototype.hasOwnProperty.call(DEFAULT_CONFIG_VALUES, key)) {
    return DEFAULT_CONFIG_VALUES[key];
  }
  return '';
}

function formatCurrentValue(value) {
  const text = String(value ?? '').trim();
  return text || '当前未单独配置';
}

async function loadSeasonalConfig() {
  const res = await http.get('/seasonal-config');
  const data = mapRowsToConfig(res.data);
  seasonalFields.forEach((item) => {
    seasonalForm[item.key] = resolveValue(item.key, data[item.key]);
  });
}

async function loadPackPricingRules() {
  const res = await http.get('/pack-pricing-rules');
  const next = mapRowsToConfig(res.data);
  packPricingFields.forEach((item) => {
    packPricingForm[item.key] = resolveValue(item.key, next[item.key]);
  });
}

async function loadAll() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    await Promise.all([loadSeasonalConfig(), loadPackPricingRules()]);
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
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
