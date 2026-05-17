const { get } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');

Page({
  data: {
    commentId: 0,
    orderId: 0,
    detail: null,
    loading: false
  },

  onLoad(options) {
    const commentId = Number(options.commentId || 0);
    if (!commentId) {
      wx.showToast({ title: '评价参数错误', icon: 'none' });
      return;
    }
    this.setData({ commentId });
    this.loadDetail();
  },

  loadDetail() {
    this.setData({ loading: true });
    get('/comment/detail', { commentId: this.data.commentId }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || null;
        this.setData({
          detail,
          orderId: Number((detail && detail.orderId) || 0)
        });
      })
      .catch((error) => {
        this.setData({ detail: null });
        showRequestError(error, '评价详情加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onBackOrder() {
    const orderId = Number(this.data.orderId || 0);
    if (!orderId) {
      wx.navigateBack();
      return;
    }
    wx.navigateTo({ url: `/pages/order-detail/order-detail?id=${orderId}` });
  }
});
