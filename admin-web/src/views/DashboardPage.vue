<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="overview-hero">
        <div>
          <div class="hero-kicker">FreshTime 店铺总览</div>
          <h2 class="section-title">数据概览</h2>
          <p class="section-desc">聚合商品、订单与销售数据，便于展示当前店铺的经营状态</p>
        </div>
        <div class="hero-actions">
          <div class="hero-tag">答辩演示模式</div>
          <button class="ghost-btn" @click="loadOverview" :disabled="loading">
            {{ loading ? '加载中...' : '刷新数据' }}
          </button>
        </div>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>

      <div v-else class="stats-grid">
        <div class="stat-card">
          <span class="stat-label">商品总数</span>
          <strong class="stat-value">{{ overview.goodsCount }}</strong>
          <span class="card-tip">覆盖全部在售与未上架商品</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">上架商品</span>
          <strong class="stat-value">{{ overview.onSaleGoodsCount }}</strong>
          <span class="card-tip">当前前台用户可见商品</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">订单总数</span>
          <strong class="stat-value">{{ overview.orderCount }}</strong>
          <span class="card-tip">当前店铺累计生成的订单</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">待发货订单</span>
          <strong class="stat-value">{{ overview.pendingDeliveryOrderCount }}</strong>
          <span class="card-tip">优先处理的履约任务</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">累计销售额</span>
          <strong class="stat-value">¥{{ overview.totalSalesAmount }}</strong>
          <span class="card-tip">按已支付订单金额统计</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">在售率</span>
          <strong class="stat-value">{{ saleRate }}</strong>
          <span class="card-tip">用于观察当前商品上架活跃度</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">一人食订单</span>
          <strong class="stat-value">{{ overview.mealOrderCount }}</strong>
          <span class="card-tip">一人食方案成交数</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">搭配订单</span>
          <strong class="stat-value">{{ overview.comboOrderCount }}</strong>
          <span class="card-tip">蔬果搭配成交数</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">当季订单</span>
          <strong class="stat-value">{{ overview.seasonalOrderCount }}</strong>
          <span class="card-tip">当季精选来源成交数</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">混合来源订单</span>
          <strong class="stat-value">{{ overview.mixedOrderCount }}</strong>
          <span class="card-tip">同单包含多种来源</span>
        </div>
      </div>
    </div>

    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">运营关注点</h2>
          <p class="section-desc">答辩展示时可以直接说明店铺当前的经营重点</p>
        </div>
      </div>

      <div class="insight-grid">
        <div class="insight-card">
          <span class="insight-title">商品运营</span>
          <strong class="insight-value">{{ overview.onSaleGoodsCount }}/{{ overview.goodsCount }}</strong>
          <p class="insight-desc">在售商品占比可用于说明当前店铺的供给情况。</p>
        </div>
        <div class="insight-card">
          <span class="insight-title">订单履约</span>
          <strong class="insight-value">{{ overview.pendingDeliveryOrderCount }}</strong>
          <p class="insight-desc">待发货订单可作为后台履约流程演示入口。</p>
        </div>
        <div class="insight-card">
          <span class="insight-title">销售表现</span>
          <strong class="insight-value">¥{{ overview.totalSalesAmount }}</strong>
          <p class="insight-desc">可结合订单页说明店铺经营结果与销售转化情况。</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, reactive, ref } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const error = ref('');
const overview = reactive({
  goodsCount: 0,
  onSaleGoodsCount: 0,
  orderCount: 0,
  pendingDeliveryOrderCount: 0,
  totalSalesAmount: 0,
  mealOrderCount: 0,
  comboOrderCount: 0,
  seasonalOrderCount: 0,
  mixedOrderCount: 0
});

const saleRate = computed(() => {
  const goodsCount = Number(overview.goodsCount || 0);
  const onSaleGoodsCount = Number(overview.onSaleGoodsCount || 0);
  if (!goodsCount) {
    return '0%';
  }
  return `${Math.round((onSaleGoodsCount / goodsCount) * 100)}%`;
});

async function loadOverview() {
  loading.value = true;
  error.value = '';
  try {
    const res = await http.get('/dashboard/overview');
    Object.assign(overview, res.data || {});
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

onMounted(loadOverview);
</script>
