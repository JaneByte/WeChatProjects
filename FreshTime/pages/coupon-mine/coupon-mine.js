const { get } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    list: [],
    loading: false,
    loadError: false
  },

  onShow() {
    this.loadList();
  },

  loadList() {
    if (!app.getUserId()) {
      this.setData({ list: [] });
      app.requireLogin({ redirect: '/pages/coupon-mine/coupon-mine', silent: true }).catch(() => {});
      return;
    }
    this.setData({ loading: true });
    get('/coupon/list', {}, { retry: 0 })
      .then((res) => {
        const raw = Array.isArray((res && res.data) || []) ? res.data : [];
        const list = raw
          .filter((item) => Number(item.used || 0) === 0)
          .map((item) => {
            const expireAt = `${item.expireAt || ''}`.trim();
            const expireTs = this.parseExpireTime(expireAt);
            const remainDays = this.calcRemainDays(expireTs);
            const remainDaysText = this.buildRemainDaysText(remainDays);
            return {
              ...item,
              expireTs,
              remainDays,
              isNearExpire: remainDays >= 0 && remainDays <= 7,
              remainDaysText
            };
          })
          .sort((a, b) => Number(a.expireTs || 0) - Number(b.expireTs || 0));
        this.setData({ list, loadError: false });
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '优惠券加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onGoCouponCenter() {
    wx.navigateTo({ url: '/pages/coupon/coupon' });
  },

  onUseTap() {
    wx.navigateTo({ url: '/pages/goods/goods?type=weeklyHot' });
  },

  parseExpireTime(expireAt) {
    if (!expireAt) return Number.MAX_SAFE_INTEGER;
    const text = `${expireAt} 23:59:59`;
    const ts = new Date(text.replace(/-/g, '/')).getTime();
    if (Number.isNaN(ts)) return Number.MAX_SAFE_INTEGER;
    return ts;
  },

  calcRemainDays(expireTs) {
    if (!expireTs || expireTs === Number.MAX_SAFE_INTEGER) return -1;
    const diff = expireTs - Date.now();
    return Math.floor(diff / (24 * 60 * 60 * 1000));
  },

  buildRemainDaysText(remainDays) {
    if (!Number.isFinite(remainDays) || remainDays < 0) return '';
    if (remainDays === 0) return '今日到期';
    return `剩余${remainDays}天`;
  }
});
