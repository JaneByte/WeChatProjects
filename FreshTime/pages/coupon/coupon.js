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
  }
});
