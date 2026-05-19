<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">店铺信息</h2>
        </div>
        <div class="topbar-actions">
          <button class="ghost-btn" @click="loadShop" :disabled="loading || saving">
            {{ loading ? '加载中...' : '刷新' }}
          </button>
          <button class="primary-btn" @click="saveShop" :disabled="loading || saving">
            {{ saving ? '保存中...' : '保存信息' }}
          </button>
        </div>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <template v-else>
        <div class="form-section-head">
          <h3 class="form-section-title">基础资料</h3>
        </div>

        <div class="form-grid">
          <label class="field-block">
            <span class="field-label">店铺名称</span>
            <input v-model.trim="shop.shopName" class="input" placeholder="用于前台展示的店铺名称" />
          </label>
          <div class="field-block">
            <span class="field-label">登录账号</span>
            <div class="readonly-field">{{ shop.username || '-' }}</div>
          </div>
          <label class="field-block">
            <span class="field-label">联系人</span>
            <input v-model.trim="shop.contactName" class="input" placeholder="请输入联系人姓名" />
          </label>
          <label class="field-block">
            <span class="field-label">联系电话</span>
            <input v-model.trim="shop.phone" class="input" placeholder="请输入联系电话" />
          </label>
          <label class="field-block input-wide">
            <span class="field-label">店铺地址</span>
            <input v-model.trim="shop.address" class="input input-wide" placeholder="请输入店铺地址" />
          </label>
        </div>

        <div class="form-section-head">
          <h3 class="form-section-title">账号信息</h3>
        </div>

        <div class="detail-box detail-grid">
          <div class="detail-item">
            <span class="detail-label">账号状态</span>
            <span :class="['status-pill', shopStatusClass(shop.status)]">{{ formatStatus(shop.status) }}</span>
          </div>
        </div>
      </template>
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
const shop = reactive({
  username: '',
  shopName: '',
  contactName: '',
  phone: '',
  address: '',
  status: 1
});

function formatStatus(status) {
  if (status === 1) {
    return '正常';
  }
  if (status === 2) {
    return '待审核';
  }
  return '禁用';
}

function shopStatusClass(status) {
  if (status === 1) {
    return 'status-active';
  }
  if (status === 2) {
    return 'status-warn';
  }
  return 'status-off';
}

async function loadShop() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await http.get('/session/me');
    Object.assign(shop, res.data || {});
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

async function saveShop() {
  if (!shop.shopName) {
    error.value = '店铺名称不能为空';
    return;
  }
  if (!shop.contactName) {
    error.value = '联系人不能为空';
    return;
  }
  if (!shop.phone) {
    error.value = '联系电话不能为空';
    return;
  }
  saving.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await http.post('/session/profile', {
      shopName: shop.shopName,
      contactName: shop.contactName,
      phone: shop.phone,
      address: shop.address
    });
    Object.assign(shop, res.data || {});
    successMessage.value = '店铺信息已保存';
  } catch (err) {
    error.value = err.message;
  } finally {
    saving.value = false;
  }
}

onMounted(loadShop);
</script>
