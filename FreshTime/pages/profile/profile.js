const { get, post } = require('../../utils/request.js');
const { showRequestError } = require('../../utils/ui.js');

const app = getApp();

Page({
  data: {
    userInfo: {
      nickname: '新鲜生活家',
      level: '普通会员',
      avatar: '/assets/icon/my.png'
    },
    orderTabs: [
      { key: 'pendingPay', label: '待付款', mark: '付' },
      { key: 'pendingShip', label: '待发货', mark: '发' },
      { key: 'pendingReceive', label: '待收货', mark: '收' },
      { key: 'afterSale', label: '售后', mark: '售' }
    ],
    menuList: [
      { key: 'address', label: '收货地址', desc: '管理常用地址' },
      { key: 'coupon', label: '优惠券', desc: '查看可用优惠' },
      { key: 'service', label: '在线客服', desc: '问题咨询与反馈' },
      { key: 'settings', label: '设置', desc: '账号与通知配置' }
    ],
    activeOrderTab: '',
    currentOrderStatus: null,
    currentUserIdText: '登录中...',
    orderList: [],
    orderTotal: 0,
    submittingOrderAction: false
  },

  onShow() {
    app.ensureLoginReady()
      .then(() => {
        this.refreshCurrentUserText();
        this.loadOrderSummary(this.data.currentOrderStatus);
      })
      .catch(() => {
        this.setData({ currentUserIdText: '登录失败', orderList: [], orderTotal: 0 });
      });
  },

  refreshCurrentUserText() {
    const userId = app.getUserId();
    this.setData({ currentUserIdText: userId ? `${userId}` : '未登录' });
  },

  getCurrentUserId() {
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none', duration: 1500 });
      return null;
    }
    return userId;
  },

  loadOrderSummary(status = null) {
    const userId = this.getCurrentUserId();
    if (!userId) {
      this.setData({ orderList: [], orderTotal: 0, currentOrderStatus: status });
      return;
    }

    const params = { userId, limit: 50 };
    if (status !== null && status !== undefined) params.status = status;

    get('/order/list', params, { retry: 0 })
      .then((res) => {
        const list = ((res && res.data) || []).map((item) => {
          const items = Array.isArray(item.items) ? item.items : [];
          const itemCount = items.reduce((sum, row) => sum + Number(row.quantity || 0), 0);
          return {
            ...item,
            itemCount
          };
        });
        this.setData({
          currentOrderStatus: status,
          orderList: Array.isArray(list) ? list : [],
          orderTotal: Array.isArray(list) ? list.length : 0
        });
      })
      .catch((error) => showRequestError(error, '订单加载失败'));
  },

  onOrderTap(e) {
    const { key } = e.currentTarget.dataset;
    const statusMap = { pendingPay: 0, pendingShip: 1, pendingReceive: 2, afterSale: 5 };
    const status = Object.prototype.hasOwnProperty.call(statusMap, key) ? statusMap[key] : null;
    this.setData({ activeOrderTab: key });
    wx.navigateTo({ url: `/pages/order-list/order-list?status=${status}` });
  },

  executeOrderAction(actionRequest, successText, errorText) {
    if (this.data.submittingOrderAction) return;
    this.setData({ submittingOrderAction: true });

    actionRequest()
      .then(() => {
        wx.showToast({ title: successText, icon: 'success', duration: 1200 });
        this.loadOrderSummary(this.data.currentOrderStatus);
      })
      .catch((error) => showRequestError(error, errorText))
      .finally(() => this.setData({ submittingOrderAction: false }));
  },

  onCancelOrder(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = this.getCurrentUserId();
    if (!userId) return;
    this.executeOrderAction(() => post(`/order/cancel?userId=${userId}&orderId=${id}`, {}, { retry: 0 }), '取消成功', '取消失败');
  },

  onFinishOrder(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = this.getCurrentUserId();
    if (!userId) return;
    this.executeOrderAction(() => post(`/order/finish?userId=${userId}&orderId=${id}`, {}, { retry: 0 }), '确认收货成功', '确认收货失败');
  },

  onPayOrder(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = this.getCurrentUserId();
    if (!userId) return;
    if (this.data.submittingOrderAction) return;
    this.setData({ submittingOrderAction: true });
    post(`/order/pay?userId=${userId}&orderId=${id}`, {}, { retry: 0 })
      .then(() => {
        wx.redirectTo({ url: `/pages/pay-result/pay-result?result=success&orderId=${id}` });
      })
      .catch((error) => showRequestError(error, '支付失败'))
      .finally(() => this.setData({ submittingOrderAction: false }));
  },

  onMenuTap(e) {
    const { key } = e.currentTarget.dataset;
    if (key === 'address') {
      wx.navigateTo({ url: '/pages/address-list/address-list' });
      return;
    }
    if (key === 'coupon') {
      wx.navigateTo({ url: '/pages/coupon/coupon' });
      return;
    }
    if (key === 'service') {
      wx.navigateTo({ url: '/pages/service/service' });
      return;
    }
    if (key === 'settings') {
      wx.navigateTo({ url: '/pages/settings/settings' });
      return;
    }
    wx.showToast({ title: '敬请期待', icon: 'none' });
  },

  onSwitchUserId() {
    app.bootstrapLogin()
      .then(() => {
        this.refreshCurrentUserText();
        wx.showToast({ title: '登录状态已刷新', icon: 'success', duration: 1200 });
        this.loadOrderSummary(this.data.currentOrderStatus);
      })
      .catch(() => {
        wx.showToast({ title: '登录中，请稍后重试', icon: 'none', duration: 1500 });
      });
  },

  onPullDownRefresh() {
    this.refreshCurrentUserText();
    this.loadOrderSummary(this.data.currentOrderStatus);
    wx.stopPullDownRefresh();
  }
});
