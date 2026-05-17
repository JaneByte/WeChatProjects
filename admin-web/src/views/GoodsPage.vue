<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">商品管理</h2>
          <p class="section-desc">已接商品查询与上下架接口</p>
        </div>
        <button class="ghost-btn" @click="loadGoods" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div class="toolbar">
        <input v-model.trim="keyword" class="input" placeholder="搜索商品名/关键词/产地" />
        <select v-model="status" class="input select">
          <option value="">全部状态</option>
          <option value="1">上架</option>
          <option value="0">下架</option>
        </select>
        <button class="primary-btn" @click="loadGoods">查询</button>
        <button class="ghost-btn" @click="openCreateDialog">新增商品</button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <table v-else class="data-table">
        <thead>
          <tr>
            <th>ID</th>
            <th>商品名</th>
            <th>分类</th>
            <th>价格</th>
            <th>单位</th>
            <th>库存</th>
            <th>产地</th>
            <th>当季供应</th>
            <th>状态</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in goodsList" :key="item.id">
            <td>{{ item.id }}</td>
            <td>
              <div class="cell-title">{{ item.name }}</div>
              <div class="cell-sub">{{ item.keywords || '未填写关键词' }}</div>
            </td>
            <td>{{ getCategoryName(item.categoryId) }}</td>
            <td>
              <div class="cell-title">¥{{ item.price }}</div>
              <div class="cell-sub" v-if="item.originalPrice">原价 ¥{{ item.originalPrice }}</div>
            </td>
            <td>{{ item.unit || '-' }}</td>
            <td>{{ item.stock }}</td>
            <td>{{ item.origin || '-' }}</td>
            <td>
              <div class="cell-title">{{ buildSeasonSummary(item) }}</div>
              <div class="cell-sub">{{ buildSeasonHintSummary(item) }}</div>
            </td>
            <td>
              <span :class="['status-pill', item.status === 1 ? 'status-active' : 'status-off']">
                {{ item.status === 1 ? '上架中' : '已下架' }}
              </span>
            </td>
            <td>
              <button class="link-btn" @click="openEditDialog(item)">编辑</button>
              <button class="link-btn" @click="toggleStatus(item)">
                {{ item.status === 1 ? '下架' : '上架' }}
              </button>
            </td>
          </tr>
          <tr v-if="!goodsList.length">
            <td colspan="10" class="empty-cell">暂无商品数据</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="modal-mask" v-if="showEditor" @click="closeDialog">
      <div class="modal-card" @click.stop>
        <div class="section-head">
          <div>
            <h2 class="section-title">{{ form.id ? '编辑商品' : '新增商品' }}</h2>
            <p class="section-desc">填写商品基础信息并保存到店铺后台</p>
          </div>
          <button class="ghost-btn" @click="closeDialog" :disabled="saving">关闭</button>
        </div>

        <div class="form-grid">
          <label class="field-block">
            <span class="field-label">商品名称</span>
            <input v-model.trim="form.name" class="input" placeholder="用于前台展示的商品名称" />
          </label>
          <label class="field-block">
            <span class="field-label">商品分类</span>
            <select v-model="form.categoryId" class="input select">
              <option value="">选择分类</option>
              <option v-for="item in categoryList" :key="item.id" :value="item.id">
                {{ item.name }}
              </option>
            </select>
          </label>
          <div class="input-wide upload-row">
            <input v-model.trim="form.mainImage" class="input" placeholder="主图地址" />
            <label class="ghost-btn upload-btn">
              {{ uploadLoading ? '上传中...' : '上传主图' }}
              <input class="hidden-input" type="file" accept="image/*" :disabled="uploadLoading" @change="onSelectImage" />
            </label>
            <button class="ghost-btn" type="button" :disabled="uploadLoading || !form.mainImage" @click="clearImage">
              清空主图
            </button>
          </div>
          <div class="input-wide upload-tip">建议优先使用后台上传，数据库会保存统一的图片地址，方便小程序和店铺后台共用。</div>
          <label class="field-block">
            <span class="field-label">售价（成交价）</span>
            <input v-model.number="form.price" class="input" placeholder="用户下单使用的价格" type="number" min="0" step="0.01" />
          </label>
          <label class="field-block">
            <span class="field-label">原价（划线价）</span>
            <input v-model.number="form.originalPrice" class="input" placeholder="展示对比价，可为空" type="number" min="0" step="0.01" />
          </label>
          <label class="field-block">
            <span class="field-label">库存</span>
            <input v-model.number="form.stock" class="input" placeholder="可售库存数量" type="number" min="0" />
          </label>
          <label class="field-block">
            <span class="field-label">单位</span>
            <input v-model.trim="form.unit" class="input" placeholder="如：斤/盒/个" />
          </label>
          <label class="field-block">
            <span class="field-label">产地</span>
            <input v-model.trim="form.origin" class="input" placeholder="如：山东、新疆、进口" />
          </label>
          <label class="field-block">
            <span class="field-label">供应起始月</span>
            <input v-model.number="form.seasonStartMonth" class="input" placeholder="1-12" type="number" min="1" max="12" />
            <span class="field-hint">支持跨年搭配结束月使用，如 11 到 2 表示冬季供应窗口。</span>
          </label>
          <label class="field-block">
            <span class="field-label">供应结束月</span>
            <input v-model.number="form.seasonEndMonth" class="input" placeholder="1-12" type="number" min="1" max="12" />
            <span class="field-hint">不填写起止月时，系统按普通商品处理，不会重点进入当季精选。</span>
          </label>
          <label class="field-block">
            <span class="field-label">季末阈值天数</span>
            <input v-model.number="form.seasonLateThresholdDays" class="input" placeholder="如：20" type="number" min="1" />
            <span class="field-hint">建议 10-30 天，用于控制“临近过季”提示出现时机。</span>
          </label>
          <label class="field-block input-wide">
            <span class="field-label">关键词</span>
            <input v-model.trim="form.keywords" class="input input-wide" placeholder="用于搜索，逗号分隔" />
          </label>
          <label class="field-block input-wide">
            <span class="field-label">季初提示</span>
            <input v-model.trim="form.seasonEarlyHint" class="input input-wide" placeholder="如：新一季刚上架，适合尝鲜" />
          </label>
          <label class="field-block input-wide">
            <span class="field-label">应季提示</span>
            <input v-model.trim="form.seasonPeakHint" class="input input-wide" placeholder="如：当前正处在最佳赏味期" />
          </label>
          <label class="field-block input-wide">
            <span class="field-label">季末提示</span>
            <input v-model.trim="form.seasonLateHint" class="input input-wide" placeholder="如：临近季末，建议尽快下单" />
          </label>
          <div class="field-block input-wide">
            <span class="field-label">推荐标签（可多选）</span>
            <div class="toolbar" style="margin-top: 0;">
              <label v-for="tag in tagOptions" :key="tag.id" class="ghost-btn" style="padding: 8px 12px; border-radius: 999px;">
                <input type="checkbox" :value="tag.id" v-model="selectedTagIds" style="margin-right: 6px;" />
                {{ tag.tagName }}<span v-if="tag.tagType">（{{ tag.tagType }}）</span>
              </label>
            </div>
          </div>
          <label class="field-block input-wide">
            <span class="field-label">商品详情</span>
            <textarea v-model.trim="form.detail" class="textarea input-wide" placeholder="用于详情页文案展示"></textarea>
          </label>
          <div class="input-wide preview-panel" v-if="form.mainImage || form.detail">
            <div class="preview-media" v-if="resolveImageUrl(form.mainImage)">
              <img :src="resolveImageUrl(form.mainImage)" :alt="form.name || '商品主图预览'" class="preview-image" />
            </div>
            <div class="preview-media preview-empty" v-else>暂无主图预览</div>
            <div class="preview-copy">
              <div class="cell-title">{{ form.name || '商品名称预览' }}</div>
              <div class="cell-sub">{{ getCategoryName(Number(form.categoryId || 0)) }}</div>
              <div class="preview-price">¥{{ form.price || 0 }}</div>
              <p class="preview-text">{{ form.detail || '这里会显示商品详情摘要，方便录入时快速检查内容。' }}</p>
            </div>
          </div>
        </div>

        <div class="toolbar">
          <button class="primary-btn" @click="submitGoods" :disabled="saving">
            {{ saving ? '保存中...' : '保存商品' }}
          </button>
          <button class="ghost-btn" @click="closeDialog" :disabled="saving">取消</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, reactive, ref, watch } from 'vue';
import { http, resolveFileUrl, uploadHttp } from '../services/http';

const loading = ref(false);
const saving = ref(false);
const uploadLoading = ref(false);
const error = ref('');
const successMessage = ref('');
const keyword = ref('');
const status = ref('');
const goodsList = ref([]);
const categoryList = ref([]);
const tagOptions = ref([]);
const selectedTagIds = ref([]);
const originalTagIds = ref([]);
const showEditor = ref(false);
const form = reactive(createEmptyForm());
const originalSnapshot = reactive(createEmptyForm());

function createEmptyForm() {
  return {
    id: null,
    categoryId: '',
    name: '',
    mainImage: '',
    detail: '',
    price: '',
    originalPrice: '',
    stock: 0,
    unit: '斤',
    origin: '',
    keywords: '',
    seasonStartMonth: '',
    seasonEndMonth: '',
    seasonLateThresholdDays: 20,
    seasonEarlyHint: '',
    seasonPeakHint: '',
    seasonLateHint: '',
    status: 1
  };
}

function assignForm(source = {}) {
  Object.assign(form, createEmptyForm(), source);
}

function setOriginalSnapshot(source = {}) {
  Object.assign(originalSnapshot, createEmptyForm(), source);
}

const categoryNameMap = computed(() => {
  return categoryList.value.reduce((acc, item) => {
    acc[item.id] = item.name;
    return acc;
  }, {});
});

function getCategoryName(categoryId) {
  return categoryNameMap.value[categoryId] || `分类 ${categoryId}`;
}

function buildSeasonSummary(item = {}) {
  const start = Number(item.seasonStartMonth || 0);
  const end = Number(item.seasonEndMonth || 0);
  if (start > 0 && end > 0) {
    return start <= end ? `${start}-${end} 月应季` : `${start} 月至次年 ${end} 月应季`;
  }
  return '未配置当季窗口';
}

function buildSeasonHintSummary(item = {}) {
  const hints = [item.seasonEarlyHint, item.seasonPeakHint, item.seasonLateHint]
    .map((text) => String(text || '').trim())
    .filter(Boolean);
  if (!hints.length) {
    return '未配置季节提示文案';
  }
  return `${hints.length} 条提示已配置`;
}

function resolveImageUrl(url) {
  const value = String(url || '').trim();
  if (!value || value.startsWith('cloud://')) {
    return '';
  }
  return resolveFileUrl(value);
}

async function loadGoods() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await http.get('/goods/list', {
      params: {
        keyword: keyword.value,
        status: status.value === '' ? undefined : Number(status.value)
      }
    });
    goodsList.value = res.data || [];
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

async function loadCategories() {
  try {
    const res = await http.get('/category/list');
    categoryList.value = res.data || [];
  } catch (err) {
    error.value = err.message;
  }
}

async function loadTagOptions() {
  try {
    const res = await http.get('/tag/list', {
      params: { structuredOnly: true }
    });
    tagOptions.value = res.data || [];
  } catch (err) {
    error.value = err.message;
  }
}

function openCreateDialog() {
  assignForm();
  setOriginalSnapshot();
  selectedTagIds.value = [];
  originalTagIds.value = [];
  showEditor.value = true;
}

async function openEditDialog(item) {
  const payload = {
    id: item.id,
    categoryId: item.categoryId,
    name: item.name,
    mainImage: item.mainImage || '',
    detail: item.detail || '',
    price: item.price,
    originalPrice: item.originalPrice,
    stock: item.stock,
    unit: item.unit || '斤',
    origin: item.origin || '',
    keywords: item.keywords || '',
    seasonStartMonth: item.seasonStartMonth || '',
    seasonEndMonth: item.seasonEndMonth || '',
    seasonLateThresholdDays: item.seasonLateThresholdDays || 20,
    seasonEarlyHint: item.seasonEarlyHint || '',
    seasonPeakHint: item.seasonPeakHint || '',
    seasonLateHint: item.seasonLateHint || '',
    status: item.status
  };
  assignForm(payload);
  setOriginalSnapshot(payload);
  try {
    const res = await http.get('/goods/tags', {
      params: { goodsId: item.id }
    });
    const tags = (res.data || []).filter((row) => row.tagType);
    selectedTagIds.value = tags.map((row) => Number(row.id)).filter((id) => Number.isFinite(id));
    originalTagIds.value = selectedTagIds.value.slice();
  } catch (err) {
    error.value = err.message;
    selectedTagIds.value = [];
    originalTagIds.value = [];
  }
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

function clearImage() {
  form.mainImage = '';
  successMessage.value = '商品主图已清空，保存后生效';
}

async function onSelectImage(event) {
  const [file] = event.target.files || [];
  event.target.value = '';
  if (!file) {
    return;
  }
  const formData = new FormData();
  formData.append('file', file);
  uploadLoading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await uploadHttp.post('/upload/image', formData, {
      headers: {
        'Content-Type': 'multipart/form-data'
      }
    });
    form.mainImage = res?.data?.url || '';
    successMessage.value = '商品主图已上传';
  } catch (err) {
    error.value = err.message;
  } finally {
    uploadLoading.value = false;
  }
}

async function submitGoods() {
  const safePrice = form.price === '' ? null : Number(form.price);
  const safeOriginalPrice = form.originalPrice === '' ? null : Number(form.originalPrice);
  const safeStock = Number(form.stock || 0);
  if (!form.name) {
    error.value = '商品名称不能为空';
    return;
  }
  if (!form.categoryId) {
    error.value = '请选择商品分类';
    return;
  }
  if (safePrice === null || Number.isNaN(safePrice) || safePrice < 0) {
    error.value = '请填写有效的售价';
    return;
  }
  if (safeOriginalPrice !== null && (Number.isNaN(safeOriginalPrice) || safeOriginalPrice < safePrice)) {
    error.value = '原价必须大于或等于售价';
    return;
  }
  if (Number.isNaN(safeStock) || safeStock < 0) {
    error.value = '库存不能为负数';
    return;
  }
  if (form.seasonStartMonth !== '' && (Number(form.seasonStartMonth) < 1 || Number(form.seasonStartMonth) > 12)) {
    error.value = '供应起始月必须在1到12之间';
    return;
  }
  if (form.seasonEndMonth !== '' && (Number(form.seasonEndMonth) < 1 || Number(form.seasonEndMonth) > 12)) {
    error.value = '供应结束月必须在1到12之间';
    return;
  }
  const changeList = resolveChangeList({
    ...form,
    price: safePrice,
    originalPrice: safeOriginalPrice,
    stock: safeStock
  });
  const confirmText = changeList.length
    ? `即将更新以下字段：\n${changeList.join('\n')}\n\n确认保存吗？`
    : '未检测到变更，是否仍然保存？';
  const confirmRes = await new Promise((resolve) => {
    window.setTimeout(() => resolve(window.confirm(confirmText)), 0);
  });
  if (!confirmRes) return;

  saving.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    await http.post('/goods/save', {
      ...form,
      categoryId: form.categoryId === '' ? null : Number(form.categoryId),
      price: safePrice,
      originalPrice: safeOriginalPrice,
      stock: safeStock,
      seasonStartMonth: form.seasonStartMonth === '' ? null : Number(form.seasonStartMonth),
      seasonEndMonth: form.seasonEndMonth === '' ? null : Number(form.seasonEndMonth),
      seasonLateThresholdDays: Number(form.seasonLateThresholdDays || 20),
      tagIds: selectedTagIds.value
    });
    closeDialog();
    const successText = form.id ? '商品信息已更新' : '商品已创建';
    await loadGoods();
    successMessage.value = successText;
  } catch (err) {
    error.value = err.message;
  } finally {
    saving.value = false;
  }
}

function resolveChangeList(next) {
  if (!form.id) return ['新建商品'];
  const list = [];
  const normalizeTagIds = (ids = []) => ids.map((id) => Number(id)).filter((id) => Number.isFinite(id)).sort((a, b) => a - b);
  const formatTagNames = (ids = []) => {
    const idSet = new Set(normalizeTagIds(ids));
    const names = tagOptions.value
      .filter((tag) => idSet.has(Number(tag.id)))
      .map((tag) => tag.tagName);
    return names.length ? names.join('、') : '-';
  };
  const pairs = [
    ['商品名称', originalSnapshot.name, next.name],
    ['分类', Number(originalSnapshot.categoryId || 0), Number(next.categoryId || 0)],
    ['售价', Number(originalSnapshot.price || 0), Number(next.price || 0)],
    ['原价', Number(originalSnapshot.originalPrice || 0), Number(next.originalPrice || 0)],
    ['库存', Number(originalSnapshot.stock || 0), Number(next.stock || 0)],
    ['单位', originalSnapshot.unit || '', next.unit || ''],
    ['产地', originalSnapshot.origin || '', next.origin || ''],
    ['关键词', originalSnapshot.keywords || '', next.keywords || ''],
    ['供应起始月', Number(originalSnapshot.seasonStartMonth || 0), Number(next.seasonStartMonth || 0)],
    ['供应结束月', Number(originalSnapshot.seasonEndMonth || 0), Number(next.seasonEndMonth || 0)],
    ['季末阈值天数', Number(originalSnapshot.seasonLateThresholdDays || 0), Number(next.seasonLateThresholdDays || 0)],
    ['季初提示', originalSnapshot.seasonEarlyHint || '', next.seasonEarlyHint || ''],
    ['应季提示', originalSnapshot.seasonPeakHint || '', next.seasonPeakHint || ''],
    ['季末提示', originalSnapshot.seasonLateHint || '', next.seasonLateHint || ''],
    ['主图地址', originalSnapshot.mainImage || '', next.mainImage || '']
  ];
  pairs.forEach(([label, prev, cur]) => {
    if (`${prev}` !== `${cur}`) {
      list.push(`${label}: ${prev || '-'} -> ${cur || '-'}`);
    }
  });
  const prevTags = normalizeTagIds(originalTagIds.value);
  const nextTags = normalizeTagIds(selectedTagIds.value);
  if (JSON.stringify(prevTags) !== JSON.stringify(nextTags)) {
    list.push(`推荐标签: ${formatTagNames(prevTags)} -> ${formatTagNames(nextTags)}`);
  }
  return list;
}

async function toggleStatus(item) {
  try {
    await http.post('/goods/status', null, {
      params: {
        id: item.id,
        status: item.status === 1 ? 0 : 1
      }
    });
    const successText = item.status === 1 ? '商品已下架' : '商品已上架';
    await loadGoods();
    successMessage.value = successText;
  } catch (err) {
    error.value = err.message;
  }
}

onMounted(async () => {
  await Promise.all([loadGoods(), loadCategories(), loadTagOptions()]);
  window.addEventListener('keydown', onEscClose);
});

onUnmounted(() => {
  document.body.style.overflow = '';
  window.removeEventListener('keydown', onEscClose);
});
</script>
