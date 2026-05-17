const app = getApp();
const { showRequestError } = require('../../utils/ui.js');

Page({
  data: {
    loading: false,
    redirect: ''
  },

  onLoad(options) {
    this.setData({
      redirect: options && options.redirect ? decodeURIComponent(options.redirect) : ''
    });
  },

  onShow() {
    if (app.getUserId() && app.getToken()) {
      this.finishLogin();
    }
  },

  ensureNotBusy() {
    if (this.data.loading || app.isLoggingIn()) return false;
    return true;
  },

  onWechatLogin() {
    if (!this.ensureNotBusy()) return;
    this.setData({ loading: true });

    app.loginByCode()
      .then(() => app.refreshCartBadgeFromServer())
      .then(() => {
        wx.showToast({ title: '登录成功', icon: 'success', duration: 1200 });
        this.finishLogin();
      })
      .catch((error) => {
        showRequestError(error, '微信登录失败');
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  finishLogin() {
    const { redirect } = this.data;
    const profile = app.getLoginProfile() || {};
    const profileTabPages = [
      '/pages/index/index',
      '/pages/category/category',
      '/pages/cart/cart',
      '/pages/profile/profile'
    ];

    if (app.isDefaultProfile(profile)) {
      const query = redirect ? `?mode=onboarding&redirect=${encodeURIComponent(redirect)}` : '?mode=onboarding';
      wx.redirectTo({
        url: `/pages/profile-edit/profile-edit${query}`,
        fail: () => wx.switchTab({ url: '/pages/profile/profile' })
      });
      return;
    }

    if (redirect) {
      if (profileTabPages.includes(redirect)) {
        wx.switchTab({ url: redirect });
        return;
      }
      wx.redirectTo({
        url: redirect,
        fail: () => wx.navigateBack({ delta: 1, fail: () => {} })
      });
      return;
    }
    wx.navigateBack({ delta: 1, fail: () => wx.switchTab({ url: '/pages/profile/profile' }) });
  }
});
