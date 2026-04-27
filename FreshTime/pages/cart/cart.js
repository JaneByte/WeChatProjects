// cart.js
// 购物车逻辑 · 100%对齐分类页规范 · 全问题修复
const app = getApp(); // 与分类页统一的全局实例获取方式
Page({
  // ==================== 页面数据 ====================
  data: {
    cartItems: [],
    allSelected: false,
    totalPrice: 0,
    selectedCount: 0,
    editMode: false,
    scrollTimer: null,
    // 左滑交互
    slideTransition: true,
    startX: 0,
    currentSlideId: null,
    slideThreshold: 100,
    rpxRatio: 1
  },
  // ==================== 生命周期 ====================
  onLoad() {
    const systemInfo = wx.getSystemInfoSync();
    this.data.rpxRatio = 750 / systemInfo.screenWidth;
    this.loadCartData();
  },
  onShow() {
    this.loadCartData();
    // 进入页面更新角标
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
    // 清理定时器，防止内存泄漏
    if (this.data.scrollTimer) {
      clearTimeout(this.data.scrollTimer);
      this.data.scrollTimer = null;
    }
  },
  // ==================== 数据初始化 ====================
  loadCartData() {
    // 从全局读取购物车数据，100%保留selected选中状态
    const globalCart = app?.globalData?.cartList || [];
    
    // 商品去重合并
    const cartMap = new Map();
    globalCart.forEach(item => {
      if (cartMap.has(item.id)) {
        const existItem = cartMap.get(item.id);
        existItem.quantity = (existItem.quantity || 1) + (item.quantity || 1);
        existItem.stock = Math.min(
          existItem.stock !== undefined ? existItem.stock : 999,
          item.stock !== undefined ? item.stock : 999
        );
        // 保留用户的选中状态
        existItem.selected = existItem.selected ?? item.selected ?? true;
      } else {
        cartMap.set(item.id, { ...item });
      }
    });

    // 处理字段，保留selected状态
    const cartItems = Array.from(cartMap.values()).map(item => ({
      ...item,
      slideOffset: 0,
      stock: item.stock !== undefined ? item.stock : 999,
      quantity: item.quantity || 1,
      selected: item.selected !== undefined ? item.selected : true, // 仅undefined时才默认true
      unit: item.unit || '份',
      desc: item.desc || '',
      image: item.image || ''
    }));

    this.setData({ cartItems }, () => {
      this.calculateTotalAndSelectState();
    });
  },
  // ==================== 计算总价 & 全选状态（修复异步逻辑错误） ====================
  calculateTotalAndSelectState() {
    let { cartItems } = this.data;
    let total = 0;
    let selectedCount = 0;
    const updates = {};
    let hasUpdate = false;

    // 1. 先处理售罄商品，强制取消选中
    cartItems = cartItems.map((item, idx) => {
      if (item.stock <= 0 && item.selected) {
        updates[`cartItems[${idx}].selected`] = false;
        hasUpdate = true;
        return { ...item, selected: false };
      }
      return item;
    });

    // 2. 有更新先同步到data
    if (hasUpdate) {
      this.setData(updates);
    }

    // 3. 用处理后的最新数据统计
    const validItems = cartItems.filter(item => item.stock > 0);
    let allSelected = validItems.length > 0;

    cartItems.forEach(item => {
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
  // ==================== 同步全局购物车（修复：保留selected字段） ====================
  syncToGlobal() {
    const { cartItems } = this.data;
    // 仅过滤UI相关的slideOffset，保留selected字段
    const pureCart = cartItems.map(({ slideOffset, ...rest }) => rest);
    app.globalData.cartList = pureCart;
    app.syncCartToStorage();
  },
  // ==================== 复选框事件 ====================
  toggleSelect(e) {
    const { id } = e.currentTarget.dataset;
    const { cartItems } = this.data;
    const index = cartItems.findIndex(item => item.id === id);
    if (index === -1) return;
    const item = cartItems[index];

    if (item.stock <= 0) {
      wx.showToast({ title: '商品已售罄', icon: 'none', duration: 1500 });
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
  // ==================== 数量调整 ====================
  increaseQuantity(e) {
    const { id } = e.currentTarget.dataset;
    const { cartItems, editMode } = this.data;

    if (editMode) {
      wx.showToast({ title: '编辑模式下不可调整数量', icon: 'none', duration: 1500 });
      return;
    }

    const index = cartItems.findIndex(item => item.id === id);
    if (index === -1) return;
    const item = cartItems[index];
    if (item.stock <= 0) {
      wx.showToast({ title: '商品已售罄', icon: 'none', duration: 1500 });
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

    const index = cartItems.findIndex(item => item.id === id);
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
  // ==================== 左滑删除逻辑 ====================
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
    const index = cartItems.findIndex(item => item.id === id);
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
    const index = cartItems.findIndex(item => item.id === id);
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
    const index = cartItems.findIndex(item => item.id === id);
    if (index === -1) return;
    const itemName = cartItems[index].name || '商品';

    this.setData({
      [`cartItems[${index}].slideOffset`]: 0
    }, () => {
      wx.showModal({
        title: '确认删除',
        content: `确定删除「${itemName}」吗？`,
        success: (res) => {
          if (res.confirm) {
            const newCartItems = cartItems.filter(item => item.id !== id);
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
  // ==================== 编辑模式 ====================
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
          const newItems = cartItems.filter(item => !item.selected);
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
  // ==================== 图片加载失败兜底 ====================
  onImageError(e) {
    const { index } = e.currentTarget.dataset;
    // 替换为你的默认兜底图路径
    this.setData({
      [`cartItems[${index}].image`]: ''
    });
  },
  // ==================== 结算 ====================
  onCheckout() {
    if (this.data.selectedCount === 0) return;
    wx.showToast({ title: '结算功能开发中', icon: 'none', duration: 1500 });
  },
  // ==================== 导航跳转 ====================
  goShopping() {
    wx.switchTab({ url: '/pages/category/category' });
  },
  goToDetail(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  }
});