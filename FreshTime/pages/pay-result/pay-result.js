const { get } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    success: false,
    loading: true,
    loadError: false,
    message: '正在同步订单状态...',
    orderId: null,
    orderNo: '',
    actualAmount: 0,
    payTime: '',
    payTradeNo: '',
    payChannel: ''
  },

  onLoad(options) {
    const orderId = Number(options.orderId || 0) || null;
    this.setData({ orderId }, () => this.loadOrderStatus());
  },

  loadOrderStatus() {
    const orderId = this.data.orderId;
    if (!app.getUserId() || !orderId) {
      this.setData({
        loading: false,
        loadError: true,
        success: false,
        message: '订单状态获取失败，请返回订单列表查看'
      });
      return;
    }

    this.setData({ loading: true, loadError: false });
    get('/order/detail', { orderId }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || {};
        const status = Number(detail.status);
        const payStatus = Number(detail.payStatus);
        const success = payStatus === 2 || status === 1 || status === 2 || status === 3 || status === 6 || status === 5;
        const message = success
          ? '订单支付已完成，可前往订单详情查看状态'
          : '支付未完成，请返回订单页重试';
        this.setData({
          success,
          message,
          orderNo: detail.orderNo || '',
          actualAmount: Number(detail.actualAmount || 0),
          payTime: detail.payTime || '',
          payTradeNo: detail.payTradeNo || '',
          payChannel: detail.payChannel || ''
        });
      })
      .catch((error) => {
        this.setData({
          success: false,
          loadError: true,
          message: '订单状态获取失败，请返回订单列表查看'
        });
        showRequestError(error, '订单状态获取失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  goOrderList() {
    const status = this.data.success ? 1 : 0;
    wx.redirectTo({ url: `/pages/order-list/order-list?status=${status}` });
  },

  goOrderDetail() {
    const { orderId } = this.data;
    if (!orderId) {
      this.goOrderList();
      return;
    }
    wx.redirectTo({ url: `/pages/order-detail/order-detail?id=${orderId}` });
  },

  goHome() {
    wx.switchTab({ url: '/pages/index/index' });
  }
});
