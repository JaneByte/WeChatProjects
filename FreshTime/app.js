// app.js
const { get, post, TOKEN_STORAGE_KEY } = require('./utils/request');

const USER_ID_KEY = 'userId';
const LOGIN_PROFILE_KEY = 'loginProfile';
const MANUAL_LOGOUT_KEY = 'manualLogout';
const DEFAULT_AVATAR = '/assets/icon/my.png';
const DEFAULT_NICKNAME_PREFIX = '微信用户';

App({
  onLaunch() {
    wx.cloud.init({
      env: 'cloudbase-0gymwbii3e34c141',
      traceUser: true
    });

    this.initUserId();
    this.initToken();
    this.initLoginProfile();
    this.initCartData();
    this.bootstrapLogin({ skipIfLoggedOut: true })
      .catch(() => {})
      .finally(() => {
        this.globalData.loginReady = true;
        if (this.getUserId() && this.getToken()) {
          this.refreshCartBadgeFromServer();
        }
      });
  },

  globalData: {
    userId: null,
    cartList: [],
    loginReady: false,
    token: '',
    loginProfile: null,
    loggingIn: false
  },

  initUserId() {
    try {
      const localUserId = wx.getStorageSync(USER_ID_KEY);
      const token = wx.getStorageSync(TOKEN_STORAGE_KEY) || '';
      if (token && localUserId !== '' && localUserId !== null && localUserId !== undefined) {
        this.globalData.userId = Number(localUserId);
        return;
      }
      wx.removeStorageSync(USER_ID_KEY);
      this.globalData.userId = null;
    } catch (error) {
      this.globalData.userId = null;
    }
  },

  initToken() {
    try {
      this.globalData.token = wx.getStorageSync(TOKEN_STORAGE_KEY) || '';
    } catch (error) {
      this.globalData.token = '';
    }
  },

  initLoginProfile() {
    try {
      const profile = wx.getStorageSync(LOGIN_PROFILE_KEY);
      this.globalData.loginProfile = profile && typeof profile === 'object' ? profile : null;
    } catch (error) {
      this.globalData.loginProfile = null;
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

  setToken(token) {
    const normalized = typeof token === 'string' ? token.trim() : '';
    this.globalData.token = normalized;
    if (normalized) {
      wx.setStorageSync(TOKEN_STORAGE_KEY, normalized);
    } else {
      wx.removeStorageSync(TOKEN_STORAGE_KEY);
    }
  },

  getToken() {
    return this.globalData.token || '';
  },

  setLoginProfile(profile = {}) {
    const nextProfile = {
      nickname: this.resolveNickname(profile.nickname),
      avatar: profile.avatar || DEFAULT_AVATAR,
      openid: profile.openid || ''
    };
    this.globalData.loginProfile = nextProfile;
    wx.setStorageSync(LOGIN_PROFILE_KEY, nextProfile);
    return nextProfile;
  },

  getLoginProfile() {
    return this.globalData.loginProfile;
  },

  buildDefaultNickname(seed = '') {
    const source = typeof seed === 'string' ? seed : `${Date.now()}${Math.random().toString(36).slice(2, 6)}`;
    const suffix = source.replace(/[^0-9a-zA-Z]/g, '').slice(-4).toUpperCase() || `${Math.floor(Math.random() * 9000) + 1000}`;
    return `${DEFAULT_NICKNAME_PREFIX}${suffix}`;
  },

  resolveNickname(nickname, seed = '') {
    const safeNickname = typeof nickname === 'string' ? nickname.trim() : '';
    if (safeNickname) {
      return safeNickname;
    }
    return this.buildDefaultNickname(seed);
  },

  isDefaultProfile(profile = {}) {
    const nickname = typeof profile.nickname === 'string' ? profile.nickname.trim() : '';
    const avatar = typeof profile.avatar === 'string' ? profile.avatar.trim() : '';
    const isDefaultNickname = !!nickname && nickname.startsWith(DEFAULT_NICKNAME_PREFIX);
    const isDefaultAvatar = !avatar || avatar === DEFAULT_AVATAR;
    return isDefaultNickname || isDefaultAvatar;
  },

  markManualLogout(flag) {
    try {
      if (flag) {
        wx.setStorageSync(MANUAL_LOGOUT_KEY, 1);
      } else {
        wx.removeStorageSync(MANUAL_LOGOUT_KEY);
      }
    } catch (error) {
      // noop
    }
  },

  hasManualLogoutFlag() {
    try {
      return wx.getStorageSync(MANUAL_LOGOUT_KEY) === 1;
    } catch (error) {
      return false;
    }
  },

  isLoggedIn() {
    return !!(this.globalData.userId && this.globalData.token);
  },

  isLoggingIn() {
    return !!this.globalData.loggingIn;
  },

  clearLoginState() {
    this.globalData.userId = null;
    this.globalData.token = '';
    this.globalData.loginProfile = null;
    this.globalData.cartList = [];
    this.globalData.loggingIn = false;
    wx.removeStorageSync(USER_ID_KEY);
    wx.removeStorageSync(TOKEN_STORAGE_KEY);
    wx.removeStorageSync(LOGIN_PROFILE_KEY);
    wx.removeStorageSync('cartList');
    wx.removeStorageSync('checkoutItems');
    wx.removeStorageSync('checkoutMeta');
    wx.removeStorageSync('selectedAddress');
    this.updateCartBadge();
    if (typeof wx.removeTabBarBadge === 'function') {
      wx.removeTabBarBadge({ index: 2, fail: () => {} });
    }
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

  refreshCartBadgeFromServer() {
    if (!this.getUserId()) return Promise.resolve();
    return get('/cart/list', {}, { retry: 0 })
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

  bootstrapLogin(options = {}) {
    if (this.loginPromise) return this.loginPromise;
    if (options.skipIfLoggedOut === true && this.hasManualLogoutFlag()) {
      return Promise.reject(new Error('MANUAL_LOGOUT'));
    }

    this.globalData.loggingIn = true;
    this.loginPromise = this.loginByCode()
      .finally(() => {
        this.globalData.loggingIn = false;
        if (this.getUserId() && this.getToken()) {
          this.refreshCartBadgeFromServer();
        }
        this.loginPromise = null;
      });

    return this.loginPromise;
  },

  ensureLoginReady() {
    if (this.isLoggedIn()) return Promise.resolve(this.globalData.userId);
    if (this.hasManualLogoutFlag()) return Promise.resolve(null);
    return this.bootstrapLogin({ skipIfLoggedOut: true })
      .then(() => this.globalData.userId || null)
      .catch(() => null);
  },

  ensureLightLogin(options = {}) {
    if (this.isLoggedIn()) return Promise.resolve(this.globalData.userId);
    const timeoutMs = Number(options.timeoutMs || 1800);
    return Promise.race([
      this.bootstrapLogin({ skipIfLoggedOut: false })
        .then(() => {
          if (!this.isLoggedIn()) throw new Error('LOGIN_REQUIRED');
          return this.globalData.userId;
        }),
      new Promise((_, reject) => {
        setTimeout(() => reject(new Error('LOGIN_TIMEOUT')), timeoutMs);
      })
    ]);
  },

  requireLogin(options = {}) {
    if (this.isLoggedIn()) return Promise.resolve(this.globalData.userId);
    if (this.hasManualLogoutFlag()) {
      if (options.silent !== true) {
        wx.showToast({ title: options.message || '请先登录', icon: 'none', duration: 1500 });
      }
      this.goLoginPage({ redirect: options.redirect || '' });
      return Promise.reject(new Error('MANUAL_LOGOUT'));
    }

    if (!options.silent) {
      wx.showLoading({ title: '登录中', mask: true });
    }

    return this.ensureLightLogin({ timeoutMs: options.timeoutMs || 1800 })
      .catch((error) => {
        if (!options.silent) {
          wx.hideLoading();
        }
        if (options.silent !== true) {
          wx.showToast({ title: options.message || '请先登录', icon: 'none', duration: 1500 });
        }
        this.goLoginPage({ redirect: options.redirect || '' });
        throw error;
      })
      .finally(() => {
        if (!options.silent) {
          wx.hideLoading();
        }
      });
  },

  async loginByCode(profile = {}) {
    const loginRes = await new Promise((resolve, reject) => {
      wx.login({
        success: resolve,
        fail: reject
      });
    });

    const code = (loginRes && loginRes.code) || '';
    if (!code) throw new Error('wx.login failed');

    const data = await this.loginRequest({
      code,
      loginType: 'wechat',
      nickname: this.resolveNickname(profile.nickname, code),
      avatar: profile.avatar || ''
    });
    return data;
  },

  async loginRequest(payload) {
    const res = await post('/auth/login', payload, { retry: 0 });
    const data = (res && res.data) || {};
    if (!data.userId || !data.token) throw new Error('登录失败');
    this.markManualLogout(false);
    this.setUserId(data.userId);
    this.setToken(data.token);
    this.setLoginProfile({
      nickname: this.resolveNickname(data.nickname || payload.nickname, data.openid || payload.openid || payload.code || ''),
      avatar: data.avatar || payload.avatar || DEFAULT_AVATAR,
      openid: data.openid || payload.openid || ''
    });
    return data;
  },

  async updateProfile(profile = {}) {
    const payload = {
      nickname: typeof profile.nickname === 'string' ? profile.nickname.trim() : '',
      avatar: typeof profile.avatar === 'string' ? profile.avatar.trim() : ''
    };
    const res = await post('/auth/profile', payload, { retry: 0 });
    const data = (res && res.data) || {};
    const currentProfile = this.getLoginProfile() || {};
    this.setLoginProfile({
      nickname: this.resolveNickname(data.nickname || payload.nickname || currentProfile.nickname, currentProfile.openid || ''),
      avatar: data.avatar || currentProfile.avatar || DEFAULT_AVATAR,
      openid: data.openid || currentProfile.openid || ''
    });
    if (data.token) {
      this.setToken(data.token);
    }
    return data;
  },

  handleUnauthorized() {
    this.clearLoginState();
    this.goLoginPage();
  },

  goLoginPage(options = {}) {
    if (this.loginPagePending) {
      return;
    }
    const currentPages = getCurrentPages();
    const current = currentPages[currentPages.length - 1];
    if (current && current.route === 'pages/login/login') {
      return;
    }
    this.loginPagePending = true;
    const redirect = options.redirect || '';
    const query = redirect ? `?redirect=${encodeURIComponent(redirect)}` : '';
    wx.navigateTo({
      url: `/pages/login/login${query}`,
      fail: () => {},
      complete: () => {
        this.loginPagePending = false;
      }
    });
  }
});
