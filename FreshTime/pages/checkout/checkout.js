const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    items: [],
    amount: 0,
    submitting: false,
    address: null,
    remark: ''
  },

  onShow() {
    const items = wx.getStorageSync('checkoutItems') || [];
    const amount = items.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0);
    const selectedAddress = wx.getStorageSync('selectedAddress');
    this.setData({
      items,
      amount: Math.round(amount * 100) / 100,
      address: selectedAddress || null
    });

    if (!selectedAddress) {
      this.loadDefaultAddress();
    }
  },

  loadDefaultAddress() {
    const userId = app.getUserId();
    if (!userId) return;

    get('/address/list', { userId }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        if (!Array.isArray(list) || list.length === 0) return;
        const def = list.find((item) => Number(item.isDefault) === 1) || list[0];
        this.setData({ address: def });
      })
      .catch(() => {});
  },

  onChooseAddress() {
    wx.navigateTo({ url: '/pages/address-list/address-list?select=1' });
  },

  onInputRemark(e) {
    this.setData({ remark: e.detail.value || '' });
  },

  onSubmit() {
    if (this.data.submitting) return;
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }
    if (!this.data.items.length) {
      wx.showToast({ title: '无可提交商品', icon: 'none' });
      return;
    }
    if (!this.data.address || !this.data.address.id) {
      wx.showToast({ title: '请选择收货地址', icon: 'none' });
      return;
    }

    const payload = {
      userId,
      merchantId: this.data.items[0].merchantId || 1,
      addressId: this.data.address.id,
      remark: (this.data.remark || '').trim(),
      items: this.data.items.map((item) => ({
        goodsId: item.id,
        quantity: item.quantity
      }))
    };

    this.setData({ submitting: true });
    post('/order/submit', payload, { retry: 0 })
      .then((res) => {
        post(`/cart/delete-selected?userId=${userId}`, {}, { retry: 0 }).catch(() => {});

        wx.removeStorageSync('checkoutItems');
        wx.removeStorageSync('selectedAddress');
        wx.showToast({ title: '下单成功', icon: 'success' });
        const orderId = res && res.data && res.data.orderId;
        setTimeout(() => {
          if (orderId) {
            wx.redirectTo({ url: `/pages/pay-result/pay-result?result=success&orderId=${orderId}` });
          } else {
            wx.redirectTo({ url: '/pages/order-list/order-list' });
          }
        }, 600);
      })
      .catch((error) => showRequestError(error, '下单失败'))
      .finally(() => this.setData({ submitting: false }));
  },

  onGoCart() {
    wx.switchTab({ url: '/pages/cart/cart' });
  }
});

