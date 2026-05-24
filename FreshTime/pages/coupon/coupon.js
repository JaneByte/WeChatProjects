const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    availableList: [],
    recommendGoodsList: [],
    leftColumnList: [],
    rightColumnList: [],
    loading: false,
    loadError: false,
    claimLoadingId: 0,
    selectedSkuId: 0,
    addCartLoadingId: 0,
    specPopupVisible: false,
    specGoods: null,
    specDisplayPrice: '0.00'
  },

  onShow() {
    this.loadData();
  },

  loadData() {
    this.loadAvailableList();
    this.loadRecommendGoods();
  },

  splitGoodsColumns(list) {
    const leftColumnList = [];
    const rightColumnList = [];
    (Array.isArray(list) ? list : []).forEach((item, index) => {
      if (index % 2 === 0) leftColumnList.push(item);
      else rightColumnList.push(item);
    });
    return { leftColumnList, rightColumnList };
  },

  normalizeGoodsList(list) {
    const normalized = (Array.isArray(list) ? list : []).map((item) => {
      const price = Number(item.price || item.payPrice || 0);
      const skuList = Array.isArray(item.skuList) ? item.skuList : [];
      const firstSku = this.getFirstAvailableSku({ skuList });
      const priceNum = Number((firstSku && firstSku.skuPrice) || item.price || item.payPrice || 0);
      return {
        ...item,
        image: item.mainImage || item.image || '',
        mainImage: item.mainImage || item.image || '',
        unit: item.unit || '份',
        desc: item.desc || '领券后下单更划算',
        price: priceNum.toFixed(2),
        originPrice: priceNum,
        skuList
      };
    });
    const cols = this.splitGoodsColumns(normalized);
    this.setData({
      recommendGoodsList: normalized,
      leftColumnList: cols.leftColumnList,
      rightColumnList: cols.rightColumnList
    });
  },

  loadAvailableList() {
    if (!app.getUserId()) {
      this.setData({ availableList: [] });
      return;
    }
    get('/coupon/available', {}, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ availableList: Array.isArray(list) ? list.slice(0, 5) : [] });
      })
      .catch(() => this.setData({ availableList: [] }));
  },

  loadRecommendGoods() {
    if (!app.getUserId()) {
      this.loadHotGoodsFallback();
      return;
    }
    this.setData({ loading: true });
    get('/order/list', { limit: 10 }, { retry: 0 })
      .then((res) => {
        const list = Array.isArray((res && res.data) || []) ? res.data : [];
        const goodsMap = {};
        const goodsList = [];
        list.forEach((order) => {
          const items = Array.isArray(order.items) ? order.items : [];
          items.forEach((row) => {
            const goodsId = Number(row.goodsId || row.id || 0);
            if (!goodsId || goodsMap[goodsId]) return;
            goodsMap[goodsId] = true;
            goodsList.push({
              id: goodsId,
              name: row.goodsName || row.name || '商品',
              price: row.price || row.payPrice || 0,
              mainImage: row.mainImage || row.image || '',
              unit: row.unit || '份'
            });
          });
        });
        if (goodsList.length > 0) {
          this.normalizeGoodsList(goodsList.slice(0, 6));
          this.setData({
            loadError: false
          });
          return;
        }
        this.loadHotGoodsFallback();
      })
      .catch(() => this.loadHotGoodsFallback())
      .finally(() => this.setData({ loading: false }));
  },

  loadHotGoodsFallback() {
    get('/home/goods', { page: 1, pageSize: 6 }, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        const list = Array.isArray(data.list) ? data.list : [];
        this.normalizeGoodsList(list.slice(0, 6));
        this.setData({
          loadError: false
        });
      })
      .catch((error) => {
        this.setData({
          recommendGoodsList: [],
          leftColumnList: [],
          rightColumnList: [],
          loadError: true
        });
        showRequestError(error, '推荐商品加载失败');
      });
  },

  onClaimTap(e) {
    const couponId = Number(e.currentTarget.dataset.id || 0);
    if (!couponId || this.data.claimLoadingId) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/coupon/coupon' }).catch(() => {});
      return;
    }
    this.setData({ claimLoadingId: couponId });
    post('/coupon/claim', { couponId }, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '领取成功', icon: 'success' });
        this.loadData();
      })
      .catch((error) => showRequestError(error, '领取失败'))
      .finally(() => this.setData({ claimLoadingId: 0 }));
  },

  onTapGoods(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  },

  onGoodsCardTap(e) {
    const item = (e && e.detail && e.detail.item) || null;
    if (!item || !item.id) return;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${item.id}` });
  },

  onGoodsCardAdd(e) {
    const item = (e && e.detail && e.detail.item) || null;
    if (!item || !item.id) return;
    this.onAddCart({ currentTarget: { dataset: { id: item.id } } });
  },

  onSpecTap() {},

  onAddCart(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id || this.data.addCartLoadingId) return;
    const target = (this.data.recommendGoodsList || []).find((item) => Number(item.id) === id) || null;
    if (!target) return;
    this.setData({
      specPopupVisible: true,
      specGoods: target,
      selectedSkuId: Number((this.getFirstAvailableSku(target) || {}).id || 0)
    }, () => this.refreshSpecDisplayPrice());
  },

  onCloseSpecPopup() {
    if (this.data.addCartLoadingId) return;
    this.setData({
      specPopupVisible: false,
      specGoods: null,
      selectedSkuId: 0,
      specDisplayPrice: '0.00'
    });
  },

  onSelectSku(e) {
    const skuId = Number(e.currentTarget.dataset.skuid || 0);
    if (!skuId) return;
    this.setData({ selectedSkuId: skuId }, () => this.refreshSpecDisplayPrice());
  },

  onConfirmSpecAdd() {
    const target = this.data.specGoods;
    if (!target || !target.id || this.data.addCartLoadingId) return;
    const selectedSku = this.getSelectedSku(target, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '该规格库存不足', icon: 'none' });
      return;
    }
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/coupon/coupon' }).catch(() => {});
      return;
    }
    this.setData({ addCartLoadingId: Number(target.id) });
    post(`/cart/add?goodsId=${target.id}&skuId=${selectedSku.id}&quantity=1`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success' });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
        this.setData({
          specPopupVisible: false,
          specGoods: null,
          selectedSkuId: 0,
          specDisplayPrice: '0.00'
        });
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
          return;
        }
        showRequestError(error, '加入购物车失败');
      })
      .finally(() => this.setData({ addCartLoadingId: 0 }));
  },

  getFirstAvailableSku(item = {}) {
    const list = Array.isArray(item.skuList) ? item.skuList : [];
    const enabled = list.filter((sku) => Number(sku.status) === 1);
    if (!enabled.length) return null;
    const sorted = enabled.slice().sort((a, b) => Number(a.sort || 0) - Number(b.sort || 0));
    return sorted[0];
  },

  getSelectedSku(item = {}, selectedSkuId = 0) {
    const list = Array.isArray(item.skuList) ? item.skuList : [];
    const skuId = Number(selectedSkuId || 0);
    if (skuId > 0) {
      const matched = list.find((sku) => Number(sku.id) === skuId);
      if (matched) return matched;
    }
    return this.getFirstAvailableSku(item);
  },

  refreshSpecDisplayPrice() {
    const target = this.data.specGoods;
    if (!target) {
      this.setData({ specDisplayPrice: '0.00' });
      return;
    }
    const selectedSku = this.getSelectedSku(target, this.data.selectedSkuId);
    const price = Number((selectedSku && selectedSku.skuPrice) || target.originPrice || target.price || 0);
    this.setData({ specDisplayPrice: price.toFixed(2) });
  },

  noop() {},

  onOpenMyCoupon() {
    wx.navigateTo({ url: '/pages/coupon-mine/coupon-mine' });
  }
});
