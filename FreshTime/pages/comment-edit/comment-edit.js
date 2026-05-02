const { post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    orderId: null,
    goodsId: null,
    goodsName: '',
    rating: 5,
    stars: [1, 2, 3, 4, 5],
    content: '',
    submitting: false
  },

  onLoad(options) {
    const orderId = Number(options.orderId || 0);
    const goodsId = Number(options.goodsId || 0);
    const goodsName = options.goodsName ? decodeURIComponent(options.goodsName) : '';
    if (!orderId || !goodsId) {
      wx.showToast({ title: '评价参数错误', icon: 'none' });
      setTimeout(() => wx.navigateBack(), 600);
      return;
    }
    this.setData({ orderId, goodsId, goodsName });
  },

  onSelectRating(e) {
    const value = Number(e.currentTarget.dataset.value || 5);
    this.setData({ rating: Math.max(1, Math.min(5, value)) });
  },

  onInputContent(e) {
    this.setData({ content: e.detail.value || '' });
  },

  onSubmit() {
    if (this.data.submitting) return;
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    const payload = {
      userId,
      orderId: this.data.orderId,
      goodsId: this.data.goodsId,
      rating: this.data.rating,
      content: (this.data.content || '').trim()
    };

    this.setData({ submitting: true });
    post('/comment/submit', payload, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '评价成功', icon: 'success' });
        setTimeout(() => wx.navigateBack(), 700);
      })
      .catch((error) => showRequestError(error, '评价提交失败'))
      .finally(() => this.setData({ submitting: false }));
  }
});

