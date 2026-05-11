const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    list: [],
    availableList: [],
    loading: false,
    loadError: false,
    claimLoadingId: 0
  },

  onShow() {
    this.loadData();
  },

  loadData() {
    this.loadList();
    this.loadAvailableList();
  },

  loadList() {
    const userId = app.getUserId();
    if (!userId) {
      this.setData({ list: [] });
      return;
    }
    this.setData({ loading: true });
    get('/coupon/list', { userId }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ list: Array.isArray(list) ? list : [], loadError: false });
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '优惠券加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  loadAvailableList() {
    const userId = app.getUserId();
    if (!userId) {
      this.setData({ availableList: [] });
      return;
    }
    get('/coupon/available', { userId }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ availableList: Array.isArray(list) ? list : [] });
      })
      .catch(() => this.setData({ availableList: [] }));
  },

  onClaimTap(e) {
    const couponId = Number(e.currentTarget.dataset.id || 0);
    if (!couponId || this.data.claimLoadingId) return;
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }
    this.setData({ claimLoadingId: couponId });
    post('/coupon/claim', { userId, couponId }, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '领取成功', icon: 'success' });
        this.loadData();
      })
      .catch((error) => showRequestError(error, '领取失败'))
      .finally(() => this.setData({ claimLoadingId: 0 }));
  },

  onUseTap() {
    wx.navigateTo({ url: '/pages/goods/goods?type=weeklyHot' });
  }
});
