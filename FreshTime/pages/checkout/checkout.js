const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const { runMockPayFlow } = require('../../utils/mock-pay');
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
    selectedCouponIndex: -1,
    pendingOrderId: null,
    checkoutMeta: null,
    orderTipText: '',
    amountLabel: '商品总额'
  },
  submitLock: false,

  onShow() {
    const items = wx.getStorageSync('checkoutItems') || [];
    const checkoutMeta = wx.getStorageSync('checkoutMeta') || null;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/checkout/checkout', silent: true }).catch((error) => {
        showRequestError(error, '登录状态失效，请重新登录');
      });
      return;
    }
    const planPackPrice = checkoutMeta && checkoutMeta.source === 'plan'
      ? Number(checkoutMeta.packPrice || 0)
      : 0;
    const rawAmount = items.reduce((sum, item) => sum + Number(item.price || 0) * Number(item.quantity || 0), 0);
    const amount = planPackPrice > 0 ? planPackPrice : rawAmount;
    const normalizedItems = (Array.isArray(items) ? items : []).map((item) => ({
      ...item,
      price: Number(item.price || 0),
      originPrice: Number(item.originPrice || item.price || 0),
      flashActive: Boolean(item.flashActive),
      priceType: item.priceType || 'NORMAL',
      sourceLabel: this.formatSourceLabel(item.sourceType, item.sourceScene),
      specLabel: this.formatSpecLabel(item.skuName, item.skuWeightG)
    }));
    const selectedAddress = wx.getStorageSync('selectedAddress');
    this.setData({
      items: normalizedItems,
      amount: Math.round(amount * 100) / 100,
      discountAmount: 0,
      actualAmount: Math.round(amount * 100) / 100,
      address: selectedAddress || null,
      checkoutMeta,
      amountLabel: checkoutMeta && checkoutMeta.source === 'plan' ? '当前方案价' : '商品总额',
      orderTipText: checkoutMeta && checkoutMeta.source === 'plan'
        ? (checkoutMeta.tipText || '组合优惠仅限当前方案即时下单，加入普通购物车后不保留该优惠')
        : ''
    });

    if (!selectedAddress) {
      this.loadDefaultAddress();
    }
    this.loadCoupons();
  },

  formatSourceLabel(sourceType, sourceScene) {
    const scene = this.decodeSourceScene(sourceScene);
    const type = `${sourceType || ''}`.trim().toUpperCase();
    if (scene && scene !== 'MIXED' && scene !== 'ORDER_SOURCE_MIXED') {
      return scene;
    }
    if (type === 'MEAL') return '小份优选';
    if (type === 'COMBO') return '蔬果搭配';
    if (type === 'SEASONAL') return '当季精选';
    if (type === 'FLASH') return '限时秒杀';
    return '';
  },

  decodeSourceScene(sourceScene) {
    const text = `${sourceScene || ''}`.trim();
    if (!text) return '';
    try {
      return decodeURIComponent(text);
    } catch (error) {
      return text;
    }
  },

  formatSpecLabel(skuName, skuWeightG) {
    const name = `${skuName || ''}`.trim();
    const weight = Number(skuWeightG || 0);
    if (name && weight > 0) return `${name} ${weight}g`;
    if (name) return name;
    if (weight > 0) return `${weight}g`;
    return '';
  },

  loadCoupons() {
    if (!app.getUserId()) return;
    get('/coupon/list', {}, { retry: 0 })
      .then((res) => {
        const list = Array.isArray(res && res.data) ? res.data : [];
        this.setData({ couponList: list }, () => this.recalculateCoupons(true));
      })
      .catch((error) => {
        showRequestError(error, '优惠券加载失败');
      });
  },

  loadDefaultAddress() {
    if (!app.getUserId()) return;

    get('/address/list', {}, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        if (!Array.isArray(list) || list.length === 0) return;
        const def = list.find((item) => Number(item.isDefault) === 1) || list[0];
        this.setData({ address: def });
      })
      .catch((error) => {
        showRequestError(error, '默认地址加载失败');
      });
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
    if (this.data.submitting || this.submitLock) return;
    if (this.data.pendingOrderId) {
      wx.redirectTo({ url: `/pages/order-detail/order-detail?id=${this.data.pendingOrderId}` });
      return;
    }
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/checkout/checkout' }).catch((error) => {
        showRequestError(error, '登录状态失效，请重新登录');
      });
      return;
    }
    if (!this.data.items.length) {
      wx.showToast({ title: '无可提交商品', icon: 'none' });
      return;
    }
    if (!this.data.address || !this.data.address.id) {
      wx.showToast({ title: '请先选择收货地址', icon: 'none' });
      return;
    }
    const payload = {
      addressId: this.data.address.id,
      userCouponId: this.data.selectedCouponId,
      remark: (this.data.remark || '').trim(),
      packPrice: this.data.checkoutMeta && this.data.checkoutMeta.source === 'plan'
        ? Number(this.data.checkoutMeta.packPrice || 0)
        : undefined,
      items: this.data.items.map((item) => ({
        goodsId: item.id,
        skuId: Number(item.skuId || 0),
        quantity: Number(item.quantity || 0),
        sourceType: item.sourceType || 'NORMAL',
        sourcePlanId: item.sourcePlanId || null,
        sourceScene: item.sourceScene || ''
      }))
    };
    const invalidItem = payload.items.find((item) => !item.goodsId || !item.skuId || !item.quantity || Number(item.quantity) <= 0);
    if (invalidItem) {
      wx.showToast({ title: '商品规格异常，请返回重选', icon: 'none' });
      return;
    }

    this.submitLock = true;
    this.setData({ submitting: true });
    post('/order/submit', payload, { retry: 0 })
      .then((res) => {
        const orderId = res && res.data && res.data.orderId;
        if (!orderId) {
          wx.redirectTo({ url: '/pages/order-list/order-list' });
          return;
        }
        this.setData({ pendingOrderId: orderId });
        wx.removeStorageSync('checkoutItems');
        wx.removeStorageSync('checkoutMeta');
        wx.removeStorageSync('selectedAddress');
        return this.cleanupCheckoutCartItems()
          .catch((error) => {
            showRequestError(error, '清理购物车结算项失败');
          })
          .then(() => app.refreshCartBadgeFromServer().catch((error) => {
            showRequestError(error, '购物车角标刷新失败');
          }))
          .then(() => runMockPayFlow({
          orderId,
          orderNo: res && res.data && res.data.orderNo,
          actualAmount: this.data.actualAmount
          }))
          .then(() => {
            wx.showToast({ title: '支付成功', icon: 'success' });
            setTimeout(() => {
              wx.redirectTo({
                url: `/pages/pay-result/pay-result?result=success&orderId=${orderId}`
              });
            }, 600);
          });
      })
      .catch((error) => {
        const pendingId = this.data.pendingOrderId;
        if (error && error.code === 'PAY_CANCELLED') {
          wx.showToast({ title: '你已取消支付', icon: 'none' });
          if (pendingId) {
            setTimeout(() => {
              wx.redirectTo({ url: `/pages/order-detail/order-detail?id=${pendingId}` });
            }, 400);
          }
          return;
        }
        showRequestError(error, '支付失败，请在订单详情继续支付');
        if (pendingId) {
          setTimeout(() => {
            wx.redirectTo({ url: `/pages/order-detail/order-detail?id=${pendingId}` });
          }, 500);
        }
      })
      .finally(() => {
        this.submitLock = false;
        this.setData({ submitting: false });
      });
  },

  cleanupCheckoutCartItems() {
    const meta = this.data.checkoutMeta || {};
    const source = `${meta.source || ''}`.trim();
    const cartItems = Array.isArray(meta.cartItems) ? meta.cartItems : [];
    if (source !== 'cart' || cartItems.length === 0) {
      return Promise.resolve();
    }
    const tasks = cartItems
      .map((item) => ({
        goodsId: Number(item.goodsId || 0),
        skuId: Number(item.skuId || 0)
      }))
      .filter((item) => item.goodsId > 0 && item.skuId > 0)
      .map((item) => post(`/cart/delete?goodsId=${item.goodsId}&skuId=${item.skuId}`, {}, { retry: 0 }));
    if (!tasks.length) {
      return Promise.resolve();
    }
    return Promise.all(tasks);
  },

  onGoCart() {
    wx.switchTab({ url: '/pages/cart/cart' });
  }
});
