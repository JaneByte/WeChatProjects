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
      { label: '退款中', value: '6' },
      { label: '已退款', value: '5' },
      { label: '已完成', value: '3' },
      { label: '已取消', value: '4' }
    ]
  },

  onLoad(options) {
    const status = options.status || '';
    this.setData({ status: `${status}` });
  },

  onShow() {
    this.loadList();
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
        countdownText: formatCountdown(remainSeconds)
      };
    });
  },

  loadList() {
    const userId = app.getUserId();
    if (!userId) {
      this.setData({ list: [] });
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    const params = { userId, limit: 50 };
    if (this.data.status !== '') params.status = Number(this.data.status);

    this.setData({ loading: true });
    get('/order/list', params, { retry: 0 })
      .then((res) => {
        const list = this.normalizeList((res && res.data) || []);
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
    if (!id) return;
    const userId = app.getUserId();
    if (!userId) return;
    if (this.data.actionLoading) return;
    this.setData({ actionLoading: true });
    post(`/order/pay/mock-create?userId=${userId}&orderId=${id}`, {}, { retry: 0 })
      .then((payRes) => {
        const payData = (payRes && payRes.data) || {};
        return post('/order/pay/mock-confirm', {
          userId,
          orderId: id,
          payTradeNo: payData.payTradeNo
        }, { retry: 0 }).then((confirmRes) => {
          const confirmData = (confirmRes && confirmRes.data) || {};
          wx.redirectTo({
            url: `/pages/pay-result/pay-result?result=success&orderId=${id}&payTradeNo=${encodeURIComponent(confirmData.payTradeNo || '')}&payChannel=${encodeURIComponent(confirmData.payChannel || '')}`
          });
        });
      })
      .catch((error) => showRequestError(error, '支付失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onCancel(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = app.getUserId();
    if (!userId) return;
    this.executeAction(
      () => post(`/order/cancel?userId=${userId}&orderId=${id}`, {}, { retry: 0 }),
      '取消成功',
      '取消失败'
    );
  },

  onFinish(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = app.getUserId();
    if (!userId) return;
    this.executeAction(
      () => post(`/order/finish?userId=${userId}&orderId=${id}`, {}, { retry: 0 }),
      '确认收货成功',
      '确认收货失败'
    );
  },

  onRefund(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = app.getUserId();
    if (!userId) return;
    this.executeAction(
      () => post(`/order/refund/apply?userId=${userId}&orderId=${id}`, {}, { retry: 0 }),
      '退款申请已提交',
      '退款申请失败'
    );
  }
});
