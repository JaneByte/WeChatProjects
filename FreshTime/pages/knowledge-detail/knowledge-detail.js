const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const { getTempFileUrls } = require('../../utils/cloud');
const { trackEvent } = require('../../utils/track');
const app = getApp();

Page({
  data: {
    id: '',
    loading: true,
    loadError: false,
    article: null,
    recommendGoods: []
  },

  onLoad(options = {}) {
    const id = `${options.id || ''}`.trim();
    this.setData({ id }, () => this.loadDetail());
  },

  loadDetail(showError = false) {
    const { id } = this.data;
    if (!id) {
      this.setData({ loading: false, loadError: false, article: null });
      return;
    }

    this.setData({ loading: true, loadError: false });
    get(`/knowledge/${encodeURIComponent(id)}`, {}, { retry: 1 })
      .then((res) => {
        const article = this.normalizeArticle(this.unwrapData(res));
        this.setData({ article, loading: false, loadError: false });
        this.loadRecommendGoods(article.searchKeyword || '');
      })
      .catch((error) => {
        this.setData({ loading: false, loadError: true });
        if (showError) showRequestError(error, '科普内容加载失败');
      });
  },

  onRetry() {
    this.loadDetail(true);
  },

  onTapSearch() {
    const keyword = (this.data.article && this.data.article.searchKeyword) || '';
    const query = keyword ? `?keyword=${encodeURIComponent(keyword)}` : '';
    wx.navigateTo({ url: `/pages/search/search${query}` });
  },

  loadRecommendGoods(keyword) {
    const clean = `${keyword || ''}`.trim();
    if (!clean) {
      this.setData({ recommendGoods: [] });
      return;
    }
    get('/home/recommend-goods', { keyword: clean, limit: 4 }, { retry: 1 })
      .then((res) => this.unwrapData(res))
      .then((data) => this.normalizeGoodsList(data.list || []))
      .then((list) => this.setData({ recommendGoods: list }))
      .catch(() => this.setData({ recommendGoods: [] }));
  },

  normalizeGoodsList(list) {
    if (!Array.isArray(list) || list.length === 0) return Promise.resolve([]);
    const fileIds = list.map((item) => item.mainImage || item.image).filter((id) => id && id.startsWith('cloud://'));
    return getTempFileUrls(fileIds)
      .then((urlMap = {}) => list.map((item) => {
        const rawImage = item.mainImage || item.image || '';
        const image = urlMap[rawImage] || rawImage;
        return {
          ...item,
          image,
          mainImage: image
        };
      }))
      .catch(() => list);
  },

  onTapRecommend(e) {
    const { id } = e.currentTarget.dataset;
    if (!id) return;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  },

  onAddRecommend(e) {
    const { id } = e.currentTarget.dataset;
    if (!id) return;
    this.addToCart(id, 1, () => trackEvent('knowledge_goods_add', { goodsId: `${id}`, articleId: `${this.data.id}` }));
  },

  addToCart(goodsId, quantity = 1, onSuccess) {
    const userId = app.getUserId && app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }
    post(`/cart/add?userId=${userId}&goodsId=${goodsId}&quantity=${quantity}`, {}, { retry: 0 })
      .then(() => {
        if (typeof onSuccess === 'function') onSuccess();
        wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => showRequestError(error, '加入购物车失败'));
  },

  unwrapData(response) {
    if (
      response &&
      typeof response === 'object' &&
      Object.prototype.hasOwnProperty.call(response, 'data')
    ) {
      return response.data || {};
    }
    return response || {};
  },

  normalizeArticle(raw = {}) {
    const toList = (value) => {
      if (!value) return [];
      if (Array.isArray(value)) return value.filter((item) => `${item}`.trim());
      return `${value}`
        .split(/\r?\n|\|/)
        .map((item) => item.trim())
        .filter(Boolean);
    };

    return {
      id: raw.id || '',
      title: raw.title || '科普内容',
      summary: raw.summary || '',
      tags: toList(raw.tags),
      pickGuide: toList(raw.pickGuide),
      nutrition: toList(raw.nutrition),
      pairing: toList(raw.pairing),
      cautions: toList(raw.cautions),
      content: raw.content || '',
      searchKeyword: raw.searchKeyword || ''
    };
  }
});
