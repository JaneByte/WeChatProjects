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
    actionLoading: false,
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
    seasonalUrgencyText: '',
    displayPriceText: '0.00',
    originalPriceText: '',
    showOriginalPrice: false,
    flashSpecLabelText: '标准装',
    flashDisplayPercent: 0,
    flashRemainText: ''
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
    if (this.data.sourceType === 'FLASH') {
      this.syncFlashDisplay(this.data.detail || {});
      this.startFlashCountdown();
    }
  },

  onHide() {
    this.clearFlashCountdown();
  },

  onUnload() {
    this.clearFlashCountdown();
  },

  loadDetail() {
    this.setData({ loading: true });
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
        this.syncPriceDisplay(detail, firstSku);
        this.syncFlashSpecLabel(detail, firstSku);
        this.syncFlashDisplay(detail);
      })
      .catch((error) => {
        this.setData({ detail: null });
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
    if (this.data.actionLoading) return;
    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    const addQty = Number(this.data.quantity || 1);
    const selectedSku = this.getSelectedSku(detail, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '请选择可用规格', icon: 'none' });
      return;
    }
    this.setData({ actionLoading: true });
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
      })
      .finally(() => this.setData({ actionLoading: false }));
  },

  onBuyNow() {
    if (this.data.actionLoading) return;
    const detail = this.data.detail;
    if (!detail || !detail.id) return;
    const buyQty = Number(this.data.quantity || 1);
    const selectedSku = this.getSelectedSku(detail, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '请选择可用规格', icon: 'none' });
      return;
    }
    this.setData({ actionLoading: true });
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
          price: this.getCheckoutPrice(freshDetail, freshSku),
          originPrice: Number((freshSku && freshSku.skuPrice) || freshDetail.price || 0),
          priceType: this.data.sourceType === 'FLASH' && this.isFlashActive(freshDetail) ? 'FLASH' : 'NORMAL',
          flashActive: this.data.sourceType === 'FLASH' && this.isFlashActive(freshDetail),
          skuName: freshSku.skuName || '',
          skuWeightG: Number(freshSku.skuWeightG || 0),
          quantity: buyQty,
          sourceType: this.data.sourceType || 'NORMAL',
          sourceScene: this.data.sourceScene || ''
        }]);
        wx.setStorageSync('checkoutMeta', {
          source: 'direct',
          cartItems: []
        });
        wx.navigateTo({ url: '/pages/checkout/checkout' });
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
          return;
        }
        showRequestError(error, error.message || '商品状态已变更，请重试');
      })
      .finally(() => this.setData({ actionLoading: false }));
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
      this.syncPriceDisplay(fresh, selectedSku);
      this.syncFlashSpecLabel(fresh, selectedSku);
      this.syncFlashDisplay(fresh);
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
    if (this.data.sourceType === 'FLASH') return;
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
    this.syncPriceDisplay(this.data.detail, sku);
    this.syncFlashSpecLabel(this.data.detail, sku);
  },

  onPickerSkuChange(e) {
    if (this.data.sourceType === 'FLASH') return;
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
    const standardSku = sorted.find((sku) => {
      const name = `${sku.skuName || ''}`.trim();
      return name.includes('标准') || name.includes('默认');
    });
    return standardSku || sorted[0];
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
  },

  isFlashActive(detail = {}) {
    if (Number(detail.isFlash || detail.is_flash || 0) !== 1) return false;
    const flashPrice = Number(detail.flashPrice || detail.flash_price || 0);
    const flashStock = this.parseNumberField(detail.flashStock || detail.flash_stock, 0);
    const startTs = this.parseTimeToTimestamp(detail.flashStartTime || detail.flash_start_time || 0);
    const endTs = this.parseTimeToTimestamp(detail.flashEndTime || detail.flash_end_time || 0);
    if (!(flashPrice > 0) || !(flashStock > 0) || !(startTs > 0) || !(endTs > 0)) return false;
    const now = Date.now();
    if (Number.isNaN(startTs) || Number.isNaN(endTs)) return false;
    return now >= startTs && now <= endTs;
  },

  parseTimeToTimestamp(timeValue) {
    if (!timeValue) return 0;
    if (typeof timeValue === 'number') return timeValue;
    const raw = String(timeValue).trim();
    if (!raw) return 0;
    const normalized = raw.includes('T')
      ? raw
      : raw.replace(' ', 'T');
    const ts = new Date(normalized).getTime();
    if (!Number.isNaN(ts)) return ts;
    const fallbackTs = new Date(raw.replace(/-/g, '/')).getTime();
    if (!Number.isNaN(fallbackTs)) return fallbackTs;
    const localTs = new Date(raw.replace(/-/g, '/').replace('T', ' ')).getTime();
    if (!Number.isNaN(localTs)) return localTs;
    return 0;
  },

  calcSoldPercent(currentStock, initialFlashStock) {
    const nowStock = this.parseNumberField(currentStock, 0);
    const totalStock = this.parseNumberField(initialFlashStock, 0);
    if (totalStock <= 0) return 0;
    const sold = Math.max(0, totalStock - nowStock);
    const ratio = Math.round((sold * 100) / totalStock);
    return Math.max(0, Math.min(100, ratio));
  },

  calcFlashDisplayPercent(detail = {}) {
    const startTs = this.parseTimeToTimestamp(detail.flashStartTime || detail.flash_start_time || 0);
    const endTs = this.parseTimeToTimestamp(detail.flashEndTime || detail.flash_end_time || 0);
    if (!(startTs > 0) || !(endTs > startTs)) {
      return 18;
    }
    const nowBucket = this.getFlashTimeBucket();
    const elapsed = Math.max(0, Math.min(nowBucket - startTs, endTs - startTs));
    const duration = endTs - startTs;
    const timeRatio = duration > 0 ? elapsed / duration : 0;
    const stagedPercent = Math.round(18 + (timeRatio * 68));
    return Math.max(18, Math.min(92, stagedPercent));
  },

  parseNumberField(value, fallback = 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  },

  getFlashTimeBucket() {
    const minuteMs = 60 * 1000;
    return Math.floor(Date.now() / minuteMs) * minuteMs;
  },

  pad2(num) {
    return num < 10 ? `0${num}` : `${num}`;
  },

  formatFlashRemainText(detail = {}) {
    const endTs = this.parseTimeToTimestamp(detail.flashEndTime || detail.flash_end_time || 0);
    if (!(endTs > 0)) return '';
    const remain = endTs - Date.now();
    if (remain <= 0) return '即将结束';
    const hour = Math.floor(remain / (1000 * 60 * 60));
    const minute = Math.floor((remain % (1000 * 60 * 60)) / (1000 * 60));
    const second = Math.floor((remain % (1000 * 60)) / 1000);
    return `还剩 ${this.pad2(hour)}:${this.pad2(minute)}:${this.pad2(second)}`;
  },

  getCheckoutPrice(detail = {}, sku = {}) {
    const skuPrice = Number((sku && sku.skuPrice) || detail.price || 0);
    if (this.data.sourceType !== 'FLASH' || !this.isFlashActive(detail)) {
      return Number(detail.price || skuPrice || 0);
    }
    const flashPrice = Number(detail.flashPrice || detail.flash_price || 0);
    if (!(flashPrice > 0)) return skuPrice;
    return Number(flashPrice.toFixed(2));
  },

  getOriginalDisplayPrice(detail = {}, sku = {}, currentPrice = 0) {
    const skuPrice = Number((sku && sku.skuPrice) || 0);
    const originalPrice = Number(detail.originalPrice || detail.original_price || 0);
    if (skuPrice > currentPrice) return skuPrice;
    if (originalPrice > currentPrice) return originalPrice;
    return Number(currentPrice || 0);
  },

  syncPriceDisplay(detail = {}, sku = null) {
    const currentPrice = this.getCheckoutPrice(detail, sku);
    const originalPrice = this.getOriginalDisplayPrice(detail, sku, currentPrice);
    this.setData({
      displayPriceText: Number(currentPrice || 0).toFixed(2),
      originalPriceText: originalPrice > currentPrice ? Number(originalPrice).toFixed(2) : '',
      showOriginalPrice: originalPrice > currentPrice
    });
  },

  getFlashSpecLabel(detail = {}, sku = null) {
    const targetSku = sku || this.getFirstAvailableSku(detail);
    if (!targetSku) return '标准装';
    const skuName = `${targetSku.skuName || ''}`.trim();
    const weight = Number(targetSku.skuWeightG || 0);
    if (weight > 0 && skuName) return `${weight}g${skuName.includes('标准') ? skuName : skuName}`;
    if (weight > 0) return `${weight}g标准装`;
    if (skuName) return skuName;
    return '标准装';
  },

  syncFlashSpecLabel(detail = {}, sku = null) {
    this.setData({
      flashSpecLabelText: this.getFlashSpecLabel(detail, sku)
    });
  },

  syncFlashDisplay(detail = {}) {
    if (this.data.sourceType !== 'FLASH' || !this.isFlashActive(detail)) {
      this.setData({
        flashDisplayPercent: 0,
        flashRemainText: ''
      });
      return;
    }
    this.setData({
      flashDisplayPercent: this.calcFlashDisplayPercent(detail),
      flashRemainText: this.formatFlashRemainText(detail)
    });
  },

  startFlashCountdown() {
    this.clearFlashCountdown();
    this.flashTimer = setInterval(() => {
      if (this.data.sourceType !== 'FLASH') return;
      this.syncFlashDisplay(this.data.detail || {});
    }, 1000);
  },

  clearFlashCountdown() {
    if (this.flashTimer) {
      clearInterval(this.flashTimer);
      this.flashTimer = null;
    }
  }
});
