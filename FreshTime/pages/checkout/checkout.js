const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    items: [],
    amount: 0,
    discountAmount: 0,
    actualAmount: 0,
    submitting: false,
    address: null,
    remark: '',
    couponList: [],
    availableCouponList: [],
    unavailableCouponList: [],
    selectedCouponId: null,
    selectedCouponIndex: -1
  },

  onShow() {
    const items = wx.getStorageSync('checkoutItems') || [];
    const amount = items.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0);
    const selectedAddress = wx.getStorageSync('selectedAddress');
    this.setData({
      items,
      amount: Math.round(amount * 100) / 100,
      discountAmount: 0,
      actualAmount: Math.round(amount * 100) / 100,
      address: selectedAddress || null
    });

    if (!selectedAddress) {
      this.loadDefaultAddress();
    }
    this.loadCoupons();
  },

  loadCoupons() {
    const userId = app.getUserId();
    if (!userId) return;
    get('/coupon/list', { userId }, { retry: 0 })
      .then((res) => {
        const list = Array.isArray(res && res.data) ? res.data : [];
        this.setData({ couponList: list }, () => this.recalculateCoupons(true));
      })
      .catch(() => {});
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

  onChooseCoupon(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const target = this.data.availableCouponList.find((item) => Number(item.id) === id);
    if (!target) return;
    this.applySelectedCoupon(Number(target.id));
  },

  onClearCoupon() {
    this.applySelectedCoupon(null);
  },

  recalculateCoupons(autoPickBest) {
    const amount = Number(this.data.amount || 0);
    const source = (this.data.couponList || []).map((item) => {
      const thresholdAmount = Number(item.thresholdAmount || 0);
      const discountAmount = Math.min(Number(item.discountAmount || 0), amount);
      const usable = amount >= thresholdAmount;
      return {
        ...item,
        thresholdAmount,
        discountAmount,
        usable,
        unusableReason: usable ? '' : `满${thresholdAmount}可用`
      };
    });
    const availableCouponList = source
      .filter((item) => item.usable)
      .sort((a, b) => {
        if (b.discountAmount !== a.discountAmount) return b.discountAmount - a.discountAmount;
        if (b.thresholdAmount !== a.thresholdAmount) return b.thresholdAmount - a.thresholdAmount;
        return String(a.expireAt || '').localeCompare(String(b.expireAt || ''));
      });
    const unavailableCouponList = source.filter((item) => !item.usable);
    this.setData({ availableCouponList, unavailableCouponList }, () => {
      const selectedId = Number(this.data.selectedCouponId || 0);
      const selectedAvailable = this.data.availableCouponList.find((item) => Number(item.id) === selectedId);
      if (selectedAvailable) {
        this.applySelectedCoupon(selectedId);
        return;
      }
      if (autoPickBest && this.data.availableCouponList.length > 0) {
        this.applySelectedCoupon(Number(this.data.availableCouponList[0].id));
        return;
      }
      this.applySelectedCoupon(null);
    });
  },

  applySelectedCoupon(couponId) {
    const amount = Number(this.data.amount || 0);
    const selected = (this.data.availableCouponList || []).find((item) => Number(item.id) === Number(couponId));
    const discountAmount = selected ? Math.min(Number(selected.discountAmount || 0), amount) : 0;
    const actualAmount = Math.max(0, amount - discountAmount);
    this.setData({
      selectedCouponId: selected ? Number(selected.id) : null,
      selectedCouponIndex: selected ? this.data.availableCouponList.findIndex((item) => Number(item.id) === Number(selected.id)) : -1,
      discountAmount: Math.round(discountAmount * 100) / 100,
      actualAmount: Math.round(actualAmount * 100) / 100
    });
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
      couponId: this.data.selectedCouponId,
      remark: (this.data.remark || '').trim(),
      items: this.data.items.map((item) => ({
        goodsId: item.id,
        quantity: item.quantity
      }))
    };

    this.setData({ submitting: true });
    post('/order/submit', payload, { retry: 0 })
      .then((res) => {
        const orderId = res && res.data && res.data.orderId;
        if (!orderId) {
          wx.redirectTo({ url: '/pages/order-list/order-list' });
          return;
        }
        return post(`/order/pay/mock-create?userId=${userId}&orderId=${orderId}`, {}, { retry: 0 })
          .then((payRes) => {
            const payData = (payRes && payRes.data) || {};
            return post('/order/pay/mock-confirm', {
              userId,
              orderId,
              payTradeNo: payData.payTradeNo
            }, { retry: 0 }).then((confirmRes) => {
              const confirmData = (confirmRes && confirmRes.data) || {};
              post(`/cart/delete-selected?userId=${userId}`, {}, { retry: 0 }).catch(() => {});
              wx.removeStorageSync('checkoutItems');
              wx.removeStorageSync('selectedAddress');
              wx.showToast({ title: '支付成功', icon: 'success' });
              setTimeout(() => {
                wx.redirectTo({
                  url: `/pages/pay-result/pay-result?result=success&orderId=${orderId}&payTradeNo=${encodeURIComponent(confirmData.payTradeNo || '')}&payChannel=${encodeURIComponent(confirmData.payChannel || '')}`
                });
              }, 600);
            });
          });
      })
      .catch((error) => showRequestError(error, '下单失败'))
      .finally(() => this.setData({ submitting: false }));
  },

  onGoCart() {
    wx.switchTab({ url: '/pages/cart/cart' });
  }
});

