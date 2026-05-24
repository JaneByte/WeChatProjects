const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    notifyOrder: true,
    notifyPromo: false,
    loading: false,
    submitting: false,
    accountSummary: '未登录'
  },

  onLoad() {},

  onShow() {
    this.refreshAccountSummary();
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/settings/settings', silent: true }).catch(() => {});
      return;
    }
    this.loadSettings();
  },

  refreshAccountSummary() {
    const profile = app.getLoginProfile() || {};
    const userId = app.getUserId();
    this.setData({
      accountSummary: userId ? `${profile.nickname || '微信用户'} · ID ${userId}` : '未登录'
    });
  },

  loadSettings() {
    if (!app.getUserId()) return;
    this.setData({ loading: true });
    get('/settings/detail', {}, { retry: 0 })
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
    if (!app.getUserId() || this.data.submitting) return;

    this.setData({ submitting: true });
    post('/settings/save', { notifyOrder, notifyPromo }, { retry: 0 })
      .then(() => {
        this.setData({ notifyOrder, notifyPromo });
        wx.showToast({ title: '设置已更新', icon: 'success', duration: 1000 });
      })
      .catch((error) => showRequestError(error, '设置保存失败'))
      .finally(() => this.setData({ submitting: false }));
  },

  onLogout() {
    if (this.data.submitting) return;
    wx.showModal({
      title: '退出登录',
      content: '退出后将清空当前本地登录状态，是否继续？',
      success: (res) => {
        if (!res.confirm) return;
        app.markManualLogout(true);
        app.clearLoginState();
        this.refreshAccountSummary();
        wx.showToast({ title: '已退出登录', icon: 'success', duration: 1200 });
        setTimeout(() => {
          wx.switchTab({ url: '/pages/index/index' });
        }, 400);
      }
    });
  }
});
