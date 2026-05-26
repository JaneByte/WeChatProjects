<template>
  <div class="page-grid">
    <div class="section-card">
        <div class="section-head">
          <div>
            <h2 class="section-title">订单管理</h2>
            <p class="section-desc">查看订单状态、收货信息与当前待处理的履约任务</p>
          </div>
        <button class="ghost-btn" @click="loadOrders" :disabled="loading">
          {{ loading ? '加载中...' : '刷新' }}
        </button>
      </div>

      <div class="toolbar">
        <input v-model.trim="orderNoKeyword" class="input" placeholder="筛选订单号" />
        <input v-model.trim="userId" class="input" placeholder="按用户ID筛选" />
        <select v-model="status" class="input select">
          <option value="">全部状态</option>
          <option value="0">待付款</option>
          <option value="1">待发货</option>
          <option value="2">待收货</option>
          <option value="3">已完成</option>
          <option value="4">已取消</option>
          <option value="5">已退款</option>
          <option value="7">售后待审核</option>
          <option value="6">退款中</option>
        </select>
        <button class="primary-btn" @click="loadOrders">查询</button>
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>
      <div v-else-if="successMessage" class="success-box">{{ successMessage }}</div>

      <template v-else>
        <div class="stats-grid compact-stats">
          <div class="stat-card compact-card">
            <span class="stat-label">订单总数</span>
            <strong class="stat-value small-value">{{ displayOrders.length }}</strong>
          </div>
          <div class="stat-card compact-card">
            <span class="stat-label">待发货</span>
            <strong class="stat-value small-value">{{ countByStatus(1) }}</strong>
          </div>
          <div class="stat-card compact-card">
            <span class="stat-label">配送中</span>
            <strong class="stat-value small-value">{{ countByStatus(2) }}</strong>
          </div>
          <div class="stat-card compact-card">
            <span class="stat-label">已完成</span>
            <strong class="stat-value small-value">{{ countByStatus(3) }}</strong>
          </div>
        </div>

        <table class="data-table">
        <thead>
          <tr>
            <th>订单号</th>
            <th>订单来源</th>
            <th>用户ID</th>
            <th>收货人</th>
            <th>实付金额</th>
            <th>状态</th>
            <th>创建时间</th>
            <th>操作</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in displayOrders" :key="item.id">
            <td class="table-title-cell">
              <div class="cell-title">{{ item.orderNo }}</div>
              <div class="cell-sub">{{ formatPayStatus(item.payStatus) }}</div>
            </td>
            <td class="table-source-cell">
              <div class="cell-title">{{ formatOrderSource(item.orderSource) }}</div>
              <div class="cell-sub" v-if="item.sourceSceneSummary">{{ item.sourceSceneSummary }}</div>
            </td>
            <td class="table-id-cell">{{ item.userId }}</td>
            <td class="table-title-cell">
              <div class="cell-title">{{ item.receiverName || '-' }}</div>
              <div class="cell-sub">{{ item.receiverPhone || '未填写电话' }}</div>
            </td>
            <td class="table-amount-cell">¥{{ item.actualAmount }}</td>
            <td class="table-status-cell">
              <span :class="['status-pill', statusClass(item.status)]">
                {{ formatStatus(item.status) }}
              </span>
            </td>
            <td class="table-time-cell">{{ item.createTime }}</td>
            <td class="table-actions-cell">
              <div class="table-actions">
                <button class="link-btn" @click="viewDetail(item.id)">详情</button>
                <button v-for="action in getOrderActions(item)" :key="`${item.id}-${action.label}`" class="link-btn" @click="updateStatus(item, action)">
                  {{ action.label }}
                </button>
              </div>
            </td>
          </tr>
          <tr v-if="!displayOrders.length">
            <td colspan="8" class="empty-cell">暂无订单数据</td>
          </tr>
        </tbody>
        </table>
      </template>
    </div>

    <div class="modal-mask" v-if="detailOrder" @click="closeDetail">
      <div class="modal-card" @click.stop>
        <div class="section-head">
          <div>
            <h2 class="section-title">订单详情</h2>
            <p class="section-desc">订单号：{{ detailOrder.orderNo }}</p>
          </div>
          <button class="ghost-btn" @click="closeDetail">关闭</button>
        </div>

        <div class="detail-box detail-grid">
          <div class="detail-item">
            <span class="detail-label">用户ID</span>
            <strong class="detail-value">{{ detailOrder.userId }}</strong>
          </div>
          <div class="detail-item">
            <span class="detail-label">订单状态</span>
            <strong class="detail-value">{{ formatStatus(detailOrder.status) }}</strong>
          </div>
          <div class="detail-item">
            <span class="detail-label">支付状态</span>
            <strong class="detail-value">{{ formatPayStatus(detailOrder.payStatus) }}</strong>
          </div>
          <div class="detail-item">
            <span class="detail-label">订单来源</span>
            <strong class="detail-value">{{ formatOrderSource(detailOrder.orderSource) }}</strong>
          </div>
          <div class="detail-item">
            <span class="detail-label">实付金额</span>
            <strong class="detail-value">¥{{ detailOrder.actualAmount }}</strong>
          </div>
          <div class="detail-item">
            <span class="detail-label">收货人</span>
            <strong class="detail-value">{{ detailOrder.receiverName || '-' }}</strong>
          </div>
          <div class="detail-item">
            <span class="detail-label">联系电话</span>
            <strong class="detail-value">{{ detailOrder.receiverPhone || '-' }}</strong>
          </div>
          <div class="detail-item detail-wide">
            <span class="detail-label">收货地址</span>
            <strong class="detail-value detail-text">{{ detailOrder.receiverAddress || '-' }}</strong>
          </div>
          <div class="detail-item detail-wide">
            <span class="detail-label">订单备注</span>
            <strong class="detail-value detail-text">{{ detailOrder.remark || '无' }}</strong>
          </div>
        </div>

        <div class="toolbar" v-if="getOrderActions(detailOrder).length">
          <button v-for="action in getOrderActions(detailOrder)" :key="action.label" class="primary-btn" @click="updateStatus(detailOrder, action)">
            {{ action.label }}
          </button>
        </div>

        <table class="data-table">
          <thead>
            <tr>
              <th>商品</th>
              <th>来源</th>
              <th>数量</th>
              <th>单价</th>
              <th>小计</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in detailItems" :key="item.id">
              <td class="table-title-cell">{{ item.goodsName }}</td>
              <td class="table-note-cell">{{ formatOrderSource(item.sourceType) }}{{ item.sourceScene ? ` · ${decodeSourceScene(item.sourceScene)}` : '' }}</td>
              <td class="table-id-cell">{{ item.quantity }}</td>
              <td class="table-amount-cell">¥{{ item.price }}</td>
              <td class="table-amount-cell">¥{{ item.totalPrice }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed, onMounted, onUnmounted, ref, watch } from 'vue';
import { http } from '../services/http';

const loading = ref(false);
const error = ref('');
const successMessage = ref('');
const orderNoKeyword = ref('');
const userId = ref('');
const status = ref('');
const orderList = ref([]);
const detailOrder = ref(null);
const detailItems = ref([]);

const statusMap = {
  0: '待付款',
  1: '待发货',
  2: '待收货',
  3: '已完成',
  4: '已取消',
  5: '已退款',
  6: '退款中',
  7: '售后待审核'
};

function formatStatus(value) {
  return statusMap[value] || `状态${value}`;
}

function formatPayStatus(value) {
  if (value === 2) return '已支付';
  if (value === 1) return '待确认支付';
  return '未支付';
}

function formatOrderSource(value) {
  if (value === 'MEAL') return '小份优选';
  if (value === 'COMBO') return '场景搭配';
  if (value === 'SEASONAL') return '当季精选';
  if (value === 'MIXED') return '混合来源';
  return '普通商品';
}

function buildSourceSceneSummary(order = {}) {
  const items = Array.isArray(order.items) ? order.items : [];
  const sceneSet = new Set();
  items.forEach((item) => {
    const scene = decodeSourceScene(item && item.sourceScene);
    if (scene) {
      sceneSet.add(scene);
      return;
    }
    const type = formatOrderSource(item && item.sourceType);
    if (type && type !== '普通商品') {
      sceneSet.add(type);
    }
  });
  return Array.from(sceneSet).slice(0, 2).join(' / ');
}

function decodeSourceScene(value) {
  const text = String(value || '').trim();
  if (!text) return '';
  try {
    return decodeURIComponent(text);
  } catch (error) {
    return text;
  }
}

function statusClass(value) {
  if (value === 3) return 'status-active';
  if (value === 1 || value === 2 || value === 6 || value === 7) return 'status-warn';
  return 'status-off';
}

function getOrderActions(order = {}) {
  const status = Number(order.status);
  if (status === 1) {
    return [{ label: '标记发货', nextStatus: 2, successText: '订单已标记为待收货' }];
  }
  if (status === 7) {
    return [
      { label: '同意售后', nextStatus: 6, successText: '已同意售后，订单进入退款中' },
      { label: '拒绝售后', nextStatus: order.finishTime ? 3 : 1, successText: '已拒绝售后申请' }
    ];
  }
  return [];
}

const displayOrders = computed(() => {
  const keyword = orderNoKeyword.value.trim();
  if (!keyword) {
    return orderList.value;
  }
  return orderList.value.filter((item) => String(item.orderNo || '').includes(keyword));
});

function countByStatus(targetStatus) {
  return displayOrders.value.filter((item) => Number(item.status) === targetStatus).length;
}

async function loadOrders() {
  loading.value = true;
  error.value = '';
  successMessage.value = '';
  try {
    const res = await http.get('/order/list', {
      params: {
        status: status.value === '' ? undefined : Number(status.value),
        userId: userId.value === '' ? undefined : Number(userId.value)
      }
    });
    orderList.value = (res.data || []).map((item) => ({
      ...item,
      sourceSceneSummary: buildSourceSceneSummary(item)
    }));
  } catch (err) {
    error.value = err.message;
  } finally {
    loading.value = false;
  }
}

async function viewDetail(orderId) {
  try {
    const res = await http.get('/order/detail', {
      params: { orderId }
    });
    detailOrder.value = (res.data && res.data.order) || null;
    detailItems.value = (res.data && res.data.items) || [];
  } catch (err) {
    error.value = err.message;
  }
}

function closeDetail() {
  detailOrder.value = null;
  detailItems.value = [];
}

function onEscClose(event) {
  if (event && event.key === 'Escape' && detailOrder.value) {
    closeDetail();
  }
}

watch(detailOrder, (value) => {
  document.body.style.overflow = value ? 'hidden' : '';
});

async function updateStatus(order, action) {
  if (!action || action.nextStatus == null) return;
  try {
    await http.post('/order/status', null, {
      params: {
        orderId: order.id,
        status: action.nextStatus
      }
    });
    const successText = action.successText || '订单状态已更新';
    if (detailOrder.value && detailOrder.value.id === order.id) {
      await viewDetail(order.id);
    }
    await loadOrders();
    successMessage.value = successText;
  } catch (err) {
    error.value = err.message;
  }
}

onMounted(() => {
  loadOrders();
  window.addEventListener('keydown', onEscClose);
});

onUnmounted(() => {
  document.body.style.overflow = '';
  window.removeEventListener('keydown', onEscClose);
});
</script>
