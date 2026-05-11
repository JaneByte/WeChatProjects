const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    id: null,
    detail: null,
    loading: false,
    loadError: false,
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
    this.setData({ loading: true, loadError: false });
    get('/goods/detail', { id: this.data.id }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || null;
        if (!detail || !detail.id || Number(detail.status) === 0) {
          this.setData({ detail: null, quantity: 1 });
          return;
        }
        this.setData({ detail, quantity: 1 });
      })
      .catch((error) => {
        this.setData({ detail: null, loadError: true });
        showRequestError(error, '商品加载失败');
      })
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
    const addQty = Number(this.data.quantity || 1);
    this.recheckGoodsAvailability(detail.id, addQty)
      .then((freshDetail) => {
        post(`/cart/add?userId=${userId}&goodsId=${freshDetail.id}&quantity=${addQty}`, {}, { retry: 0 })
          .then(() => {
            wx.showToast({ title: '已加入购物车', icon: 'success' });
            if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
          })
          .catch((error) => showRequestError(error, '加入购物车失败'));
      })
      .catch((error) => showRequestError(error, error.message || '商品状态已变更，请重试'));
  },

  onBuyNow() {
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    const buyQty = Number(this.data.quantity || 1);
    this.recheckGoodsAvailability(detail.id, buyQty)
      .then((freshDetail) => {
        wx.setStorageSync('checkoutItems', [{
          id: freshDetail.id,
          name: freshDetail.name,
          image: freshDetail.mainImage || '',
          price: freshDetail.price,
          quantity: buyQty,
          merchantId: freshDetail.merchantId || 1
        }]);
        wx.navigateTo({ url: '/pages/checkout/checkout' });
      })
      .catch((error) => showRequestError(error, error.message || '商品状态已变更，请重试'));
  },

  recheckGoodsAvailability(goodsId, expectQty) {
    return get('/goods/detail', { id: goodsId }, { retry: 0 }).then((res) => {
      const fresh = (res && res.data) || null;
      if (!fresh || !fresh.id || Number(fresh.status) !== 1) {
        throw new Error('商品已下架');
      }
      if (Number(fresh.stock || 0) < Number(expectQty || 1)) {
        throw new Error('库存不足，请调整数量');
      }
      this.setData({ detail: fresh });
      return fresh;
    });
  },

  onGoTrace() {
    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    wx.navigateTo({ url: `/pages/trace-detail/trace-detail?goodsId=${detail.id}` });
  }
});

