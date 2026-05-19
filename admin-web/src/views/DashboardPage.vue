<template>
  <div class="page-grid">
    <div class="section-card">
      <div class="overview-hero">
        <div>
          <div class="hero-kicker">FreshTime 店铺总览</div>
          <h2 class="section-title">经营数据概览</h2>
          <p class="section-desc">聚焦销售表现、履约进度与特色功能转化，便于快速掌握店铺当前经营情况</p>
        </div>
        <div class="hero-actions">
          <button class="ghost-btn" @click="loadOverview" :disabled="loading">
            {{ loading ? '加载中...' : '刷新数据' }}
          </button>
        </div>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>

      <div v-else class="stats-grid dashboard-stats-grid">
        <div class="stat-card stat-card-primary">
          <span class="stat-label">累计销售额</span>
          <strong class="stat-value">¥{{ overview.totalSalesAmount }}</strong>
          <span class="card-tip">当前店铺已支付订单累计成交金额</span>
        </div>
        <div class="stat-card stat-card-emphasis">
          <span class="stat-label">累计订单数</span>
          <strong class="stat-value">{{ overview.orderCount }}</strong>
          <span class="card-tip">店铺累计生成的订单数量</span>
        </div>
        <div class="stat-card stat-card-warning">
          <span class="stat-label">待发货订单</span>
          <strong class="stat-value">{{ overview.pendingDeliveryOrderCount }}</strong>
          <span class="card-tip">当前需要优先处理的履约任务</span>
        </div>
        <div class="stat-card">
          <span class="stat-label">上架商品数</span>
          <strong class="stat-value">{{ overview.onSaleGoodsCount }}</strong>
          <span class="card-tip">当前前台可正常销售的商品数量</span>
        </div>
        <div class="stat-card stat-card-feature-lite">
          <span class="stat-label">小份优选订单</span>
          <strong class="stat-value">{{ overview.mealOrderCount }}</strong>
          <span class="card-tip">包含小份优选商品的已支付订单</span>
        </div>
        <div class="stat-card stat-card-feature-lite">
          <span class="stat-label">搭配订单</span>
          <strong class="stat-value">{{ overview.comboOrderCount }}</strong>
          <span class="card-tip">包含蔬果搭配商品的已支付订单</span>
        </div>
        <div class="stat-card stat-card-feature-lite">
          <span class="stat-label">当季精选订单</span>
          <strong class="stat-value">{{ overview.seasonalOrderCount }}</strong>
          <span class="card-tip">包含时令推荐商品的已支付订单</span>
        </div>
      </div>
    </div>

    <div class="section-card">
      <div class="section-head">
        <div>
          <h2 class="section-title">经营提醒</h2>
          <p class="section-desc">结合当前订单、商品与特色功能表现，帮助快速判断优先处理事项</p>
        </div>
      </div>

      <div class="insight-grid">
        <div class="insight-card insight-card-priority">
          <span class="insight-title">履约优先级</span>
          <strong class="insight-value">{{ overview.pendingDeliveryOrderCount }}</strong>
          <p class="insight-desc">{{ pendingDeliveryInsight }}</p>
        </div>
        <div class="insight-card insight-card-supply">
          <span class="insight-title">商品供给</span>
          <strong class="insight-value">{{ overview.onSaleGoodsCount }}/{{ overview.goodsCount }}</strong>
          <p class="insight-desc">{{ goodsSupplyInsight }}</p>
        </div>
        <div class="insight-card insight-card-feature">
          <span class="insight-title">特色功能转化</span>
          <strong class="insight-value">{{ featureOrderCount }}</strong>
          <p class="insight-desc">{{ featureInsight }}</p>
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

const featureOrderCount = computed(() => {
  return Number(overview.mealOrderCount || 0)
    + Number(overview.comboOrderCount || 0)
    + Number(overview.seasonalOrderCount || 0);
});

const pendingDeliveryInsight = computed(() => {
  const count = Number(overview.pendingDeliveryOrderCount || 0);
  if (!count) {
    return '当前没有待发货订单，履约状态较稳定。';
  }
  return `当前有 ${count} 笔待发货订单，建议优先处理发货与履约。`;
});

const goodsSupplyInsight = computed(() => {
  const onSaleGoodsCount = Number(overview.onSaleGoodsCount || 0);
  const goodsCount = Number(overview.goodsCount || 0);
  if (!goodsCount) {
    return '当前暂未录入商品信息。';
  }
  return `当前上架商品 ${onSaleGoodsCount} 个，共维护商品 ${goodsCount} 个，可支撑日常前台展示。`;
});

const featureInsight = computed(() => {
  const seasonalOrderCount = Number(overview.seasonalOrderCount || 0);
  const featureCount = Number(featureOrderCount.value || 0);
  if (!featureCount) {
    return '当前特色功能订单数量较少。';
  }
  return `特色功能累计产生 ${featureCount} 笔订单，其中当季精选 ${seasonalOrderCount} 笔。`;
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
