<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">方案规则配置</h2>
          <p class="section-desc">集中维护小份优选、搭配、榨汁、沙拉等场景下的推荐规则关键词。</p>
        </div>
        <button class="ghost-btn" @click="loadRules" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <div class="form-grid">
        <label v-for="item in ruleFields" :key="item.key" class="field-block input-wide">
          <span class="field-label">{{ item.label }}</span>
          <textarea
            v-model.trim="form[item.key]"
            class="textarea input-wide"
            :placeholder="item.placeholder"
          ></textarea>
          <span class="field-hint">{{ item.hint }}</span>
        </label>
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

const ruleFields = [
  { key: 'plan.strong_flavor_keywords', label: '强味型关键词', placeholder: '如：洋葱,大葱,蒜', hint: '逗号分隔，用于限制沙拉、轻食等场景的重口味食材' },
  { key: 'plan.juice_blacklist_keywords', label: '榨汁黑名单', placeholder: '如：蒜,洋葱,辣椒', hint: '这些食材不会进入榨汁候选池' },
  { key: 'plan.salad_blacklist_keywords', label: '沙拉黑名单', placeholder: '如：榴莲,菠萝蜜,洋葱', hint: '这些食材不会进入沙拉候选池' },
  { key: 'plan.hotpot_blacklist_keywords', label: '火锅黑名单', placeholder: '如：鲜切即食,果切杯', hint: '这些商品不会进入火锅搭配候选池' },
  { key: 'plan.starchy_keywords', label: '高淀粉关键词', placeholder: '如：土豆,南瓜,玉米', hint: '用于限制榨汁和清爽搭配中过多淀粉型食材' },
  { key: 'plan.watery_fruit_keywords', label: '高含水水果关键词', placeholder: '如：西瓜,哈密瓜,香瓜', hint: '用于限制不适合火锅/热食搭配的高含水水果' },
  { key: 'plan.juice_conflict_pairs', label: '榨汁冲突对', placeholder: '如：黄瓜|香蕉,番茄|香蕉', hint: '格式：食材A|食材B，多组用逗号分隔' },
  { key: 'plan.salad_conflict_pairs', label: '沙拉冲突对', placeholder: '如：土豆|西瓜,洋葱|草莓', hint: '格式：食材A|食材B，多组用逗号分隔' },
  { key: 'plan.general_conflict_pairs', label: '通用冲突对', placeholder: '如：榴莲|柠檬', hint: '用于所有场景的基础冲突规避' }
];

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
