const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    id: null,
    detail: null,
    loading: false,
    quantity: 1
  },

  onLoad(options) {
    const id = Number(options.id || 0);
    if (!id) {
      wx.showToast({ title: '商品参数错误', icon: 'none' });
      return;
    }
    this.setData({ id });
    this.loadDetail();
  },

  loadDetail() {
    this.setData({ loading: true });
    get('/goods/detail', { id: this.data.id }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || null;
        this.setData({ detail, quantity: 1 });
      })
      .catch((error) => showRequestError(error, '商品加载失败'))
      .finally(() => this.setData({ loading: false }));
  },

  onInputQuantity(e) {
    const stock = Number((this.data.detail && this.data.detail.stock) || 0);
    let value = Number(e.detail.value || 1);
    if (!Number.isFinite(value) || value <= 0) value = 1;
    if (stock > 0 && value > stock) value = stock;
    this.setData({ quantity: value });
  },

  onMinus() {
    const next = Math.max(1, Number(this.data.quantity || 1) - 1);
    this.setData({ quantity: next });
  },

  onPlus() {
    const stock = Number((this.data.detail && this.data.detail.stock) || 0);
    const current = Number(this.data.quantity || 1);
    if (stock > 0 && current >= stock) {
      wx.showToast({ title: '已达库存上限', icon: 'none' });
      return;
    }
    this.setData({ quantity: current + 1 });
  },

  onAddCart() {
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    if (Number(detail.stock || 0) <= 0) {
      wx.showToast({ title: '商品已售罄', icon: 'none' });
      return;
    }

    const addQty = Number(this.data.quantity || 1);
    post(`/cart/add?userId=${userId}&goodsId=${detail.id}&quantity=${addQty}`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success' });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => showRequestError(error, '加入购物车失败'));
  },

  onBuyNow() {
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    if (Number(detail.stock || 0) <= 0) {
      wx.showToast({ title: '商品已售罄', icon: 'none' });
      return;
    }

    wx.setStorageSync('checkoutItems', [{
      id: detail.id,
      name: detail.name,
      image: detail.mainImage || '',
      price: detail.price,
      quantity: Number(this.data.quantity || 1),
      merchantId: detail.merchantId || 1
    }]);
    wx.navigateTo({ url: '/pages/checkout/checkout' });
  }
});

