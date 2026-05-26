const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const { runMockPayFlow } = require('../../utils/mock-pay');
const app = getApp();
const AFTER_SALE_DAYS = 7;
const AFTER_SALE_MS = AFTER_SALE_DAYS * 24 * 60 * 60 * 1000;

Page({
  data: {
    id: null,
    detail: null,
    loading: false,
    goodsCount: 0,
    goodsAmount: 0,
    remainSeconds: 0,
    countdownText: '00:00:00',
    actionLoading: false,
    canAfterSale: false
  },

  onLoad(options) {
    this.pageActive = true;
    const id = Number(options.id || 0);
    this.setData({ id });
    if (!app.getUserId()) {
      app.requireLogin({ redirect: `/pages/order-detail/order-detail?id=${id}`, silent: true }).catch(() => {});
      return;
    }
    this.loadDetail();
  },

  onShow() {
    this.pageActive = true;
    this.loadDetail();
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
      if (Number(this.data.detail && this.data.detail.status) !== 0) return;
      const next = Math.max(0, Number(this.data.remainSeconds || 0) - 1);
      this.setData({ remainSeconds: next, countdownText: this.formatCountdown(next) });
    }, 1000);
  },

  stopCountdownTicker() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  },

  formatCountdown(seconds) {
    const safe = Math.max(0, Number(seconds || 0));
    const h = Math.floor(safe / 3600);
    const m = Math.floor((safe % 3600) / 60);
    const s = safe % 60;
    const pad = (n) => (n < 10 ? `0${n}` : `${n}`);
    return `${pad(h)}:${pad(m)}:${pad(s)}`;
  },

  parseDateTime(value) {
    if (!value) return NaN;
    const normalized = String(value)
      .replace('T', ' ')
      .replace(/\.\d+/, '')
      .replace(/-/g, '/');
    return new Date(normalized).getTime();
  },

  calcRemainSeconds(createTime) {
    if (!createTime) return 0;
    const ts = this.parseDateTime(createTime);
    if (Number.isNaN(ts)) return 0;
    const remainMs = ts + 30 * 60 * 1000 - Date.now();
    return Math.max(0, Math.floor(remainMs / 1000));
  },

  canAfterSale(detail = {}) {
    if (Number(detail.status) !== 3 || !detail.finishTime) return false;
    const ts = this.parseDateTime(detail.finishTime);
    if (Number.isNaN(ts)) return false;
    return (Date.now() - ts) <= AFTER_SALE_MS;
  },

  loadDetail() {
    if (!app.getUserId()) {
      app.requireLogin({ redirect: `/pages/order-detail/order-detail?id=${this.data.id}`, silent: true }).catch(() => {});
      return;
    }
    if (!this.data.id) return;

    this.setData({ loading: true });
    get('/order/detail', { orderId: this.data.id }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || null;
        const items = (detail && detail.items) || [];
        const goodsCount = items.reduce((sum, item) => sum + Number(item.quantity || 0), 0);
        const goodsAmount = items.reduce((sum, item) => {
          const total = Number(item.totalPrice || 0);
          if (total > 0) return sum + total;
          return sum + Number(item.price || 0) * Number(item.quantity || 0);
        }, 0);
        const remainSeconds = Number(detail && detail.status) === 0 ? this.calcRemainSeconds(detail.createTime) : 0;
        this.setData({
          detail,
          goodsCount,
          goodsAmount: Math.round(goodsAmount * 100) / 100,
          remainSeconds,
          countdownText: this.formatCountdown(remainSeconds),
          canAfterSale: this.canAfterSale(detail)
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
    if (!app.getUserId() || !this.data.detail || this.data.actionLoading) return;
    this.setData({ actionLoading: true });
    runMockPayFlow({
      orderId: this.data.detail.id,
      orderNo: this.data.detail.orderNo,
      actualAmount: this.data.detail.actualAmount
    })
      .then(() => {
        wx.redirectTo({
          url: `/pages/pay-result/pay-result?result=success&orderId=${this.data.detail.id}`
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

  onCancel() {
    if (!app.getUserId() || !this.data.detail) return;
    this.executeAction(
      () => post(`/order/cancel?orderId=${this.data.detail.id}`, {}, { retry: 0 }),
      '取消成功',
      '取消失败'
    );
  },

  onFinish() {
    if (!app.getUserId() || !this.data.detail) return;
    this.executeAction(
      () => post(`/order/finish?orderId=${this.data.detail.id}`, {}, { retry: 0 }),
      '确认收货成功',
      '确认收货失败'
    );
  },

  onRefund() {
    if (!app.getUserId() || !this.data.detail) return;
    const isAfterSale = Number(this.data.detail.status) === 3;
    this.executeAction(
      () => post(`/order/refund/apply?orderId=${this.data.detail.id}`, {}, { retry: 0 }),
      isAfterSale ? '售后申请已提交' : '退款申请已提交',
      isAfterSale ? '售后申请失败' : '退款申请失败'
    );
  },

  onRefundFinish() {
    if (!app.getUserId() || !this.data.detail) return;
    wx.showModal({
      title: '确认退款',
      content: '请确认你已收到该订单退款，确认后订单将变更为“已退款”。',
      confirmText: '确认',
      cancelText: '取消',
      success: (res) => {
        if (!res.confirm) return;
        this.executeAction(
          () => post(`/order/refund/finish?orderId=${this.data.detail.id}`, {}, { retry: 0 }),
          '已确认退款成功',
          '确认退款失败'
        );
      }
    });
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
  },

  onViewComment(e) {
    const commentId = Number(e.currentTarget.dataset.commentId || 0);
    if (!commentId) {
      wx.showToast({ title: '评价参数错误', icon: 'none' });
      return;
    }
    wx.navigateTo({ url: `/pages/comment-detail/comment-detail?commentId=${commentId}` });
  }
});
