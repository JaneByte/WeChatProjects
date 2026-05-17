<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">店铺信息</h2>
          <p class="section-desc">查看当前店铺的基础资料与经营主体信息</p>
        </div>
        <button class="ghost-btn" @click="loadShop" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>

      <div v-else class="detail-box detail-grid">
        <div class="detail-item">
          <span class="detail-label">店铺名称</span>
          <strong>{{ shop.shopName || '-' }}</strong>
        </div>
        <div class="detail-item">
          <span class="detail-label">登录账号</span>
          <strong>{{ shop.username || '-' }}</strong>
        </div>
        <div class="detail-item">
          <span class="detail-label">联系人</span>
          <strong>{{ shop.contactName || '-' }}</strong>
        </div>
        <div class="detail-item">
          <span class="detail-label">联系电话</span>
          <strong>{{ shop.phone || '-' }}</strong>
        </div>
        <div class="detail-item detail-wide">
          <span class="detail-label">店铺地址</span>
          <strong>{{ shop.address || '-' }}</strong>
        </div>
        <div class="detail-item detail-wide">
          <span class="detail-label">店铺简介</span>
          <strong>{{ shop.description || '当前未填写店铺简介' }}</strong>
        </div>
        <div class="detail-item">
          <span class="detail-label">账号状态</span>
          <strong>{{ formatStatus(shop.status) }}</strong>
        </div>
        <div class="detail-item">
          <span class="detail-label">入驻时间</span>
          <strong>{{ shop.createTime || '-' }}</strong>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted, reactive, ref } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const error = ref('');
const shop = reactive({
  username: '',
  shopName: '',
  contactName: '',
  phone: '',
  address: '',
  description: '',
  status: 1,
  createTime: ''
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

async function loadShop() {
  loading.value = true;
  error.value = '';
  try {
    const res = await http.get('/session/me');
    Object.assign(shop, res.data || {});
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

onMounted(loadShop);
</script>
