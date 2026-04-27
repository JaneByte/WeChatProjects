// app.js
App({
  onLaunch: function () {
    // 全局唯一云环境初始化
    wx.cloud.init({
      env: 'cloudbase-0gymwbii3e34c141',
      traceUser: true
    });
    // 仅初始化购物车数据，不操作tabbar，避免启动报错
    this.initCartData();
  },

  // 全局数据管理（分类页、购物车页统一读写）
  globalData: {
    cartList: [], // 购物车核心数据池
  },

  // ==================== 购物车全局统一方法 ====================
  /**
   * 初始化购物车：从本地缓存读取历史数据，冷启动不丢失加购商品
   */
  initCartData() {
    try {
      const localCart = wx.getStorageSync('cartList');
      if (localCart && Array.isArray(localCart)) {
        this.globalData.cartList = localCart;
      }
    } catch (e) {
      console.warn('购物车缓存读取失败', e);
      this.globalData.cartList = [];
    }
  },

  /**
   * 更新tabbar购物车角标（自动计算商品总数量）
   * 已匹配你的tabbar配置：购物车是第3个tab，索引为2
   */
  updateCartBadge() {
    // 安全兜底：判断API是否可用，避免初始化时报错
    if (typeof wx.setTabBarBadge !== 'function') return;
    const { cartList } = this.globalData;
    // 计算购物车商品总件数
    const totalCount = cartList.reduce((sum, item) => sum + (item.quantity || 0), 0);
    
    if (totalCount > 0) {
      wx.setTabBarBadge({
        index: 2,
        text: totalCount.toString(),
        fail: (err) => console.warn('tabbar角标设置失败', err)
      });
    } else {
      wx.removeTabBarBadge({
        index: 2,
        fail: () => {}
      });
    }
  },

  /**
   * 同步购物车数据到本地缓存
   * 自动同步全局数据+本地缓存+tabbar角标，三端统一
   */
  syncCartToStorage() {
    try {
      wx.setStorageSync('cartList', this.globalData.cartList);
      this.updateCartBadge();
    } catch (e) {
      console.warn('购物车缓存写入失败', e);
    }
  }
})