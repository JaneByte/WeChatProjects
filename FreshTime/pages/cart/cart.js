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
    slideThreshold: 100,
    slideTransition: true,
    rpxRatio: 1,
    actionLoading: false
  },

  onLoad() {
    const systemInfo = wx.getSystemInfoSync();
    this.data.rpxRatio = 750 / systemInfo.screenWidth;
    this.loadCartData();
  },

  onShow() {
    this.loadCartData();
  },

  loadCartData() {
    const userId = app.getUserId();
    if (!userId) {
      this.setData({ cartItems: [] }, () => this.calculateTotalAndSelectState());
      return;
    }
    get('/cart/list', { userId }, { retry: 0 })
      .then((res) => {
        const raw = (res && res.data) || [];
        const cartItems = (Array.isArray(raw) ? raw : []).map((item) => ({
          id: Number(item.goodsId || item.id),
          goodsId: Number(item.goodsId || item.id),
          merchantId: item.merchantId || 1,
          name: item.name || '',
          price: Number(item.price || 0),
          unit: item.unit || '件',
          desc: item.desc || '',
          image: item.image || '',
          stock: Number(item.stock || 0),
          quantity: Number(item.quantity || 1),
          selected: Boolean(item.selected),
          slideOffset: 0
        }));
        this.setData({ cartItems }, () => this.calculateTotalAndSelectState());
        this.syncBadgeFromServerData(cartItems);
      })
      .catch((error) => {
        this.setData({ cartItems: [] }, () => this.calculateTotalAndSelectState());
        showRequestError(error, '购物车加载失败');
      });
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
    const userId = app.getUserId();
    if (!userId) return;
    const nextSelected = this.data.cartItems[index].selected ? 0 : 1;
    this.setData({ actionLoading: true });
    post(`/cart/select?userId=${userId}&goodsId=${id}&selected=${nextSelected}`, {}, { retry: 0 })
      .then(() => this.loadCartData())
      .catch((error) => showRequestError(error, '更新选中失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  toggleSelectAll() {
    if (this.data.actionLoading) return;
    const userId = app.getUserId();
    if (!userId) return;
    const selected = this.data.allSelected ? 0 : 1;
    this.setData({ actionLoading: true });
    post(`/cart/select-all?userId=${userId}&selected=${selected}`, {}, { retry: 0 })
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
    this.updateQuantity(id, item.quantity + 1);
  },

  decreaseQuantity(e) {
    if (this.data.editMode || this.data.actionLoading) return;
    const id = Number(e.currentTarget.dataset.id);
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    const item = this.data.cartItems[index];
    if (item.quantity <= 1) return;
    this.updateQuantity(id, item.quantity - 1);
  },

  updateQuantity(goodsId, quantity) {
    const userId = app.getUserId();
    if (!userId) return;
    this.setData({ actionLoading: true });
    post(`/cart/quantity?userId=${userId}&goodsId=${goodsId}&quantity=${quantity}`, {}, { retry: 0 })
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
    const offset = Math.min(Math.max(-moveX, 0), 160);
    this.setData({ [`cartItems[${index}].slideOffset`]: offset, slideTransition: false });
  },

  onTouchEnd(e) {
    const id = Number(e.currentTarget.dataset.id);
    const index = this.data.cartItems.findIndex((item) => Number(item.id) === id);
    if (index < 0) return;
    const currentOffset = this.data.cartItems[index].slideOffset || 0;
    const target = currentOffset >= this.data.slideThreshold ? 160 : 0;
    this.setData({ [`cartItems[${index}].slideOffset`]: target, slideTransition: true });
    this.data.currentSlideId = null;
  },

  onScroll() {},

  deleteItem(e) {
    if (this.data.actionLoading) return;
    const id = Number(e.currentTarget.dataset.id);
    const userId = app.getUserId();
    if (!userId) return;
    this.setData({ actionLoading: true });
    post(`/cart/delete?userId=${userId}&goodsId=${id}`, {}, { retry: 0 })
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
    const userId = app.getUserId();
    if (!userId) return;
    this.setData({ actionLoading: true });
    post(`/cart/delete-selected?userId=${userId}`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '删除成功', icon: 'success' });
        this.loadCartData();
      })
      .catch((error) => showRequestError(error, '删除失败'))
      .finally(() => this.setData({ actionLoading: false }));
  },

  onCheckout() {
    if (this.data.selectedCount === 0) return;
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    const selectedItems = this.data.cartItems.filter((item) => item.selected && item.stock > 0);
    if (!selectedItems.length) {
      wx.showToast({ title: '暂无可结算商品', icon: 'none' });
      return;
    }

    wx.setStorageSync('checkoutItems', selectedItems.map((item) => ({
      id: item.goodsId || item.id,
      name: item.name,
      image: item.image,
      price: item.price,
      quantity: item.quantity,
      merchantId: item.merchantId || 1
    })));

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
