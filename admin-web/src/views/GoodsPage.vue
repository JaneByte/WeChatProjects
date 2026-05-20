<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">商品管理</h2>
          <p class="section-desc">统一维护商品信息、价格库存与前台展示状态</p>
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
            <th class="table-id-cell">ID</th>
            <th class="table-title-cell">商品名</th>
            <th class="table-category-cell">分类</th>
            <th class="table-amount-cell">价格</th>
            <th class="table-amount-cell">秒杀</th>
            <th class="table-amount-cell">首页运营</th>
            <th class="table-unit-cell">单位</th>
            <th class="table-number-cell">总库存</th>
            <th class="table-number-cell">总销量</th>
            <th class="table-status-cell">状态</th>
            <th class="table-actions-cell">操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in goodsList" :key="item.id">
            <td class="table-id-cell">{{ item.id }}</td>
            <td class="table-title-cell">
              <div class="cell-title">{{ item.name }}</div>
            </td>
            <td class="table-category-cell">{{ getCategoryName(item.categoryId) }}</td>
            <td class="table-amount-cell">
              <div class="cell-title">{{ formatGoodsPrice(item) }}</div>
              <div class="cell-sub" v-if="item.originalPrice">原价 ¥{{ item.originalPrice }}</div>
            </td>
            <td class="table-amount-cell">
              <div class="cell-title">{{ resolveFlashSummary(item).title }}</div>
              <div class="cell-sub">{{ resolveFlashSummary(item).subtitle }}</div>
            </td>
            <td class="table-amount-cell">
              <div class="cell-title">{{ resolveHomeDisplaySummary(item).title }}</div>
              <div class="cell-sub">{{ resolveHomeDisplaySummary(item).subtitle }}</div>
            </td>
            <td class="table-unit-cell">{{ item.unit || '-' }}</td>
            <td class="table-number-cell">
              <div class="cell-title">{{ summarizeSkuStock(item) }}</div>
            </td>
            <td class="table-number-cell">
              <div class="cell-title">{{ summarizeSkuSales(item) }}</div>
            </td>
            <td class="table-status-cell">
              <span :class="['status-pill', item.status === 1 ? 'status-active' : 'status-off']">
                {{ item.status === 1 ? '上架中' : '已下架' }}
              </span>
            </td>
            <td class="table-actions-cell">
              <div class="table-actions">
                <button class="link-btn" @click="openEditDialog(item)">编辑</button>
                <button class="link-btn" @click="toggleStatus(item)">
                  {{ item.status === 1 ? '下架' : '上架' }}
                </button>
                <button class="link-btn" @click="openSkuDialog(item)">规格管理</button>
              </div>
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

        <div class="form-section-head">
          <h3 class="form-section-title">基础信息</h3>
          <p class="form-section-desc">先完善商品名称、分类、主图与基础售价信息。</p>
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
          <div class="input-wide upload-tip">建议使用后台上传，便于统一管理商品图片。</div>
          <label class="field-block">
            <span class="field-label">售价（成交价）</span>
            <input v-model.number="form.price" class="input" placeholder="用户下单使用的价格" type="number" min="0" step="0.01" />
          </label>
          <label class="field-block">
            <span class="field-label">原价（划线价）</span>
            <input v-model.number="form.originalPrice" class="input" placeholder="展示对比价，可为空" type="number" min="0" step="0.01" />
          </label>
          <label class="field-block">
            <span class="field-label">商品库存</span>
            <input v-model.number="form.stock" class="input" placeholder="可售库存数量" type="number" min="0" />
            <span class="field-hint">无独立规格时以这里为准；已有规格时以规格管理中的库存汇总为准。</span>
          </label>
          <label class="field-block">
            <span class="field-label">单位</span>
            <input v-model.trim="form.unit" class="input" placeholder="如：斤/盒/个" />
          </label>
          <label class="field-block">
            <span class="field-label">产地</span>
            <input v-model.trim="form.origin" class="input" placeholder="如：山东、新疆、进口" />
          </label>
        </div>

        <div class="form-section-head">
          <h3 class="form-section-title">秒杀配置</h3>
          <p class="form-section-desc">用于控制首页秒杀、秒杀列表与秒杀结算价格。</p>
        </div>

        <div class="form-grid">
          <label class="field-block">
            <span class="field-label">参与秒杀</span>
            <select v-model.number="form.isFlash" class="input select">
              <option :value="0">否</option>
              <option :value="1">是</option>
            </select>
            <span class="field-hint">开启后，前台会按秒杀时间和库存判断是否展示。</span>
          </label>
          <label class="field-block">
            <span class="field-label">秒杀价</span>
            <input v-model.number="form.flashPrice" class="input" placeholder="必须低于当前售价" type="number" min="0" step="0.01" />
          </label>
          <label class="field-block">
            <span class="field-label">秒杀库存</span>
            <input v-model.number="form.flashStock" class="input" placeholder="建议小于等于总库存" type="number" min="0" />
          </label>
          <label class="field-block">
            <span class="field-label">开始时间</span>
            <input v-model.trim="form.flashStartTime" class="input" type="datetime-local" />
          </label>
          <label class="field-block">
            <span class="field-label">结束时间</span>
            <input v-model.trim="form.flashEndTime" class="input" type="datetime-local" />
          </label>
          <div class="field-block">
            <span class="field-label">秒杀状态</span>
            <div class="readonly-field">{{ resolveFlashStatusText(form) }}</div>
            <span class="field-hint">未开始、进行中、已结束会根据当前时间自动判断。</span>
          </div>
        </div>

        <div class="form-section-head">
          <h3 class="form-section-title">季节与推荐配置</h3>
          <p class="form-section-desc">用于控制当季推荐窗口、提示文案与特色标签。</p>
        </div>

        <div class="form-grid">
          <label class="field-block">
            <span class="field-label">是否推荐</span>
            <select v-model.number="form.isRecommend" class="input select">
              <option :value="0">否</option>
              <option :value="1">是</option>
            </select>
          </label>
          <label class="field-block">
            <span class="field-label">首页展示</span>
            <select v-model.number="form.showInHome" class="input select">
              <option :value="0">否</option>
              <option :value="1">是</option>
            </select>
          </label>
          <label class="field-block">
            <span class="field-label">首页排序</span>
            <input v-model.number="form.homeSort" class="input" placeholder="数值越小越靠前" type="number" min="0" />
            <span class="field-hint">建议只给重点商品设置较小排序值，普通商品可保留默认值。</span>
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
        </div>

        <div class="form-section-head">
          <h3 class="form-section-title">详情预览</h3>
          <p class="form-section-desc">补充详情文案后，可在下方同步查看展示效果。</p>
        </div>

        <div class="form-grid">
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

    <div class="modal-mask" v-if="showSkuEditor" @click="closeSkuDialog">
      <div class="modal-card" @click.stop>
        <div class="section-head">
          <div>
            <h2 class="section-title">规格管理</h2>
            <p class="section-desc">{{ skuEditorGoodsName || '当前商品' }} 的规格价格、库存与销量维护</p>
          </div>
          <button class="ghost-btn" @click="closeSkuDialog" :disabled="saving">关闭</button>
        </div>

        <div class="sku-editor-preview">
          <div v-if="formSkuList.length" class="sku-editor-list">
            <div v-for="(sku, index) in formSkuList" :key="sku.id || `${index}-${sku.skuName}`" class="sku-editor-card">
              <div class="sku-editor-card__head">
                <div class="sku-editor-card__title">规格 {{ index + 1 }}</div>
                <button class="link-btn sku-remove-btn" type="button" @click="removeSku(index)">{{ sku.id ? '停用' : '删除' }}</button>
              </div>
              <div class="form-grid sku-form-grid">
                <label class="field-block">
                  <span class="field-label">规格名称</span>
                  <input v-model.trim="sku.skuName" class="input" placeholder="如：小份装、标准装" />
                </label>
                <label class="field-block">
                  <span class="field-label">重量（g）</span>
                  <input v-model.number="sku.skuWeightG" class="input" type="number" min="1" placeholder="如：300" />
                </label>
                <label class="field-block">
                  <span class="field-label">售价</span>
                  <input v-model.number="sku.skuPrice" class="input" type="number" min="0" step="0.01" placeholder="如：9.9" />
                </label>
                <label class="field-block">
                  <span class="field-label">库存</span>
                  <input v-model.number="sku.skuStock" class="input" type="number" min="0" placeholder="如：20" />
                </label>
                <label class="field-block">
                  <span class="field-label">状态</span>
                  <select v-model.number="sku.status" class="input select">
                    <option :value="1">启用</option>
                    <option :value="0">停用</option>
                  </select>
                  <span class="field-hint">已有销量的规格建议保留并停用。</span>
                </label>
                <label class="field-block">
                  <span class="field-label">累计销量</span>
                  <div class="readonly-field">{{ Number(sku.salesVolume || 0) }}</div>
                </label>
              </div>
            </div>
          </div>
          <div v-else class="cell-sub">当前没有独立规格记录，新增后即可按不同规格分别管理价格和库存。</div>
          <div class="toolbar">
            <button class="ghost-btn" type="button" @click="addSku">新增规格</button>
            <button class="primary-btn" type="button" @click="submitSkuOnly" :disabled="saving">
              {{ saving ? '保存中...' : '保存规格' }}
            </button>
            <button class="ghost-btn" type="button" @click="closeSkuDialog" :disabled="saving">取消</button>
          </div>
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
const showSkuEditor = ref(false);
const skuEditorGoodsId = ref(null);
const skuEditorGoodsName = ref('');
const formSkuList = ref([]);
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
    isRecommend: 0,
    showInHome: 1,
    homeSort: 0,
    isFlash: 0,
    flashPrice: '',
    flashStock: 0,
    flashStartTime: '',
    flashEndTime: '',
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

function summarizeSkuStock(item = {}) {
  const skuList = Array.isArray(item.skuList) ? item.skuList : [];
  if (!skuList.length) {
    return `${item.stock ?? 0}`;
  }
  const total = skuList.reduce((sum, sku) => sum + Number(sku.skuStock || 0), 0);
  return `${total}`;
}

function summarizeSkuSales(item = {}) {
  const skuList = Array.isArray(item.skuList) ? item.skuList : [];
  if (!skuList.length) {
    return '0';
  }
  const total = skuList.reduce((sum, sku) => sum + Number(sku.salesVolume || 0), 0);
  return `${total}`;
}

function formatGoodsPrice(item = {}) {
  const skuList = Array.isArray(item.skuList) ? item.skuList : [];
  if (!skuList.length) {
    return `¥${item.price}`;
  }
  const priceList = skuList
    .map((sku) => Number(sku.skuPrice))
    .filter((price) => Number.isFinite(price) && price >= 0);
  if (!priceList.length) {
    return `¥${item.price}`;
  }
  const minPrice = Math.min(...priceList);
  return `¥${minPrice} 起`;
}

function resolveFlashSummary(item = {}) {
  const enabled = Number(item.isFlash || 0) === 1;
  if (!enabled) {
    return {
      title: '未开启',
      subtitle: '普通售价'
    };
  }
  const flashPrice = Number(item.flashPrice || 0);
  const flashStock = Number(item.flashStock || 0);
  const start = String(item.flashStartTime || '').trim();
  const end = String(item.flashEndTime || '').trim();
  if (!(flashPrice > 0) || !(flashStock > 0) || !start || !end) {
    return {
      title: '待完善',
      subtitle: '缺少时间或库存'
    };
  }
  const startTs = new Date(start.replace(/-/g, '/')).getTime();
  const endTs = new Date(end.replace(/-/g, '/')).getTime();
  const now = Date.now();
  let statusText = '待完善';
  if (!Number.isNaN(startTs) && !Number.isNaN(endTs)) {
    if (now < startTs) statusText = '未开始';
    else if (now > endTs) statusText = '已结束';
    else statusText = '进行中';
  }
  return {
    title: `¥${flashPrice.toFixed(2)} · ${statusText}`,
    subtitle: `库存 ${flashStock}`
  };
}

function resolveHomeDisplaySummary(item = {}) {
  const showInHome = Number(item.showInHome || 0) === 1;
  const isRecommend = Number(item.isRecommend || 0) === 1;
  const homeSort = Number(item.homeSort || 0);
  const title = showInHome ? '首页展示中' : '未在首页展示';
  const tags = [];
  if (isRecommend) tags.push('推荐');
  if (showInHome) tags.push(`排序 ${homeSort}`);
  return {
    title,
    subtitle: tags.length ? tags.join(' · ') : '普通商品'
  };
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
    isRecommend: Number(item.isRecommend || 0),
    showInHome: Number(item.showInHome ?? 1),
    homeSort: Number(item.homeSort || 0),
    isFlash: Number(item.isFlash || 0),
    flashPrice: item.flashPrice ?? '',
    flashStock: item.flashStock ?? 0,
    flashStartTime: toDateTimeLocalValue(item.flashStartTime),
    flashEndTime: toDateTimeLocalValue(item.flashEndTime),
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

async function openSkuDialog(item) {
  error.value = '';
  successMessage.value = '';
  skuEditorGoodsId.value = item.id;
  skuEditorGoodsName.value = item.name || '';
  formSkuList.value = normalizeSkuList(item.skuList);
  showSkuEditor.value = true;
}

function closeDialog() {
  showEditor.value = false;
}

function closeSkuDialog() {
  showSkuEditor.value = false;
  skuEditorGoodsId.value = null;
  skuEditorGoodsName.value = '';
  formSkuList.value = [];
}

function onEscClose(event) {
  if (event && event.key === 'Escape') {
    if (showSkuEditor.value) {
      closeSkuDialog();
      return;
    }
    if (showEditor.value) {
      closeDialog();
    }
  }
}

watch([showEditor, showSkuEditor], ([editorVisible, skuVisible]) => {
  document.body.style.overflow = editorVisible || skuVisible ? 'hidden' : '';
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
  const safeIsRecommend = Number(form.isRecommend || 0) === 1 ? 1 : 0;
  const safeShowInHome = Number(form.showInHome || 0) === 1 ? 1 : 0;
  const safeHomeSort = Number(form.homeSort || 0);
  const safeIsFlash = Number(form.isFlash || 0) === 1 ? 1 : 0;
  const safeFlashPrice = form.flashPrice === '' || form.flashPrice == null ? null : Number(form.flashPrice);
  const safeFlashStock = Number(form.flashStock || 0);
  const safeFlashStartTime = normalizeDateTimeValue(form.flashStartTime);
  const safeFlashEndTime = normalizeDateTimeValue(form.flashEndTime);
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
  if (Number.isNaN(safeHomeSort) || safeHomeSort < 0) {
    error.value = '首页排序不能为负数';
    return;
  }
  if (safeIsFlash === 1) {
    if (safeFlashPrice === null || Number.isNaN(safeFlashPrice) || safeFlashPrice <= 0) {
      error.value = '开启秒杀时，请填写有效的秒杀价';
      return;
    }
    if (safeFlashPrice >= safePrice) {
      error.value = '秒杀价必须低于当前售价';
      return;
    }
    if (Number.isNaN(safeFlashStock) || safeFlashStock <= 0) {
      error.value = '开启秒杀时，秒杀库存必须大于0';
      return;
    }
    if (safeFlashStock > safeStock) {
      error.value = '秒杀库存不能大于商品总库存';
      return;
    }
    if (!safeFlashStartTime || !safeFlashEndTime) {
      error.value = '开启秒杀时，请完整填写开始和结束时间';
      return;
    }
    if (new Date(safeFlashEndTime).getTime() <= new Date(safeFlashStartTime).getTime()) {
      error.value = '秒杀结束时间必须晚于开始时间';
      return;
    }
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
    stock: safeStock,
    isRecommend: safeIsRecommend,
    showInHome: safeShowInHome,
    homeSort: safeHomeSort,
    isFlash: safeIsFlash,
    flashPrice: safeFlashPrice,
    flashStock: safeFlashStock,
    flashStartTime: safeFlashStartTime,
    flashEndTime: safeFlashEndTime
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
      isRecommend: safeIsRecommend,
      showInHome: safeShowInHome,
      homeSort: safeHomeSort,
      isFlash: safeIsFlash,
      flashPrice: safeIsFlash === 1 ? safeFlashPrice : null,
      flashStock: safeIsFlash === 1 ? safeFlashStock : 0,
      flashStartTime: safeIsFlash === 1 ? safeFlashStartTime : null,
      flashEndTime: safeIsFlash === 1 ? safeFlashEndTime : null,
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
    ['是否推荐', Number(originalSnapshot.isRecommend || 0) === 1 ? '是' : '否', Number(next.isRecommend || 0) === 1 ? '是' : '否'],
    ['首页展示', Number(originalSnapshot.showInHome || 0) === 1 ? '是' : '否', Number(next.showInHome || 0) === 1 ? '是' : '否'],
    ['首页排序', Number(originalSnapshot.homeSort || 0), Number(next.homeSort || 0)],
    ['参与秒杀', Number(originalSnapshot.isFlash || 0) === 1 ? '是' : '否', Number(next.isFlash || 0) === 1 ? '是' : '否'],
    ['秒杀价', Number(originalSnapshot.flashPrice || 0), Number(next.flashPrice || 0)],
    ['秒杀库存', Number(originalSnapshot.flashStock || 0), Number(next.flashStock || 0)],
    ['秒杀开始时间', originalSnapshot.flashStartTime || '', next.flashStartTime || ''],
    ['秒杀结束时间', originalSnapshot.flashEndTime || '', next.flashEndTime || ''],
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

function normalizeSkuList(list = []) {
  if (!Array.isArray(list)) {
    return [];
  }
  return list.map((sku, index) => ({
    id: sku?.id ?? null,
    skuName: String(sku?.skuName || '').trim(),
    skuWeightG: sku?.skuWeightG ?? '',
    skuPrice: sku?.skuPrice ?? '',
    skuStock: sku?.skuStock ?? 0,
    salesVolume: Number(sku?.salesVolume || 0),
    status: Number(sku?.status ?? 1),
    sort: Number(sku?.sort ?? index + 1)
  }));
}

function createEmptySku(sort = 1) {
  return {
    id: null,
    skuName: '',
    skuWeightG: '',
    skuPrice: '',
    skuStock: 0,
    salesVolume: 0,
    status: 1,
    sort
  };
}

function addSku() {
  formSkuList.value.push(createEmptySku(formSkuList.value.length + 1));
}

function removeSku(index) {
  const current = formSkuList.value[index];
  if (!current) {
    return;
  }
  if (current.id) {
    formSkuList.value[index] = {
      ...current,
      status: 0
    };
  } else {
    formSkuList.value.splice(index, 1);
  }
  formSkuList.value = formSkuList.value.map((sku, idx) => ({
    ...sku,
    sort: idx + 1
  }));
}

function validateSkuList(list = []) {
  if (!Array.isArray(list) || !list.length) {
    return '';
  }
  const duplicateSet = new Set();
  for (const sku of list) {
    const skuName = String(sku?.skuName || '').trim();
    const weight = Number(sku?.skuWeightG);
    const price = Number(sku?.skuPrice);
    const stock = Number(sku?.skuStock);
    if (!skuName) {
      return '规格名称不能为空';
    }
    if (!Number.isFinite(weight) || weight <= 0) {
      return '规格重量必须大于0';
    }
    if (!Number.isFinite(price) || price < 0) {
      return '规格售价必须大于或等于0';
    }
    if (!Number.isFinite(stock) || stock < 0) {
      return '规格库存不能小于0';
    }
    const duplicateKey = `${skuName}#${weight}`;
    if (duplicateSet.has(duplicateKey)) {
      return '同一商品下存在重复规格，请检查规格名称和重量';
    }
    duplicateSet.add(duplicateKey);
  }
  return '';
}

function buildSubmitSkuList() {
  return formSkuList.value.map((sku, index) => ({
    id: sku.id || null,
    skuName: String(sku.skuName || '').trim(),
    skuWeightG: Number(sku.skuWeightG),
    skuPrice: Number(sku.skuPrice),
    skuStock: Number(sku.skuStock || 0),
    status: Number(sku.status ?? 1),
    sort: index + 1
  }));
}

async function submitSkuOnly() {
  const skuError = validateSkuList(formSkuList.value);
  if (skuError) {
    error.value = skuError;
    return;
  }
  if (!skuEditorGoodsId.value) {
    error.value = '未找到当前商品';
    return;
  }
  const target = goodsList.value.find((item) => Number(item.id) === Number(skuEditorGoodsId.value));
  if (!target) {
    error.value = '当前商品不存在，请刷新后重试';
    return;
  }

  saving.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    await http.post('/goods/save', {
      id: target.id,
      categoryId: target.categoryId,
      name: target.name,
      mainImage: target.mainImage || '',
      detail: target.detail || '',
      price: Number(target.price),
      originalPrice: target.originalPrice === '' || target.originalPrice == null ? null : Number(target.originalPrice),
      stock: Number(target.stock || 0),
      isRecommend: Number(target.isRecommend || 0),
      showInHome: Number(target.showInHome ?? 1),
      homeSort: Number(target.homeSort || 0),
      isFlash: Number(target.isFlash || 0),
      flashPrice: target.flashPrice === '' || target.flashPrice == null ? null : Number(target.flashPrice),
      flashStock: Number(target.flashStock || 0),
      flashStartTime: normalizeDateTimeValue(target.flashStartTime),
      flashEndTime: normalizeDateTimeValue(target.flashEndTime),
      unit: target.unit || '斤',
      origin: target.origin || '',
      keywords: target.keywords || '',
      seasonStartMonth: target.seasonStartMonth === '' || target.seasonStartMonth == null ? null : Number(target.seasonStartMonth),
      seasonEndMonth: target.seasonEndMonth === '' || target.seasonEndMonth == null ? null : Number(target.seasonEndMonth),
      seasonLateThresholdDays: Number(target.seasonLateThresholdDays || 20),
      seasonEarlyHint: target.seasonEarlyHint || '',
      seasonPeakHint: target.seasonPeakHint || '',
      seasonLateHint: target.seasonLateHint || '',
      status: Number(target.status ?? 1),
      skuList: buildSubmitSkuList()
    });
    await loadGoods();
    closeSkuDialog();
    successMessage.value = '规格信息已更新';
  } catch (err) {
    error.value = err.message;
  } finally {
    saving.value = false;
  }
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

function toDateTimeLocalValue(value) {
  const text = String(value || '').trim();
  if (!text) return '';
  return text.length >= 16 ? text.slice(0, 16).replace(' ', 'T') : text.replace(' ', 'T');
}

function normalizeDateTimeValue(value) {
  const text = String(value || '').trim();
  if (!text) return null;
  return text.replace('T', ' ') + (text.length === 16 ? ':00' : '');
}

function resolveFlashStatusText(item = {}) {
  if (Number(item.isFlash || 0) !== 1) return '未开启';
  const start = normalizeDateTimeValue(item.flashStartTime);
  const end = normalizeDateTimeValue(item.flashEndTime);
  const flashPrice = Number(item.flashPrice || 0);
  const flashStock = Number(item.flashStock || 0);
  if (!(flashPrice > 0) || !(flashStock > 0) || !start || !end) return '待完善';
  const now = Date.now();
  const startTs = new Date(start.replace(/-/g, '/')).getTime();
  const endTs = new Date(end.replace(/-/g, '/')).getTime();
  if (Number.isNaN(startTs) || Number.isNaN(endTs)) return '待完善';
  if (now < startTs) return '未开始';
  if (now > endTs) return '已结束';
  return '进行中';
}
</script>
