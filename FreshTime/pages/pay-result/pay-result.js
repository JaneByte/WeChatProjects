Page({
  data: {
    success: true,
    message: '订单支付已完成，可前往订单列表查看状态',
    orderId: null,
    payTradeNo: '',
    payChannel: ''
  },

  onLoad(options) {
    const success = options.result !== 'fail';
    const orderId = Number(options.orderId || 0) || null;
    const payTradeNo = options.payTradeNo ? decodeURIComponent(options.payTradeNo) : '';
    const payChannel = options.payChannel ? decodeURIComponent(options.payChannel) : '';
    const message = success
      ? '订单支付已完成，可前往订单列表查看状态'
      : '支付未完成，请返回订单页重试';
    this.setData({ success, message, orderId, payTradeNo, payChannel });
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
