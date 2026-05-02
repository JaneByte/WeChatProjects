const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    notifyOrder: true,
    notifyPromo: false,
    loading: false,
    submitting: false
  },

  onShow() {
    this.loadSettings();
  },

  loadSettings() {
    const userId = app.getUserId();
    if (!userId) return;
    this.setData({ loading: true });
    get('/settings/detail', { userId }, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        this.setData({
          notifyOrder: !!data.notifyOrder,
          notifyPromo: !!data.notifyPromo
        });
      })
      .catch((error) => showRequestError(error, '设置加载失败'))
      .finally(() => this.setData({ loading: false }));
  },

  onToggleOrder(e) {
    this.saveSettings(!!e.detail.value, this.data.notifyPromo);
  },

  onTogglePromo(e) {
    this.saveSettings(this.data.notifyOrder, !!e.detail.value);
  },

  saveSettings(notifyOrder, notifyPromo) {
    const userId = app.getUserId();
    if (!userId || this.data.submitting) return;

    this.setData({ submitting: true });
    post('/settings/save', { userId, notifyOrder, notifyPromo }, { retry: 0 })
      .then(() => {
        this.setData({ notifyOrder, notifyPromo });
      })
      .catch((error) => showRequestError(error, '设置保存失败'))
      .finally(() => this.setData({ submitting: false }));
  },

  onClearTestData() {
    const userId = app.getUserId();
    if (!userId || this.data.submitting) return;
    wx.showModal({
      title: '确认清理',
      content: '将清理当前用户测试数据（订单/购物车/地址），是否继续？',
      success: (res) => {
        if (!res.confirm) return;
        this.setData({ submitting: true });
        post(`/order/dev/clear-my-test-data?userId=${userId}`, {}, { retry: 0 })
          .then(() => {
            wx.showToast({ title: '清理成功', icon: 'success' });
          })
          .catch((error) => showRequestError(error, '清理失败'))
          .finally(() => this.setData({ submitting: false }));
      }
    });
  },

  onGrantTestCoupons() {
    if (this.data.submitting) return;
    wx.showModal({
      title: '确认发放',
      content: '给所有用户发放默认测试优惠券，是否继续？',
      success: (res) => {
        if (!res.confirm) return;
        this.setData({ submitting: true });
        post('/coupon/dev/grant-default', {}, { retry: 0 })
          .then((resData) => {
            const data = (resData && resData.data) || {};
            wx.showToast({
              title: `发放${data.grantedCount || 0}张`,
              icon: 'success'
            });
          })
          .catch((error) => showRequestError(error, '发放失败'))
          .finally(() => this.setData({ submitting: false }));
      }
    });
  }
});
