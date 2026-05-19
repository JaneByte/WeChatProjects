const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const { runMockPayFlow } = require('../../utils/mock-pay');
const app = getApp();

const ORDER_EXPIRE_MINUTES = 30;
const ORDER_EXPIRE_MS = ORDER_EXPIRE_MINUTES * 60 * 1000;
const AFTER_SALE_DAYS = 7;
const AFTER_SALE_MS = AFTER_SALE_DAYS * 24 * 60 * 60 * 1000;

function formatCountdown(seconds) {
  const safe = Math.max(0, Number(seconds || 0));
  const h = Math.floor(safe / 3600);
  const m = Math.floor((safe % 3600) / 60);
  const s = safe % 60;
  const pad = (n) => (n < 10 ? `0${n}` : `${n}`);
  return `${pad(h)}:${pad(m)}:${pad(s)}`;
}

function calcRemainSeconds(createTime) {
  if (!createTime) return 0;
  const normalized = String(createTime)
    .replace('T', ' ')
    .replace(/\.\d+/, '')
    .replace(/-/g, '/');
  const ts = new Date(normalized).getTime();
  if (Number.isNaN(ts)) return 0;
  const remainMs = ts + ORDER_EXPIRE_MS - Date.now();
  return Math.max(0, Math.floor(remainMs / 1000));
}

function parseDateTime(value) {
  if (!value) return NaN;
  const normalized = String(value)
    .replace('T', ' ')
    .replace(/\.\d+/, '')
    .replace(/-/g, '/');
  return new Date(normalized).getTime();
}

function canAfterSale(item = {}) {
  if (Number(item.status) === 1) return true;
  if (Number(item.status) !== 3 || !item.finishTime) return false;
  const ts = parseDateTime(item.finishTime);
  if (Number.isNaN(ts)) return false;
  return (Date.now() - ts) <= AFTER_SALE_MS;
}

Page({
  data: {
    list: [],
    loading: false,
    status: '',
    loadError: false,
    actionLoading: false,
    tabs: [
      { label: '全部', value: '' },
      { label: '待付款', value: '0' },
      { label: '待发货', value: '1' },
      { label: '待收货', value: '2' },
      { label: '售后审核', value: '7' },
      { label: '退款中', value: '6' },
      { label: '已退款', value: '5' },
      { label: '已完成', value: '3' },
      { label: '已取消', value: '4' }
    ]
  },

  onLoad(options) {
    this.pageActive = true;
    const status = options.status || '';
    this.setData({ status: `${status}` });
  },

  onShow() {
    this.pageActive = true;
    this.loadList();
    this.startCountdownTicker();
  },

  onHide() {
    this.pageActive = false;
    this.stopCountdownTicker();
  },

  onUnload() {
    this.pageActive = false;
    this.stopCountdownTicker();
  },

  startCountdownTicker() {
    this.stopCountdownTicker();
    this.countdownTimer = setInterval(() => {
      if (!this.pageActive) return;
      const next = (this.data.list || []).map((item) => {
        if (Number(item.status) !== 0) return item;
        const remainSeconds = Math.max(0, Number(item.remainSeconds || 0) - 1);
        return {
          ...item,
          remainSeconds,
          countdownText: formatCountdown(remainSeconds)
        };
      });
      this.setData({ list: next });
    }, 1000);
  },

  stopCountdownTicker() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  },

  onChangeTab(e) {
    const { status } = e.currentTarget.dataset;
    this.setData({ status: `${status}` }, () => this.loadList());
  },

  normalizeList(list) {
    return (Array.isArray(list) ? list : []).map((item) => {
      const remainSeconds = Number(item.status) === 0 ? calcRemainSeconds(item.createTime) : 0;
      return {
        ...item,
        remainSeconds,
        countdownText: formatCountdown(remainSeconds),
        canAfterSale: canAfterSale(item)
      };
    });
  },

  loadList() {
    if (!app.getUserId()) {
      this.setData({ list: [] });
      app.requireLogin({ redirect: `/pages/order-list/order-list?status=${encodeURIComponent(this.data.status)}`, silent: true }).catch(() => {});
      return;
    }

    const params = { limit: 50 };
    const isAfterSaleTab = this.data.status === 'afterSale';
    if (!isAfterSaleTab && this.data.status !== '') params.status = Number(this.data.status);

    this.setData({ loading: true });
    get('/order/list', params, { retry: 0 })
      .then((res) => {
        let sourceList = (res && res.data) || [];
        if (isAfterSaleTab) {
          sourceList = (Array.isArray(sourceList) ? sourceList : []).filter((item) => {
            const status = Number(item.status);
            return status === 6 || status === 5;
          });
        }
        const list = this.normalizeList(sourceList);
        this.setData({ list, loadError: false });
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '订单加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onRetryLoad() {
    this.loadList();
  },

  onTapItem(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    wx.navigateTo({ url: `/pages/order-detail/order-detail?id=${id}` });
  },

  executeAction(actionFn, successText, failText) {
    if (this.data.actionLoading) return;
    this.setData({ actionLoading: true });
    actionFn()
      .then(() => {
        wx.showToast({ title: successText, icon: 'success' });
        this.loadList();
      })
      .catch((error) => showRequestError(error, failText))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onPay(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !app.getUserId()) return;
    if (this.data.actionLoading) return;
    this.setData({ actionLoading: true });
    runMockPayFlow({ orderId: id })
      .then(() => {
        wx.redirectTo({
          url: `/pages/pay-result/pay-result?result=success&orderId=${id}`
        });
      })
      .catch((error) => {
        if (error && error.code === 'PAY_CANCELLED') {
          wx.showToast({ title: '你已取消支付', icon: 'none' });
          return;
        }
        showRequestError(error, '支付失败');
      })
      .finally(() => this.setData({ actionLoading: false }));
  },

  onCancel(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !app.getUserId()) return;
    this.executeAction(
      () => post(`/order/cancel?orderId=${id}`, {}, { retry: 0 }),
      '取消成功',
      '取消失败'
    );
  },

  onFinish(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !app.getUserId()) return;
    this.executeAction(
      () => post(`/order/finish?orderId=${id}`, {}, { retry: 0 }),
      '确认收货成功',
      '确认收货失败'
    );
  },

  onRefund(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !app.getUserId()) return;
    const current = (this.data.list || []).find((item) => Number(item.id) === id) || {};
    const isAfterSale = Number(current.status) === 3;
    this.executeAction(
      () => post(`/order/refund/apply?orderId=${id}`, {}, { retry: 0 }),
      isAfterSale ? '售后申请已提交' : '退款申请已提交',
      isAfterSale ? '售后申请失败' : '退款申请失败'
    );
  },

  onRefundFinish(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !app.getUserId()) return;
    wx.showModal({
      title: '确认退款',
      content: '请确认你已收到该订单退款，确认后订单将变更为“已退款”。',
      confirmText: '确认',
      cancelText: '取消',
      success: (res) => {
        if (!res.confirm) return;
        this.executeAction(
          () => post(`/order/refund/finish?orderId=${id}`, {}, { retry: 0 }),
          '已确认退款成功',
          '确认退款失败'
        );
      }
    });
  }
});
