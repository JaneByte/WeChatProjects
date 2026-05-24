const { get, post } = require('../../utils/request.js');
const { showRequestError } = require('../../utils/ui.js');
const { runMockPayFlow } = require('../../utils/mock-pay');
const app = getApp();

Page({
  data: {
    userInfo: {
      nickname: '微信快捷登录',
      avatar: '/assets/icon/my.png'
    },
    isLoggedIn: false,
    profileIncomplete: false,
    loginReady: false,
    orderTabs: [
      { key: 'pendingPay', label: '待付款', mark: '付' },
      { key: 'pendingShip', label: '待发货', mark: '发' },
      { key: 'pendingReceive', label: '待收货', mark: '收' },
      { key: 'afterSale', label: '售后', mark: '售' }
    ],
    menuList: [
      { key: 'profileEdit', label: '编辑资料', desc: '修改头像与昵称' },
      { key: 'address', label: '收货地址', desc: '管理常用地址' },
      { key: 'coupon', label: '优惠券', desc: '查看可用优惠' },
      { key: 'service', label: '在线客服', desc: '问题咨询与反馈' },
      { key: 'settings', label: '设置', desc: '账号与通知配置' }
    ],
    activeOrderTab: '',
    currentOrderStatus: null,
    currentUserIdText: '',
    orderList: [],
    orderTotal: 0,
    submittingOrderAction: false,
    loginPromptVisible: false
  },

  onShow() {
    this.setData({ loginReady: false });
    this.refreshUserProfile();
    this.refreshCurrentUserText();

    app.ensureLoginReady()
      .then((userId) => {
        this.setData({ loginReady: true });
        if (!userId) {
          this.setData({
            orderList: [],
            orderTotal: 0,
            activeOrderTab: '',
            currentOrderStatus: null,
            loginPromptVisible: true
          });
          return;
        }
        this.refreshUserProfile();
        this.refreshCurrentUserText();
        this.loadOrderSummary(this.data.currentOrderStatus);
      })
      .catch(() => {
        this.setData({ loginReady: true });
      });
  },

  async refreshUserProfile() {
    const profile = app.getLoginProfile() || {};
    const userId = app.getUserId();
    const isLoggedIn = !!(userId && app.getToken());
    const nickname = profile.nickname || '微信快捷登录';
    const avatarFileId = profile.avatar || '/assets/icon/my.png';
    const avatar = await app.getResolvedAvatar(avatarFileId);
    
    this.setData({
      isLoggedIn,
      profileIncomplete: isLoggedIn && app.isDefaultProfile({ nickname, avatar: avatarFileId }),
      loginPromptVisible: !isLoggedIn,
      userInfo: {
        nickname,
        avatar
      }
    });
  },

  refreshCurrentUserText() {
    const userId = app.getUserId();
    this.setData({ currentUserIdText: userId ? `鲜时刻账号 ${userId}` : '' });
  },

  getCurrentUserId() {
    const userId = app.getUserId();
    if (!userId) {
      app.requireLogin({ redirect: '/pages/profile/profile' }).catch(() => {});
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
    const params = { limit: 50 };
    if (status !== null && status !== undefined) params.status = status;
    get('/order/list', params, { retry: 0 })
      .then((res) => {
        const fullList = ((res && res.data) || []).map((item) => {
          const items = Array.isArray(item.items) ? item.items : [];
          const itemCount = items.reduce((sum, row) => sum + Number(row.quantity || 0), 0);
          return {
            ...item,
            itemCount
          };
        });
        const list = Array.isArray(fullList) ? fullList.slice(0, 2) : [];
        this.setData({
          currentOrderStatus: status,
          orderList: list,
          orderTotal: Array.isArray(fullList) ? fullList.length : 0
        });
      })
      .catch((error) => showRequestError(error, '订单加载失败'));
  },

  onOrderTap(e) {
    if (!this.getCurrentUserId()) return;
    const { key } = e.currentTarget.dataset;
    const statusMap = { pendingPay: 0, pendingShip: 1, pendingReceive: 2, afterSale: 'afterSale' };
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
    if (!id || !this.getCurrentUserId()) return;
    this.executeOrderAction(() => post(`/order/cancel?orderId=${id}`, {}, { retry: 0 }), '取消成功', '取消失败');
  },

  onFinishOrder(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !this.getCurrentUserId()) return;
    this.executeOrderAction(() => post(`/order/finish?orderId=${id}`, {}, { retry: 0 }), '确认收货成功', '确认收货失败');
  },

  onPayOrder(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || !this.getCurrentUserId()) return;
    if (this.data.submittingOrderAction) return;
    const current = (this.data.orderList || []).find((item) => Number(item.id) === id) || {};
    this.setData({ submittingOrderAction: true });
    runMockPayFlow({
      orderId: id,
      orderNo: current.orderNo || '',
      actualAmount: Number(current.actualAmount || 0)
    })
      .then(() => {
        wx.redirectTo({ url: `/pages/pay-result/pay-result?result=success&orderId=${id}` });
      })
      .catch((error) => {
        if (error && error.code === 'PAY_CANCELLED') {
          wx.showToast({ title: '你已取消支付', icon: 'none' });
          return;
        }
        showRequestError(error, '支付失败');
      })
      .finally(() => this.setData({ submittingOrderAction: false }));
  },

  onMenuTap(e) {
    if (!this.getCurrentUserId()) return;
    const { key } = e.currentTarget.dataset;
    if (key === 'address') {
      wx.navigateTo({ url: '/pages/address-list/address-list' });
      return;
    }
    if (key === 'profileEdit') {
      wx.navigateTo({ url: '/pages/profile-edit/profile-edit' });
      return;
    }
    if (key === 'coupon') {
      wx.navigateTo({ url: '/pages/coupon-mine/coupon-mine' });
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

  onOpenLogin() {
    app.requireLogin({ redirect: '/pages/profile/profile', silent: true }).catch(() => {});
  },

  onOpenProfileEdit() {
    if (!this.getCurrentUserId()) return;
    wx.navigateTo({ url: '/pages/profile-edit/profile-edit' });
  },

  onCompleteProfile() {
    if (!this.getCurrentUserId()) return;
    wx.navigateTo({ url: '/pages/profile-edit/profile-edit?mode=onboarding&redirect=/pages/profile/profile' });
  },

  onSwitchUserId() {
    if (this.data.submittingOrderAction) return;
    this.setData({ submittingOrderAction: true });
    app.bootstrapLogin()
      .then(() => {
        this.refreshUserProfile();
        this.refreshCurrentUserText();
        wx.showToast({ title: '登录状态已刷新', icon: 'success', duration: 1200 });
        this.loadOrderSummary(this.data.currentOrderStatus);
      })
      .catch(() => {
        wx.showToast({ title: '登录中，请稍后重试', icon: 'none', duration: 1500 });
      })
      .finally(() => {
        this.setData({ submittingOrderAction: false });
      });
  },

  onPullDownRefresh() {
    this.refreshUserProfile();
    this.refreshCurrentUserText();
    if (app.isLoggedIn()) {
      this.loadOrderSummary(this.data.currentOrderStatus);
    } else {
      this.setData({
        orderList: [],
        orderTotal: 0,
        activeOrderTab: '',
        currentOrderStatus: null
      });
    }
    wx.stopPullDownRefresh();
  },
  onAvatarError() {
    this.setData({ 'userInfo.avatar': '/assets/icon/my.png' });
  }
});
