const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    id: null,
    detail: null,
    seasonalContextText: '',
    selectedSkuId: 0,
    selectedSkuIndex: 0,
    selectedSku: null,
    loading: false,
    loadError: false,
    quantity: 1,
    commentSummary: null,
    commentList: [],
    commentPage: 1,
    commentPageSize: 10,
    commentHasMore: false,
    commentLoading: false,
    sourceType: '',
    sourceScene: '',
    seasonalBadgeText: '',
    seasonalWindowText: '',
    seasonalTipText: '',
    seasonalUrgencyText: ''
  },

  onLoad(options) {
    const id = Number(options.id || 0);
    if (!id) {
      wx.showToast({ title: '商品参数错误', icon: 'none' });
      return;
    }
    this.setData({
      id,
      sourceType: `${options.sourceType || ''}`.trim().toUpperCase(),
      sourceScene: `${options.sourceScene || ''}`.trim()
    });
    this.loadDetail();
    this.loadCommentSummary();
    this.loadCommentList(true);
  },

  onShow() {
    const refreshGoodsId = Number(wx.getStorageSync('commentRefreshGoodsId') || 0);
    if (refreshGoodsId && refreshGoodsId === Number(this.data.id || 0)) {
      wx.removeStorageSync('commentRefreshGoodsId');
      this.loadCommentSummary();
      this.loadCommentList(true);
    }
  },

  loadDetail() {
    this.setData({ loading: true, loadError: false });
    get('/goods/detail', { id: this.data.id }, { retry: 0 })
      .then((res) => {
        const detail = (res && res.data) || null;
        if (!detail || !detail.id || Number(detail.status) === 0) {
          this.setData({ detail: null, selectedSkuId: 0, selectedSku: null, quantity: 1 });
          return;
        }
        const firstSku = this.getFirstAvailableSku(detail);
        this.setData({
          detail,
          seasonalContextText: this.buildSeasonalContextText(detail),
          seasonalBadgeText: this.buildSeasonalBadgeText(detail),
          seasonalWindowText: this.buildSeasonalWindowText(detail),
          seasonalTipText: this.buildSeasonalTipText(detail),
          seasonalUrgencyText: this.buildSeasonalUrgencyText(detail),
          selectedSkuId: Number((firstSku && firstSku.id) || 0),
          selectedSkuIndex: this.resolveSkuIndex(detail, Number((firstSku && firstSku.id) || 0)),
          selectedSku: firstSku,
          quantity: 1
        });
      })
      .catch((error) => {
        this.setData({ detail: null, loadError: true });
        showRequestError(error, '商品加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onInputQuantity(e) {
    const stock = this.getCurrentStock();
    let value = Number(e.detail.value || 1);
    if (!Number.isFinite(value) || value <= 0) value = 1;
    if (stock > 0 && value > stock) value = stock;
    this.setData({ quantity: value });
  },

  onMinus() {
    const next = Math.max(1, Number(this.data.quantity || 1) - 1);
    this.setData({ quantity: next });
  },

  onPlus() {
    const stock = this.getCurrentStock();
    const current = Number(this.data.quantity || 1);
    if (stock > 0 && current >= stock) {
      wx.showToast({ title: '已达库存上限', icon: 'none' });
      return;
    }
    this.setData({ quantity: current + 1 });
  },

  onAddCart() {
    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    const addQty = Number(this.data.quantity || 1);
    const selectedSku = this.getSelectedSku(detail, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '请选择可用规格', icon: 'none' });
      return;
    }
    app.requireLogin({ redirect: `/pages/goodsDetail/goodsDetail?id=${this.data.id}`, message: '正在登录，请稍候' })
      .then(() => this.recheckGoodsAvailability(detail.id, addQty))
      .then((freshDetail) => {
        const freshSku = this.getSelectedSku(freshDetail, this.data.selectedSkuId);
        if (!freshSku || Number(freshSku.skuStock || 0) < addQty) {
          throw new Error('规格库存不足，请调整数量');
        }
        return post(`/cart/add?goodsId=${freshDetail.id}&skuId=${freshSku.id}&quantity=${addQty}${this.buildSourceQuery()}`, {}, { retry: 0 });
      })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success' });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
          return;
        }
        showRequestError(error, error.message || '商品状态已变更，请重试');
      });
  },

  onBuyNow() {
    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    const buyQty = Number(this.data.quantity || 1);
    const selectedSku = this.getSelectedSku(detail, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '请选择可用规格', icon: 'none' });
      return;
    }
    app.requireLogin({ redirect: `/pages/goodsDetail/goodsDetail?id=${this.data.id}`, message: '正在登录，请稍候' })
      .then(() => this.recheckGoodsAvailability(detail.id, buyQty))
      .then((freshDetail) => {
        const freshSku = this.getSelectedSku(freshDetail, this.data.selectedSkuId);
        if (!freshSku || Number(freshSku.skuStock || 0) < buyQty) {
          throw new Error('规格库存不足，请调整数量');
        }
        wx.setStorageSync('checkoutItems', [{
          id: freshDetail.id,
          skuId: freshSku.id,
          name: freshDetail.name,
          image: freshDetail.mainImage || '',
          price: freshSku.skuPrice || freshDetail.price,
          skuName: freshSku.skuName || '',
          skuWeightG: Number(freshSku.skuWeightG || 0),
          quantity: buyQty,
          sourceType: this.data.sourceType || 'NORMAL',
          sourceScene: this.data.sourceScene || ''
        }]);
        wx.navigateTo({ url: '/pages/checkout/checkout' });
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
          return;
        }
        showRequestError(error, error.message || '商品状态已变更，请重试');
      });
  },

  recheckGoodsAvailability(goodsId, expectQty) {
    return get('/goods/detail', { id: goodsId }, { retry: 0 }).then((res) => {
      const fresh = (res && res.data) || null;
      if (!fresh || !fresh.id || Number(fresh.status) !== 1) {
        throw new Error('商品已下架');
      }
      const selectedSku = this.getSelectedSku(fresh, this.data.selectedSkuId);
      if (!selectedSku || Number(selectedSku.skuStock || 0) < Number(expectQty || 1)) {
        throw new Error('规格库存不足，请调整数量');
      }
      this.setData({ detail: fresh, selectedSku });
      return fresh;
    });
  },

  buildSeasonalContextText(detail = {}) {
    if (`${this.data.sourceType || ''}` !== 'SEASONAL') return '';
    const keywords = `${detail.keywords || ''}`;
    if (keywords.includes('春季')) return '当前为春季时令推荐，适合本周尝鲜采购';
    if (keywords.includes('夏季')) return '当前为夏季时令推荐，口感更偏清爽多汁';
    if (keywords.includes('秋季')) return '当前为秋季时令推荐，适合应季补给';
    if (keywords.includes('冬季')) return '当前为冬季时令推荐，适合当季稳定供应';
    return '来自当季精选专区，建议优先选择当前赏味期商品';
  },

  buildSeasonalBadgeText(detail = {}) {
    if (`${this.data.sourceType || ''}` !== 'SEASONAL') return '';
    const start = Number(detail.seasonStartMonth || 0);
    const end = Number(detail.seasonEndMonth || 0);
    if (start > 0 && end > 0) {
      return start <= end ? `${start}-${end}月当季供应` : `${start}月至次年${end}月当季供应`;
    }
    return '当季精选商品';
  },

  buildSeasonalWindowText(detail = {}) {
    const start = Number(detail.seasonStartMonth || 0);
    const end = Number(detail.seasonEndMonth || 0);
    if (start > 0 && end > 0) {
      return start <= end ? `当前供应窗口：${start}-${end}月` : `当前供应窗口：${start}月至次年${end}月`;
    }
    return '';
  },

  buildSeasonalTipText(detail = {}) {
    return `${detail.seasonPeakHint || detail.seasonEarlyHint || detail.seasonLateHint || ''}`.trim();
  },

  buildSeasonalUrgencyText(detail = {}) {
    const text = `${detail.seasonLateHint || ''}`.trim();
    if (!text) return '';
    return text.includes('临近') || text.includes('尽快') || text.includes('过季') ? text : '';
  },

  onSelectSku(e) {
    const skuId = Number(e.currentTarget.dataset.skuid || 0);
    if (!skuId) return;
    const sku = this.getSelectedSku(this.data.detail, skuId);
    if (!sku || Number(sku.status) !== 1) return;
    const stock = Number(sku.skuStock || 0);
    const quantity = Math.min(Math.max(1, Number(this.data.quantity || 1)), stock > 0 ? stock : 1);
    this.setData({
      selectedSkuId: skuId,
      selectedSkuIndex: this.resolveSkuIndex(this.data.detail, skuId),
      selectedSku: sku,
      quantity
    });
  },

  onPickerSkuChange(e) {
    const index = Number((e && e.detail && e.detail.value) || 0);
    const list = Array.isArray(this.data.detail && this.data.detail.skuList) ? this.data.detail.skuList : [];
    const sku = list[index];
    if (!sku) return;
    const skuId = Number(sku.id || 0);
    if (!skuId) return;
    this.onSelectSku({ currentTarget: { dataset: { skuid: skuId } } });
  },

  getFirstAvailableSku(detail = {}) {
    const list = Array.isArray(detail.skuList) ? detail.skuList : [];
    const enabled = list.filter((sku) => Number(sku.status) === 1);
    if (!enabled.length) return null;
    const sorted = enabled.slice().sort((a, b) => Number(a.sort || 0) - Number(b.sort || 0));
    return sorted[0];
  },

  getSelectedSku(detail = {}, selectedSkuId = 0) {
    const list = Array.isArray(detail.skuList) ? detail.skuList : [];
    const skuId = Number(selectedSkuId || 0);
    if (skuId > 0) {
      const matched = list.find((sku) => Number(sku.id) === skuId);
      if (matched) return matched;
    }
    return this.getFirstAvailableSku(detail);
  },

  resolveSkuIndex(detail = {}, skuId = 0) {
    const list = Array.isArray(detail.skuList) ? detail.skuList : [];
    const target = Number(skuId || 0);
    if (!target) return 0;
    const index = list.findIndex((item) => Number(item.id) === target);
    return index >= 0 ? index : 0;
  },

  getCurrentStock() {
    const sku = this.getSelectedSku(this.data.detail, this.data.selectedSkuId);
    if (sku) return Number(sku.skuStock || 0);
    return Number((this.data.detail && this.data.detail.stock) || 0);
  },

  loadCommentSummary() {
    if (!this.data.id) return;
    get('/comment/summary', { goodsId: this.data.id }, { retry: 0 })
      .then((res) => {
        const summary = (res && res.data) || {};
        this.setData({ commentSummary: summary });
      })
      .catch(() => {
        this.setData({ commentSummary: null });
      });
  },

  loadCommentList(reset = false) {
    if (!this.data.id) return;
    if (this.data.commentLoading) return;
    const nextPage = reset ? 1 : Number(this.data.commentPage || 1);
    this.setData({ commentLoading: true });
    get('/comment/list', {
      goodsId: this.data.id,
      page: nextPage,
      pageSize: this.data.commentPageSize
    }, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        const list = Array.isArray(data.list) ? data.list : [];
        const merged = reset ? list : (this.data.commentList || []).concat(list);
        this.setData({
          commentList: merged,
          commentPage: Number(data.page || nextPage) + 1,
          commentHasMore: !!data.hasMore
        });
      })
      .catch(() => {
        if (reset) {
          this.setData({ commentList: [], commentHasMore: false, commentPage: 1 });
        }
      })
      .finally(() => {
        this.setData({ commentLoading: false });
      });
  },

  onLoadMoreComments() {
    if (!this.data.commentHasMore || this.data.commentLoading) return;
    this.loadCommentList(false);
  },

  buildSourceQuery() {
    const sourceType = `${this.data.sourceType || ''}`.trim().toUpperCase();
    const sourceScene = `${this.data.sourceScene || ''}`.trim();
    const query = [];
    if (sourceType) query.push(`sourceType=${encodeURIComponent(sourceType)}`);
    if (sourceScene) query.push(`sourceScene=${encodeURIComponent(sourceScene)}`);
    return query.length ? `&${query.join('&')}` : '';
  }
});
