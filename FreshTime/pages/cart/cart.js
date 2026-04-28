// cart.js
// 购物车逻辑，保持与分类页的全局购物车数据同步
const app = getApp();
const { post } = require('../../utils/request.js');
const { showRequestError } = require('../../utils/ui.js');

Page({
  data: {
    cartItems: [],
    allSelected: false,
    totalPrice: 0,
    selectedCount: 0,
    editMode: false,
    scrollTimer: null,
    slideTransition: true,
    startX: 0,
    currentSlideId: null,
    slideThreshold: 100,
    rpxRatio: 1
  },

  onLoad() {
    const systemInfo = wx.getSystemInfoSync();
    this.data.rpxRatio = 750 / systemInfo.screenWidth;
    this.loadCartData();
  },

  onShow() {
    this.loadCartData();
    if (app && app.updateCartBadge) {
      app.updateCartBadge();
    }
  },

  onPullDownRefresh() {
    this.setData({ editMode: false });
    this.loadCartData();
    wx.stopPullDownRefresh();
  },

  onUnload() {
    if (this.data.scrollTimer) {
      clearTimeout(this.data.scrollTimer);
      this.data.scrollTimer = null;
    }
  },

  loadCartData() {
    const globalCart = app?.globalData?.cartList || [];

    const cartMap = new Map();
    globalCart.forEach((item) => {
      if (cartMap.has(item.id)) {
        const existItem = cartMap.get(item.id);
        existItem.quantity = (existItem.quantity || 1) + (item.quantity || 1);
        existItem.stock = Math.min(
          existItem.stock !== undefined ? existItem.stock : 999,
          item.stock !== undefined ? item.stock : 999
        );
        existItem.selected = existItem.selected ?? item.selected ?? true;
      } else {
        cartMap.set(item.id, { ...item });
      }
    });

    const cartItems = Array.from(cartMap.values()).map((item) => ({
      ...item,
      slideOffset: 0,
      stock: item.stock !== undefined ? item.stock : 999,
      quantity: item.quantity || 1,
      selected: item.selected !== undefined ? item.selected : true,
      unit: item.unit || '件',
      desc: item.desc || '',
      image: item.image || ''
    }));

    this.setData({ cartItems }, () => {
      this.calculateTotalAndSelectState();
    });
  },

  calculateTotalAndSelectState() {
    let { cartItems } = this.data;
    let total = 0;
    let selectedCount = 0;
    const updates = {};
    let hasUpdate = false;

    cartItems = cartItems.map((item, idx) => {
      if (item.stock <= 0 && item.selected) {
        updates[`cartItems[${idx}].selected`] = false;
        hasUpdate = true;
        return { ...item, selected: false };
      }
      return item;
    });

    if (hasUpdate) {
      this.setData(updates);
    }

    const validItems = cartItems.filter((item) => item.stock > 0);
    let allSelected = validItems.length > 0;

    cartItems.forEach((item) => {
      if (item.selected && item.stock > 0) {
        total += item.price * item.quantity;
        selectedCount++;
      }
      if (item.stock > 0 && !item.selected) {
        allSelected = false;
      }
    });

    total = Math.round(total * 100) / 100;
    this.setData({
      totalPrice: total,
      selectedCount,
      allSelected
    });
  },

  syncToGlobal() {
    const { cartItems } = this.data;
    const pureCart = cartItems.map(({ slideOffset, ...rest }) => rest);
    app.globalData.cartList = pureCart;
    app.syncCartToStorage();
  },

  toggleSelect(e) {
    const { id } = e.currentTarget.dataset;
    const { cartItems } = this.data;
    const index = cartItems.findIndex((item) => item.id === id);
    if (index === -1) return;
    const item = cartItems[index];

    if (item.stock <= 0) {
      wx.showToast({ title: '暂无库存', icon: 'none', duration: 1500 });
      return;
    }

    this.setData({
      [`cartItems[${index}].selected`]: !item.selected
    }, () => {
      this.calculateTotalAndSelectState();
      this.syncToGlobal();
    });
  },

  toggleSelectAll() {
    const { cartItems, allSelected } = this.data;
    const newSelected = !allSelected;
    const updates = {};
    cartItems.forEach((item, idx) => {
      if (item.stock > 0) {
        updates[`cartItems[${idx}].selected`] = newSelected;
      } else {
        updates[`cartItems[${idx}].selected`] = false;
      }
    });
    this.setData(updates, () => {
      this.calculateTotalAndSelectState();
      this.syncToGlobal();
    });
  },

  increaseQuantity(e) {
    const { id } = e.currentTarget.dataset;
    const { cartItems, editMode } = this.data;

    if (editMode) {
      wx.showToast({ title: '编辑模式下不可调整数量', icon: 'none', duration: 1500 });
      return;
    }

    const index = cartItems.findIndex((item) => item.id === id);
    if (index === -1) return;
    const item = cartItems[index];
    if (item.stock <= 0) {
      wx.showToast({ title: '暂无库存', icon: 'none', duration: 1500 });
      return;
    }
    if (item.quantity >= item.stock) {
      wx.showToast({ title: `库存仅剩${item.stock}件`, icon: 'none', duration: 1500 });
      return;
    }
    const newQuantity = item.quantity + 1;
    this.setData({
      [`cartItems[${index}].quantity`]: newQuantity
    }, () => {
      this.calculateTotalAndSelectState();
      this.syncToGlobal();
    });
  },

  decreaseQuantity(e) {
    const { id } = e.currentTarget.dataset;
    const { cartItems, editMode } = this.data;

    if (editMode) {
      wx.showToast({ title: '编辑模式下不可调整数量', icon: 'none', duration: 1500 });
      return;
    }

    const index = cartItems.findIndex((item) => item.id === id);
    if (index === -1) return;
    const item = cartItems[index];
    if (item.quantity <= 1) {
      wx.showToast({ title: '商品数量不能小于1', icon: 'none', duration: 1500 });
      return;
    }
    const newQuantity = item.quantity - 1;
    this.setData({
      [`cartItems[${index}].quantity`]: newQuantity
    }, () => {
      this.calculateTotalAndSelectState();
      this.syncToGlobal();
    });
  },

  onTouchStart(e) {
    const { id } = e.currentTarget.dataset;
    const touch = e.touches[0];
    this.data.startX = touch.clientX;
    this.data.currentSlideId = id;
    this.closeOtherSlides(id);
  },

  onTouchMove(e) {
    const { id } = e.currentTarget.dataset;
    if (id !== this.data.currentSlideId) return;
    const touch = e.touches[0];
    const moveX = (touch.clientX - this.data.startX) * this.data.rpxRatio;
    const { cartItems } = this.data;
    const index = cartItems.findIndex((item) => item.id === id);
    if (index === -1) return;

    let offset = moveX < 0 ? Math.abs(moveX) : 0;
    offset = Math.min(offset, 160);
    this.setData({
      [`cartItems[${index}].slideOffset`]: offset,
      slideTransition: false
    });
  },

  onTouchEnd(e) {
    const { id } = e.currentTarget.dataset;
    if (id !== this.data.currentSlideId) return;
    const { cartItems, slideThreshold } = this.data;
    const index = cartItems.findIndex((item) => item.id === id);
    if (index === -1) return;
    const currentOffset = cartItems[index].slideOffset;
    const finalOffset = currentOffset >= slideThreshold ? 160 : 0;
    this.setData({
      [`cartItems[${index}].slideOffset`]: finalOffset,
      slideTransition: true
    });
    this.data.currentSlideId = null;
  },

  closeOtherSlides(currentId) {
    const { cartItems } = this.data;
    const updates = {};
    let needUpdate = false;
    cartItems.forEach((item, idx) => {
      if (item.id !== currentId && item.slideOffset !== 0) {
        updates[`cartItems[${idx}].slideOffset`] = 0;
        needUpdate = true;
      }
    });
    if (needUpdate) {
      this.setData(updates);
    }
  },

  deleteItem(e) {
    const { id } = e.currentTarget.dataset;
    const { cartItems } = this.data;
    const index = cartItems.findIndex((item) => item.id === id);
    if (index === -1) return;
    const itemName = cartItems[index].name || '商品';

    this.setData({
      [`cartItems[${index}].slideOffset`]: 0
    }, () => {
      wx.showModal({
        title: '确认删除',
        content: `确定删除“${itemName}”吗？`,
        success: (res) => {
          if (res.confirm) {
            const newCartItems = cartItems.filter((item) => item.id !== id);
            this.setData({ cartItems: newCartItems }, () => {
              this.calculateTotalAndSelectState();
              this.syncToGlobal();
              wx.showToast({ title: '已删除', icon: 'success', duration: 1500 });

              if (newCartItems.length === 0 && this.data.editMode) {
                this.setData({ editMode: false });
              }
            });
          }
        }
      });
    });
  },

  onScroll() {
    if (this.data.scrollTimer) clearTimeout(this.data.scrollTimer);
    this.data.scrollTimer = setTimeout(() => {
      if (this.data.currentSlideId) {
        this.closeOtherSlides(null);
        this.data.currentSlideId = null;
      }
    }, 200);
  },

  toggleEditMode() {
    const editMode = !this.data.editMode;
    this.setData({ editMode });
    if (!editMode) {
      this.closeOtherSlides(null);
    }
  },

  onBatchDelete() {
    const { selectedCount, cartItems } = this.data;
    if (selectedCount === 0) return;
    wx.showModal({
      title: '确认删除',
      content: `确定删除选中的 ${selectedCount} 件商品吗？`,
      success: (res) => {
        if (res.confirm) {
          const newItems = cartItems.filter((item) => !item.selected);
          this.setData({ cartItems: newItems }, () => {
            this.calculateTotalAndSelectState();
            this.syncToGlobal();
            wx.showToast({ title: '删除成功', icon: 'success', duration: 1500 });
            if (newItems.length === 0) {
              this.setData({ editMode: false });
            }
          });
        }
      }
    });
  },

  onImageError(e) {
    const { index } = e.currentTarget.dataset;
    this.setData({
      [`cartItems[${index}].image`]: ''
    });
  },

  onCheckout() {
    if (this.data.selectedCount === 0) return;

    const selectedItems = this.data.cartItems.filter((item) => item.selected && item.stock > 0);
    if (selectedItems.length === 0) {
      wx.showToast({ title: '暂无可结算商品', icon: 'none', duration: 1500 });
      return;
    }

    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '请先设置用户ID', icon: 'none', duration: 1500 });
      return;
    }
    const merchantId = selectedItems[0].merchantId || 1;
    const payload = {
      userId,
      merchantId,
      receiverName: '默认收货人',
      receiverPhone: '13800000000',
      receiverAddress: '默认收货地址',
      items: selectedItems.map((item) => ({
        goodsId: item.id,
        quantity: item.quantity
      }))
    };

    post('/order/submit', payload, { retry: 0 })
      .then(() => {
        const remainItems = this.data.cartItems.filter((item) => !item.selected);
        this.setData({ cartItems: remainItems, editMode: false }, () => {
          this.calculateTotalAndSelectState();
          this.syncToGlobal();
        });
        wx.showToast({ title: '下单成功', icon: 'success', duration: 1500 });
      })
      .catch((error) => {
        showRequestError(error, '下单失败');
      });
  },

  goShopping() {
    wx.switchTab({ url: '/pages/category/category' });
  },

  goToDetail(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  }
});

