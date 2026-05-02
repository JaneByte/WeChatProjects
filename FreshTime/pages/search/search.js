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
    loadError: false
  },

  onLoad() {
    this.loadHistory();
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
        loadError: false
      });
      return;
    }
    this.setData({ keyword });
  },

  onSearch() {
    const keyword = (this.data.keyword || '').trim();
    if (!keyword) {
      this.setData({ list: [], searched: false, loadError: false });
      return;
    }

    this.setData({ loading: true, searched: true, loadError: false, list: [] });
    get('/goods/search', { keyword }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ list: Array.isArray(list) ? list : [], loadError: false });
        this.saveHistory(keyword);
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '搜索失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onRetrySearch() {
    this.onSearch();
  },

  onClearKeyword() {
    this.setData({
      keyword: '',
      list: [],
      searched: false,
      loadError: false
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

