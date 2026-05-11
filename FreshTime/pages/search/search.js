const { get } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');

const SEARCH_HISTORY_KEY = 'searchHistory';
const MAX_HISTORY = 8;

Page({
  data: {
    keyword: '',
    list: [],
    loading: false,
    searched: false,
    history: [],
    loadError: false,
    page: 1,
    pageSize: 20,
    hasMore: false,
    loadingMore: false
  },

  onLoad(options = {}) {
    this.loadHistory();
    const rawKeyword = (options.keyword || '').trim();
    let keyword = rawKeyword;
    if (rawKeyword) {
      try {
        keyword = decodeURIComponent(rawKeyword);
      } catch (error) {
        keyword = rawKeyword;
      }
    }
    if (!keyword) return;
    this.setData({ keyword }, () => this.onSearch());
  },

  loadHistory() {
    const history = wx.getStorageSync(SEARCH_HISTORY_KEY) || [];
    this.setData({ history: Array.isArray(history) ? history : [] });
  },

  saveHistory(keyword) {
    const clean = (keyword || '').trim();
    if (!clean) return;
    const next = [clean, ...this.data.history.filter((item) => item !== clean)].slice(0, MAX_HISTORY);
    this.setData({ history: next });
    wx.setStorageSync(SEARCH_HISTORY_KEY, next);
  },

  onInput(e) {
    const keyword = (e.detail.value || '').trim();
    if (!keyword) {
      this.setData({
        keyword: '',
        list: [],
        searched: false,
        loadError: false,
        page: 1,
        hasMore: false,
        loadingMore: false
      });
      return;
    }
    this.setData({ keyword });
  },

  onSearch() {
    const keyword = (this.data.keyword || '').trim();
    if (!keyword) {
      this.setData({ list: [], searched: false, loadError: false, page: 1, hasMore: false, loadingMore: false });
      return;
    }

    this.setData({ loading: true, searched: true, loadError: false, list: [], page: 1, hasMore: false, loadingMore: false });
    get('/goods/search', { keyword, page: 1, pageSize: this.data.pageSize }, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        const list = data.list || [];
        this.setData({
          list: Array.isArray(list) ? list : [],
          loadError: false,
          page: 2,
          hasMore: data.hasMore === true
        });
        this.saveHistory(keyword);
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '搜索失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onReachBottom() {
    if (this.data.loading || this.data.loadingMore || !this.data.hasMore || this.data.loadError) return;
    const keyword = (this.data.keyword || '').trim();
    if (!keyword) return;
    this.setData({ loadingMore: true });
    get('/goods/search', { keyword, page: this.data.page, pageSize: this.data.pageSize }, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        const appendList = Array.isArray(data.list) ? data.list : [];
        this.setData({
          list: this.data.list.concat(appendList),
          page: this.data.page + 1,
          hasMore: data.hasMore === true,
          loadError: false
        });
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '加载更多失败');
      })
      .finally(() => this.setData({ loadingMore: false }));
  },

  onRetrySearch() {
    this.onSearch();
  },

  onClearKeyword() {
    this.setData({
      keyword: '',
      list: [],
      searched: false,
      loadError: false,
      page: 1,
      hasMore: false,
      loadingMore: false
    });
  },

  onTapHistory(e) {
    const { keyword } = e.currentTarget.dataset;
    this.setData({ keyword: keyword || '' }, () => this.onSearch());
  },

  onClearHistory() {
    wx.removeStorageSync(SEARCH_HISTORY_KEY);
    this.setData({ history: [] });
  },

  onTapItem(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  }
});

