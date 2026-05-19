const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    cartItems: [],
    allSelected: false,
    totalPrice: 0,
    selectedCount: 0,
    editMode: false,
    startX: 0,
    currentSlideId: null,
    slideThreshold: 56,
    slideTransition: true,
    rpxRatio: 1,
    actionLoading: false
  },

  resetCartState() {
    this.setData({
      cartItems: [],
      allSelected: false,
      totalPrice: 0,
      selectedCount: 0,
      currentSlideId: null,
      actionLoading: false
    });
    this.syncBadgeFromServerData([]);
  },

  onLoad() {
    const systemInfo = wx.getSystemInfoSync();
    this.data.rpxRatio = 750 / systemInfo.screenWidth;
    this.loadCartData();
  },

  onShow() {
    app.ensureLoginReady().finally(() => this.loadCartData());
  },

  requireLogin(redirect = '/pages/cart/cart') {
    app.requireLogin({ redirect }).catch(() => {});
    return false;
  },

  loadCartData() {
    if (!app.getUserId()) {
      this.resetCartState();
      return;
    }
    get('/cart/list', {}, { retry: 0 })
      .then((res) => {
        const raw = (res && res.data) || [];
        const cartItems = (Array.isArray(raw) ? raw : []).map((item) => ({
          id: Number(item.id || 0),
          goodsId: Number(item.goodsId || item.id),
          skuId: Number(item.skuId || 0),
          name: item.name || '',
          price: Number(item.price || 0),
          originPrice: Number(item.originPrice || item.price || 0),
          priceType: item.priceType || 'NORMAL',
          flashActive: Boolean(item.flashActive),
          unit: item.unit || '件',
          desc: item.desc || '',
          image: item.image || '',
          stock: Number(item.stock || 0),
          quantity: Number(item.quantity || 1),
          skuName: item.skuName || '',
          skuWeightG: Number(item.skuWeightG || 0),
          skuText: item.skuText || '',
          sourceType: item.sourceType || 'NORMAL',
          sourcePlanId: item.sourcePlanId || null,
          sourceScene: item.sourceScene || '',
          sourceLabel: this.formatSourceLabel(item.sourceType, item.sourceScene),
          specLabel: this.formatSpecLabel(item.skuName, item.skuWeightG, item.skuText),
          selected: Boolean(item.selected),
          slideOffset: 0
        }));
        this.setData({ cartItems }, () => this.calculateTotalAndSelectState());
        this.syncBadgeFromServerData(cartItems);
      })
      .catch((error) => {
        this.resetCartState();
        showRequestError(error, '购物车加载失败');
      });
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

  formatSpecLabel(skuName, skuWeightG, skuText) {
    const name = `${skuName || ''}`.trim();
    const weight = Number(skuWeightG || 0);
    if (name && weight > 0) return `${name} ${weight}g`;
    if (name) return name;
    if (weight > 0) return `${weight}g`;
    const fallback = `${skuText || ''}`.trim();
    return fallback.replace(/\s*·\s*/g, ' ');
  },

  calculateTotalAndSelectState() {
    const { cartItems } = this.data;
    let totalPrice = 0;
    let selectedCount = 0;
    let allSelected = cartItems.length > 0;

    cartItems.forEach((item) => {
      if (item.stock > 0 && item.selected) {
        totalPrice += Number(item.price || 0) * Number(item.quantity || 0);
        selectedCount += 1;
      }
      if (item.stock > 0 && !item.selected) allSelected = false;
    });

    this.setData({
      totalPrice: Math.round(totalPrice * 100) / 100,
      selectedCount,
      allSelected
    });
  },

  syncBadgeFromServerData(cartItems) {
    app.globalData.cartList = (cartItems || []).map((item) => ({
      id: item.id,
      quantity: Number(item.quantity || 0)
    }));
    if (app && app.updateCartBadge) app.updateCartBadge();
  },

  toggleSelect(e) {
    if (this.data.actionLoading) return;
    const id = Number(e.currentTarget.dataset.id);
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    if (this.data.cartItems[index].stock <= 0) {
      wx.showToast({ title: '暂无库存', icon: 'none' });
      return;
    }
    if (!app.getUserId()) return;
    const nextSelected = this.data.cartItems[index].selected ? 0 : 1;
    this.setData({ actionLoading: true });
    post(`/cart/select?goodsId=${this.data.cartItems[index].goodsId}&skuId=${this.data.cartItems[index].skuId}&selected=${nextSelected}`, {}, { retry: 0 })
      .then(() => this.loadCartData())
      .catch((error) => showRequestError(error, '更新选中失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  toggleSelectAll() {
    if (this.data.actionLoading) return;
    if (!app.getUserId()) return;
    const selected = this.data.allSelected ? 0 : 1;
    this.setData({ actionLoading: true });
    post(`/cart/select-all?selected=${selected}`, {}, { retry: 0 })
      .then(() => this.loadCartData())
      .catch((error) => showRequestError(error, '全选更新失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  increaseQuantity(e) {
    if (this.data.editMode || this.data.actionLoading) return;
    const id = Number(e.currentTarget.dataset.id);
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    const item = this.data.cartItems[index];
    if (item.stock <= item.quantity) {
      wx.showToast({ title: '库存不足', icon: 'none' });
      return;
    }
    this.updateQuantity(item, item.quantity + 1);
  },

  decreaseQuantity(e) {
    if (this.data.editMode || this.data.actionLoading) return;
    const id = Number(e.currentTarget.dataset.id);
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    const item = this.data.cartItems[index];
    if (item.quantity <= 1) return;
    this.updateQuantity(item, item.quantity - 1);
  },

  updateQuantity(item, quantity) {
    if (!app.getUserId()) return;
    this.setData({ actionLoading: true });
    post(`/cart/quantity?goodsId=${item.goodsId}&skuId=${item.skuId}&quantity=${quantity}`, {}, { retry: 0 })
      .then(() => this.loadCartData())
      .catch((error) => showRequestError(error, '更新数量失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onTouchStart(e) {
    const id = Number(e.currentTarget.dataset.id);
    this.data.startX = e.touches[0].clientX;
    this.data.currentSlideId = id;
  },

  onTouchMove(e) {
    const id = Number(e.currentTarget.dataset.id);
    if (id !== this.data.currentSlideId) return;
    const moveX = (e.touches[0].clientX - this.data.startX) * this.data.rpxRatio;
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    const offset = Math.min(Math.max(-moveX, 0), 176);
    this.setData({ [`cartItems[${index}].slideOffset`]: offset, slideTransition: false });
  },

  onTouchEnd(e) {
    const id = Number(e.currentTarget.dataset.id);
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    const currentOffset = this.data.cartItems[index].slideOffset || 0;
    const target = currentOffset >= this.data.slideThreshold ? 176 : 0;
    this.setData({ [`cartItems[${index}].slideOffset`]: target, slideTransition: true });
    this.data.currentSlideId = null;
  },

  deleteItem(e) {
    if (this.data.actionLoading) return;
    const id = Number(e.currentTarget.dataset.id);
    if (!app.getUserId()) return;
    this.setData({ actionLoading: true });
    const target = this.data.cartItems.find((item) => Number(item.id) === Number(id));
    if (!target) {
      this.setData({ actionLoading: false });
      return;
    }
    post(`/cart/delete?goodsId=${target.goodsId}&skuId=${target.skuId}`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已删除', icon: 'success' });
        this.loadCartData();
      })
      .catch((error) => showRequestError(error, '删除失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  toggleEditMode() {
    this.setData({ editMode: !this.data.editMode });
  },

  onBatchDelete() {
    if (this.data.actionLoading || this.data.selectedCount === 0) return;
    if (!app.getUserId()) return;
    this.setData({ actionLoading: true });
    post('/cart/delete-selected', {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '删除成功', icon: 'success' });
        this.loadCartData();
      })
      .catch((error) => showRequestError(error, '删除失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onCheckout() {
    if (this.data.selectedCount === 0) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/cart/cart', message: '正在登录，请稍候' }).catch(() => {});
      return;
    }

    const selectedItems = this.data.cartItems.filter((item) => item.selected && item.stock > 0);
    if (!selectedItems.length) {
      wx.showToast({ title: '暂无可结算商品', icon: 'none' });
      return;
    }

    wx.setStorageSync('checkoutItems', selectedItems.map((item) => ({
      id: item.goodsId || item.id,
      skuId: item.skuId,
      name: item.name,
      image: item.image,
      price: item.price,
      originPrice: item.originPrice,
      priceType: item.priceType || 'NORMAL',
      flashActive: Boolean(item.flashActive),
      skuName: item.skuName,
      skuWeightG: item.skuWeightG,
      quantity: item.quantity,
      sourceType: item.sourceType || 'NORMAL',
      sourcePlanId: item.sourcePlanId || null,
      sourceScene: item.sourceScene || ''
    })));
    wx.setStorageSync('checkoutMeta', {
      source: 'cart',
      cartItems: selectedItems.map((item) => ({
        goodsId: Number(item.goodsId || item.id || 0),
        skuId: Number(item.skuId || 0)
      }))
    });

    wx.navigateTo({ url: '/pages/checkout/checkout' });
  },

  goShopping() {
    wx.switchTab({ url: '/pages/category/category' });
  },

  goToDetail(e) {
    const id = Number(e.currentTarget.dataset.id);
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  }
});
