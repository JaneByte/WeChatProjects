// app.js
App({
  onLaunch() {
    wx.cloud.init({
      env: 'cloudbase-0gymwbii3e34c141',
      traceUser: true
    });

    this.initUserId();
    this.initCartData();
  },

  globalData: {
    userId: null,
    cartList: []
  },

  initUserId() {
    try {
      const localUserId = wx.getStorageSync('userId');
      if (localUserId !== '' && localUserId !== null && localUserId !== undefined) {
        this.globalData.userId = Number(localUserId);
      }
    } catch (error) {
      this.globalData.userId = null;
    }
  },

  setUserId(userId) {
    const normalized = Number(userId);
    if (!Number.isFinite(normalized) || normalized <= 0) {
      return false;
    }
    this.globalData.userId = normalized;
    wx.setStorageSync('userId', normalized);
    return true;
  },

  getUserId() {
    return this.globalData.userId;
  },

  clearUserId() {
    this.globalData.userId = null;
    wx.removeStorageSync('userId');
  },

  initCartData() {
    try {
      const localCart = wx.getStorageSync('cartList');
      if (localCart && Array.isArray(localCart)) {
        this.globalData.cartList = localCart;
      }
    } catch (error) {
      this.globalData.cartList = [];
    }
  },

  updateCartBadge() {
    if (typeof wx.setTabBarBadge !== 'function') return;

    const { cartList } = this.globalData;
    const totalCount = cartList.reduce((sum, item) => sum + (item.quantity || 0), 0);

    if (totalCount > 0) {
      wx.setTabBarBadge({
        index: 2,
        text: `${totalCount}`,
        fail: () => {}
      });
    } else {
      wx.removeTabBarBadge({
        index: 2,
        fail: () => {}
      });
    }
  },

  syncCartToStorage() {
    try {
      wx.setStorageSync('cartList', this.globalData.cartList);
      this.updateCartBadge();
    } catch (error) {
      // noop
    }
  }
});
