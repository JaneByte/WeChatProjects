<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">优惠券管理</h2>
          <p class="section-desc">维护当前店铺可发放的优惠券模板</p>
        </div>
        <button class="ghost-btn" @click="loadCoupons" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div class="toolbar">
        <button class="primary-btn" @click="openCreateDialog">新增优惠券</button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <table v-else class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>名称</th>
            <th>说明</th>
            <th>门槛</th>
            <th>优惠</th>
            <th>到期日</th>
            <th>状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in couponList" :key="item.id">
            <td class="table-id-cell">{{ item.id }}</td>
            <td class="table-title-cell">{{ item.title }}</td>
            <td class="table-note-cell">{{ item.conditionText || '通用优惠券' }}</td>
            <td class="table-amount-cell">¥{{ item.thresholdAmount }}</td>
            <td class="table-amount-cell">¥{{ item.discountAmount }}</td>
            <td class="table-time-cell">{{ item.expireDate || '-' }}</td>
            <td class="table-status-cell">
              <span :class="['status-pill', item.status === 1 ? 'status-active' : 'status-off']">
                {{ item.status === 1 ? '启用' : '停用' }}
              </span>
            </td>
            <td class="table-actions-cell">
              <div class="table-actions">
                <button class="link-btn" @click="openEditDialog(item)">编辑</button>
                <button class="link-btn" @click="toggleStatus(item)">
                  {{ item.status === 1 ? '停用' : '启用' }}
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="!couponList.length">
            <td colspan="8" class="empty-cell">暂无优惠券数据</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="modal-mask" v-if="showEditor" @click="closeDialog">
      <div class="modal-card" @click.stop>
        <div class="section-head">
          <div>
            <h2 class="section-title">{{ form.id ? '编辑优惠券' : '新增优惠券' }}</h2>
            <p class="section-desc">填写当前店铺的优惠券模板信息后保存</p>
          </div>
          <button class="ghost-btn" @click="closeDialog" :disabled="saving">关闭</button>
        </div>

        <div class="form-grid">
          <div class="field-block">
            <label class="field-label">优惠券名称（必填）</label>
            <input v-model.trim="form.name" class="input" placeholder="如：满39减5" />
          </div>
          <div class="field-block">
            <label class="field-label">使用门槛金额（元）</label>
            <input v-model.number="form.thresholdAmount" class="input" type="number" min="0" step="0.01" placeholder="如：39" />
          </div>
          <div class="field-block">
            <label class="field-label">优惠金额（元）</label>
            <input v-model.number="form.discountAmount" class="input" type="number" min="0" step="0.01" placeholder="如：5" />
          </div>
          <div class="field-block">
            <label class="field-label">到期日期</label>
            <input v-model="form.expireDate" class="input" type="date" />
          </div>
          <div class="field-block input-wide">
            <label class="field-label">优惠说明</label>
            <textarea v-model.trim="form.description" class="textarea" placeholder="如：仅限生鲜分类，节假日可用"></textarea>
          </div>
          <div class="field-block">
            <label class="field-label">状态</label>
            <select v-model="form.status" class="input select">
              <option :value="1">启用</option>
              <option :value="0">停用</option>
            </select>
          </div>
        </div>

        <div class="toolbar">
          <button class="primary-btn" @click="submitCoupon" :disabled="saving">
            {{ saving ? '保存中...' : '保存优惠券' }}
          </button>
          <button class="ghost-btn" @click="closeDialog" :disabled="saving">取消</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, onUnmounted, reactive, ref, watch } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const saving = ref(false);
const error = ref('');
const successMessage = ref('');
const couponList = ref([]);
const showEditor = ref(false);
const form = reactive(createEmptyForm());
const originalSnapshot = reactive(createEmptyForm());

function createEmptyForm() {
  return {
    id: null,
    name: '',
    description: '',
    thresholdAmount: 0,
    discountAmount: 0,
    expireDate: '',
    status: 1
  };
}

function assignForm(source = {}) {
  Object.assign(form, createEmptyForm(), source);
}

function assignSnapshot(source = {}) {
  Object.assign(originalSnapshot, createEmptyForm(), source);
}

function toNumber(value) {
  const num = Number(value);
  return Number.isFinite(num) ? num : 0;
}

function formatFieldValue(key, value) {
  if (key === 'thresholdAmount' || key === 'discountAmount') {
    return `¥${toNumber(value)}`;
  }
  if (key === 'status') {
    return Number(value) === 1 ? '启用' : '停用';
  }
  return value === '' || value === null || value === undefined ? '-' : String(value);
}

function buildDiffLines() {
  const fields = [
    { key: 'name', label: '名称' },
    { key: 'description', label: '说明' },
    { key: 'thresholdAmount', label: '门槛金额' },
    { key: 'discountAmount', label: '优惠金额' },
    { key: 'expireDate', label: '到期日期' },
    { key: 'status', label: '状态' }
  ];
  return fields
    .map(({ key, label }) => {
      const prev = formatFieldValue(key, originalSnapshot[key]);
      const next = formatFieldValue(key, form[key]);
      return prev !== next ? `${label}: ${prev} -> ${next}` : '';
    })
    .filter(Boolean);
}

function validateForm() {
  if (!form.name) {
    return '请输入优惠券名称';
  }
  const threshold = toNumber(form.thresholdAmount);
  const discount = toNumber(form.discountAmount);
  if (threshold < 0) {
    return '使用门槛不能小于 0';
  }
  if (discount < 0) {
    return '优惠金额不能小于 0';
  }
  if (discount > threshold && threshold > 0) {
    return '优惠金额不能大于使用门槛';
  }
  return '';
}

async function loadCoupons() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await http.get('/coupon/list');
    couponList.value = res.data || [];
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

function openCreateDialog() {
  assignForm();
  assignSnapshot();
  showEditor.value = true;
}

function openEditDialog(item) {
  const current = {
    id: item.id,
    name: item.title,
    description: item.conditionText,
    thresholdAmount: toNumber(item.thresholdAmount),
    discountAmount: toNumber(item.discountAmount),
    expireDate: item.expireDate,
    status: Number(item.status ?? 1)
  };
  assignForm(current);
  assignSnapshot(current);
  showEditor.value = true;
}

function closeDialog() {
  showEditor.value = false;
}

function onEscClose(event) {
  if (event && event.key === 'Escape' && showEditor.value) {
    closeDialog();
  }
}

watch(showEditor, (value) => {
  document.body.style.overflow = value ? 'hidden' : '';
});

async function submitCoupon() {
  const validateMessage = validateForm();
  if (validateMessage) {
    error.value = validateMessage;
    return;
  }
  if (form.id) {
    const diffs = buildDiffLines();
    const tips = diffs.length ? diffs.join('\n') : '未检测到变更，仍要保存吗？';
    const confirmed = window.confirm(`确认保存以下变更？\n${tips}`);
    if (!confirmed) {
      return;
    }
  }
  saving.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    await http.post('/coupon/save', {
      ...form,
      thresholdAmount: toNumber(form.thresholdAmount),
      discountAmount: toNumber(form.discountAmount),
      status: Number(form.status ?? 1)
    });
    closeDialog();
    const successText = form.id ? '优惠券已更新' : '优惠券已创建';
    await loadCoupons();
    successMessage.value = successText;
  } catch (err) {
    error.value = err.message;
  } finally {
    saving.value = false;
  }
}

async function toggleStatus(item) {
  try {
    await http.post('/coupon/status', null, {
      params: {
        id: item.id,
        status: item.status === 1 ? 0 : 1
      }
    });
    const successText = item.status === 1 ? '优惠券已停用' : '优惠券已启用';
    await loadCoupons();
    successMessage.value = successText;
  } catch (err) {
    error.value = err.message;
  }
}

onMounted(() => {
  loadCoupons();
  window.addEventListener('keydown', onEscClose);
});

onUnmounted(() => {
  document.body.style.overflow = '';
  window.removeEventListener('keydown', onEscClose);
});
</script>
