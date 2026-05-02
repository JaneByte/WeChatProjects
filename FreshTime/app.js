// app.js
const { get, post } = require('./utils/request');

const USER_ID_KEY = 'userId';
const OPENID_KEY = 'mockOpenid';

App({
  onLaunch() {
    wx.cloud.init({
      env: 'cloudbase-0gymwbii3e34c141',
      traceUser: true
    });

    this.initUserId();
    this.initCartData();
    this.bootstrapLogin();
  },

  globalData: {
    userId: null,
    cartList: [],
    loginReady: false
  },

  initUserId() {
    try {
      const localUserId = wx.getStorageSync(USER_ID_KEY);
      if (localUserId !== '' && localUserId !== null && localUserId !== undefined) {
        this.globalData.userId = Number(localUserId);
      }
    } catch (error) {
      this.globalData.userId = null;
    }
  },

  setUserId(userId) {
    const normalized = Number(userId);
    if (!Number.isFinite(normalized) || normalized <= 0) return false;
    this.globalData.userId = normalized;
    wx.setStorageSync(USER_ID_KEY, normalized);
    return true;
  },

  getUserId() {
    return this.globalData.userId;
  },

  clearUserId() {
    this.globalData.userId = null;
    wx.removeStorageSync(USER_ID_KEY);
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
      wx.setTabBarBadge({ index: 2, text: `${totalCount}`, fail: () => {} });
    } else {
      wx.removeTabBarBadge({ index: 2, fail: () => {} });
    }
  },

  syncCartToStorage() {
    try {
      wx.setStorageSync('cartList', this.globalData.cartList);
      this.updateCartBadge();
    } catch (error) {
      // noop
    }
  },

  refreshCartBadgeFromServer() {
    const userId = this.getUserId();
    if (!userId) return Promise.resolve();
    return get('/cart/list', { userId }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.globalData.cartList = (Array.isArray(list) ? list : []).map((item) => ({
          id: Number(item.goodsId || item.id),
          quantity: Number(item.quantity || 0)
        }));
        this.updateCartBadge();
      })
      .catch(() => {});
  },

  bootstrapLogin() {
    if (this.loginPromise) return this.loginPromise;

    this.loginPromise = this.loginByCode()
      .catch(() => this.loginByStoredOpenid())
      .finally(() => {
        this.globalData.loginReady = true;
        this.refreshCartBadgeFromServer();
      });

    return this.loginPromise;
  },

  ensureLoginReady() {
    if (this.globalData.userId) return Promise.resolve(this.globalData.userId);
    return this.bootstrapLogin().then(() => this.globalData.userId);
  },

  async loginByCode() {
    const loginRes = await new Promise((resolve, reject) => {
      wx.login({
        success: resolve,
        fail: reject
      });
    });

    const code = (loginRes && loginRes.code) || '';
    if (!code) throw new Error('wx.login failed');

    const openid = `wxcode_${code}`;
    const nickname = '微信用户';
    const data = await this.loginRequest(openid, nickname);
    wx.setStorageSync(OPENID_KEY, data.openid || openid);
    return data;
  },

  async loginByStoredOpenid() {
    let openid = '';
    try {
      openid = wx.getStorageSync(OPENID_KEY) || '';
    } catch (error) {
      openid = '';
    }

    if (!openid) {
      openid = `local_${Date.now()}_${Math.random().toString(36).slice(2, 8)}`;
      wx.setStorageSync(OPENID_KEY, openid);
    }

    const data = await this.loginRequest(openid, '游客用户');
    return data;
  },

  async loginRequest(openid, nickname) {
    const res = await post('/auth/login', { openid, nickname }, { retry: 0 });
    const data = (res && res.data) || {};
    if (!data.userId) throw new Error('登录失败');
    this.setUserId(data.userId);
    return data;
  }
});
