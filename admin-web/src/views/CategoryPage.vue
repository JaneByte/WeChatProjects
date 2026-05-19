<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">分类管理</h2>
          <p class="section-desc">管理前台商品分类，支持新增、编辑和启停用</p>
        </div>
        <button class="ghost-btn" @click="loadCategories" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div class="toolbar">
        <select v-model="filterParentId" class="input select">
          <option value="">全部层级</option>
          <option value="0">一级分类</option>
          <option value="child">二级分类</option>
        </select>
        <select v-model="filterStatus" class="input select">
          <option value="">全部状态</option>
          <option value="1">启用</option>
          <option value="0">停用</option>
        </select>
        <button class="primary-btn" @click="applyFilters">筛选</button>
        <button class="ghost-btn" @click="openCreateDialog">新增分类</button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>

      <table v-else class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>分类名称</th>
            <th>层级</th>
            <th>父分类</th>
            <th>排序</th>
            <th>状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in displayList" :key="item.id">
            <td class="table-id-cell">{{ item.id }}</td>
            <td class="table-title-cell">{{ item.name }}</td>
            <td class="table-source-cell">{{ Number(item.parentId || 0) === 0 ? '一级分类' : '二级分类' }}</td>
            <td class="table-note-cell">{{ getParentName(item.parentId) }}</td>
            <td class="table-id-cell">{{ item.sort ?? 0 }}</td>
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
          <tr v-if="!displayList.length">
            <td colspan="7" class="empty-cell">暂无分类数据</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="modal-mask" v-if="showEditor" @click="closeDialog">
      <div class="modal-card" @click.stop>
        <div class="section-head">
          <div>
            <h2 class="section-title">{{ form.id ? '编辑分类' : '新增分类' }}</h2>
            <p class="section-desc">只维护分类基础信息，不改动前台商品内容</p>
          </div>
          <button class="ghost-btn" @click="closeDialog" :disabled="saving">关闭</button>
        </div>

        <div class="form-grid">
          <div class="field-block">
            <label class="field-label">分类名称（必填）</label>
            <input v-model.trim="form.name" class="input" placeholder="如：热销推荐" />
          </div>
          <div class="field-block">
            <label class="field-label">分类层级 / 父分类</label>
            <select v-model="form.parentId" class="input select">
              <option value="0">一级分类</option>
              <option v-for="item in rootCategoryList" :key="item.id" :value="String(item.id)">
                二级分类 / {{ item.name }}
              </option>
            </select>
          </div>
          <div class="field-block">
            <label class="field-label">排序值（越小越靠前）</label>
            <input v-model.number="form.sort" class="input" type="number" min="0" placeholder="如：10" />
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
          <button class="primary-btn" @click="submitCategory" :disabled="saving">
            {{ saving ? '保存中...' : '保存分类' }}
          </button>
          <button class="ghost-btn" @click="closeDialog" :disabled="saving">取消</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const saving = ref(false);
const error = ref('');
const categoryList = ref([]);
const filterParentId = ref('');
const filterStatus = ref('');
const showEditor = ref(false);
const form = reactive(createEmptyForm());
const originalSnapshot = reactive(createEmptyForm());

function createEmptyForm() {
  return {
    id: null,
    parentId: '0',
    name: '',
    sort: 0,
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

const rootCategoryList = computed(() => {
  return categoryList.value.filter((item) => Number(item.parentId || 0) === 0);
});

const displayList = computed(() => {
  return categoryList.value.filter((item) => {
    const parentId = Number(item.parentId || 0);
    const status = Number(item.status || 0);
    const matchParent = filterParentId.value === ''
      || (filterParentId.value === '0' && parentId === 0)
      || (filterParentId.value === 'child' && parentId !== 0);
    const matchStatus = filterStatus.value === '' || status === Number(filterStatus.value);
    return matchParent && matchStatus;
  });
});

function getParentName(parentId) {
  const currentParentId = Number(parentId || 0);
  if (currentParentId === 0) {
    return '-';
  }
  const parent = rootCategoryList.value.find((item) => item.id === currentParentId);
  return parent ? parent.name : `ID ${currentParentId}`;
}

function formatFieldValue(key, value) {
  if (key === 'parentId') {
    return Number(value) === 0 ? '一级分类' : `二级分类 / ${getParentName(value)}`;
  }
  if (key === 'status') {
    return Number(value) === 1 ? '启用' : '停用';
  }
  return value === '' || value === null || value === undefined ? '-' : String(value);
}

function buildDiffLines() {
  const fields = [
    { key: 'name', label: '名称' },
    { key: 'parentId', label: '层级/父分类' },
    { key: 'sort', label: '排序值' },
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

function applyFilters() {
  error.value = '';
}

async function loadCategories() {
  loading.value = true;
  error.value = '';
  try {
    const res = await http.get('/category/list');
    categoryList.value = (res.data || []).slice().sort((prev, next) => {
      const sortDiff = Number(prev.sort || 0) - Number(next.sort || 0);
      if (sortDiff !== 0) {
        return sortDiff;
      }
      return Number(prev.id || 0) - Number(next.id || 0);
    });
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
    parentId: String(item.parentId ?? 0),
    name: item.name || '',
    sort: toNumber(item.sort || 0),
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

function validateForm() {
  if (!form.name) {
    return '请输入分类名称';
  }
  const sortValue = toNumber(form.sort);
  if (sortValue < 0) {
    return '排序值不能小于 0';
  }
  if (form.id && Number(form.id) === Number(form.parentId)) {
    return '父分类不能选择自己';
  }
  return '';
}

async function submitCategory() {
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
  try {
    await http.post('/category/save', {
      ...form,
      parentId: Number(form.parentId || 0),
      sort: toNumber(form.sort || 0),
      status: Number(form.status ?? 1)
    });
    closeDialog();
    await loadCategories();
  } catch (err) {
    error.value = err.message;
  } finally {
    saving.value = false;
  }
}

async function toggleStatus(item) {
  try {
    await http.post('/category/status', null, {
      params: {
        id: item.id,
        status: item.status === 1 ? 0 : 1
      }
    });
    await loadCategories();
  } catch (err) {
    error.value = err.message;
  }
}

onMounted(() => {
  loadCategories();
  window.addEventListener('keydown', onEscClose);
});

onUnmounted(() => {
  document.body.style.overflow = '';
  window.removeEventListener('keydown', onEscClose);
});
</script>
