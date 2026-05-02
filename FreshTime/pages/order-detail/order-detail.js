const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

const ORDER_EXPIRE_MINUTES = 30;
const ORDER_EXPIRE_MS = ORDER_EXPIRE_MINUTES * 60 * 1000;

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
  const ts = new Date(String(createTime).replace(/-/g, '/')).getTime();
  if (Number.isNaN(ts)) return 0;
  const remainMs = ts + ORDER_EXPIRE_MS - Date.now();
  return Math.max(0, Math.floor(remainMs / 1000));
}

Page({
  data: {
    id: null,
    detail: null,
    loading: false,
    goodsCount: 0,
    goodsAmount: 0,
    remainSeconds: 0,
    countdownText: '00:00:00',
    actionLoading: false
  },

  onLoad(options) {
    const id = Number(options.id || 0);
    this.setData({ id });
    this.loadDetail();
  },

  onShow() {
    this.loadDetail();
    this.startCountdownTicker();
  },

  onHide() {
    this.stopCountdownTicker();
  },

  onUnload() {
    this.stopCountdownTicker();
  },

  startCountdownTicker() {
    this.stopCountdownTicker();
    this.countdownTimer = setInterval(() => {
      if (Number(this.data.detail && this.data.detail.status) !== 0) return;
      const next = Math.max(0, Number(this.data.remainSeconds || 0) - 1);
      this.setData({ remainSeconds: next, countdownText: formatCountdown(next) });
    }, 1000);
  },

  stopCountdownTicker() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  },

  loadDetail() {
    const userId = app.getUserId();
    if (!userId || !this.data.id) return;

    this.setData({ loading: true });
    get('/order/detail', { userId, orderId: this.data.id }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || null;
        const items = (detail && detail.items) || [];
        const goodsCount = items.reduce((sum, item) => sum + Number(item.quantity || 0), 0);
        const goodsAmount = items.reduce((sum, item) => {
          const total = Number(item.totalPrice || 0);
          if (total > 0) return sum + total;
          return sum + Number(item.price || 0) * Number(item.quantity || 0);
        }, 0);
        const remainSeconds = Number(detail && detail.status) === 0 ? calcRemainSeconds(detail.createTime) : 0;
        this.setData({
          detail,
          goodsCount,
          goodsAmount: Math.round(goodsAmount * 100) / 100,
          remainSeconds,
          countdownText: formatCountdown(remainSeconds)
        });
      })
      .catch((error) => showRequestError(error, '订单详情加载失败'))
      .finally(() => this.setData({ loading: false }));
  },

  executeAction(actionFn, successText, failText) {
    if (this.data.actionLoading) return;
    this.setData({ actionLoading: true });
    actionFn()
      .then(() => {
        wx.showToast({ title: successText, icon: 'success' });
        this.loadDetail();
      })
      .catch((error) => showRequestError(error, failText))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onPay() {
    const userId = app.getUserId();
    if (!userId || !this.data.detail) return;
    if (this.data.actionLoading) return;
    this.setData({ actionLoading: true });
    post(`/order/pay?userId=${userId}&orderId=${this.data.detail.id}`, {}, { retry: 0 })
      .then(() => {
        wx.redirectTo({ url: `/pages/pay-result/pay-result?result=success&orderId=${this.data.detail.id}` });
      })
      .catch((error) => showRequestError(error, '支付失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onCancel() {
    const userId = app.getUserId();
    if (!userId || !this.data.detail) return;
    this.executeAction(
      () => post(`/order/cancel?userId=${userId}&orderId=${this.data.detail.id}`, {}, { retry: 0 }),
      '取消成功',
      '取消失败'
    );
  },

  onFinish() {
    const userId = app.getUserId();
    if (!userId || !this.data.detail) return;
    this.executeAction(
      () => post(`/order/finish?userId=${userId}&orderId=${this.data.detail.id}`, {}, { retry: 0 }),
      '确认收货成功',
      '确认收货失败'
    );
  },

  onGoComment(e) {
    const goodsId = Number(e.currentTarget.dataset.goodsId || 0);
    const goodsName = e.currentTarget.dataset.goodsName || '';
    const orderId = Number(this.data.detail && this.data.detail.id);
    if (!orderId || !goodsId) {
      wx.showToast({ title: '评价参数错误', icon: 'none' });
      return;
    }
    wx.navigateTo({
      url: `/pages/comment-edit/comment-edit?orderId=${orderId}&goodsId=${goodsId}&goodsName=${encodeURIComponent(goodsName)}`
    });
  }
});
