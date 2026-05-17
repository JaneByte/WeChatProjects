const { getSeasonalList, refreshSeasonal, getSeasonalConfig } = require('../../utils/seasonal');
const { post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const { trackEvent } = require('../../utils/track');
const app = getApp();

Page({
  data: {
    loading: true,
    refreshing: false,
    addingId: 0,
    season: '',
    seasonText: '',
    seasonStage: '',
    seasonStageText: '',
    headline: '当季精选',
    subHeadline: '',
    refreshText: '',
    items: [],
    loadError: false,
    regionOptions: [
      { key: 'all', text: '全部产地' }
    ],
    budgetOptions: [
      { key: 'all', text: '全部预算' },
      { key: 'economy', text: '经济' },
      { key: 'standard', text: '标准' },
      { key: 'plus', text: '升级' }
    ],
    produceOptions: [
      { key: 'all', text: '全部' },
      { key: 'fruits', text: '水果' },
      { key: 'vegetables', text: '蔬菜' }
    ],
    sortOptions: [
      { key: 'score', text: '综合' },
      { key: 'sales_desc', text: '销量' },
      { key: 'price_asc', text: '低价' },
      { key: 'price_desc', text: '高价' }
    ],
    selectedRegion: 'all',
    selectedBudget: 'all',
    selectedProduceType: 'all',
    selectedSort: 'score',
    seasonalConfigReady: false
  },

  onLoad() {
    this.loadConfigAndData();
  },

  loadConfigAndData() {
    return getSeasonalConfig()
      .then(() => this.setData({ seasonalConfigReady: true }))
      .catch(() => this.setData({ seasonalConfigReady: false }))
      .finally(() => this.loadSeasonalList(false));
  },

  onPullDownRefresh() {
    this.loadSeasonalList(true).finally(() => wx.stopPullDownRefresh());
  },

  loadSeasonalList(forceRefresh) {
    this.setData({
      loading: !forceRefresh,
      refreshing: forceRefresh,
      loadError: false
    });
    const action = forceRefresh ? refreshSeasonal : getSeasonalList;
    return action({
      limit: 12,
      region: this.data.selectedRegion,
      budgetLevel: this.data.selectedBudget,
      produceType: this.data.selectedProduceType,
      sortBy: this.data.selectedSort
    })
      .then((res) => {
        const list = this.decorateItems(Array.isArray(res.items) ? res.items : []);
        this.setData({
          season: res.season || '',
          seasonText: res.seasonText || '',
          seasonStage: res.seasonStage || '',
          seasonStageText: res.seasonStageText || '',
          regionOptions: Array.isArray(res.regionOptions) && res.regionOptions.length
            ? res.regionOptions
            : this.data.regionOptions,
          selectedRegion: res.region || this.data.selectedRegion,
          selectedBudget: res.budgetLevel || this.data.selectedBudget,
          selectedProduceType: res.produceType || this.data.selectedProduceType,
          selectedSort: res.sortBy || this.data.selectedSort,
          headline: res.headline || '当季精选',
          subHeadline: res.subHeadline || '',
          refreshText: this.formatRefreshText(res.refreshTime),
          items: list,
          loadError: false
        });
        trackEvent('seasonal_list_loaded', {
          season: `${res.season || ''}`,
          itemCount: list.length
        });
      })
      .catch((error) => {
        this.setData({ loadError: true, items: [] });
        showRequestError(error, '当季精选加载失败');
      })
      .finally(() => this.setData({ loading: false, refreshing: false }));
  },

  formatRefreshText(timestamp) {
    const ts = Number(timestamp || 0);
    if (!ts) return '';
    const date = new Date(ts);
    const mm = `${date.getMinutes()}`.padStart(2, '0');
    return `更新于 ${date.getMonth() + 1}-${date.getDate()} ${date.getHours()}:${mm}`;
  },

  decorateItems(list = []) {
    return list.map((item) => {
      const stage = `${item.seasonStage || ''}`.trim();
      const stageLabelMap = {
        early: '新上季',
        peak: '当季旺期',
        late: '临近过季'
      };
      const statusTagText = stageLabelMap[stage] || (item.seasonStageText || '');
      const supplyText = item.seasonMonthRangeText || '';
      const marketingText = item.seasonMarketingText || '';
      const freshnessText = item.seasonFreshnessHint || '';
      const urgencyText = stage === 'late' ? '建议尽快下单' : '';
      return {
        ...item,
        statusTagText,
        supplyText,
        freshnessText,
        marketingText,
        urgencyText
      };
    });
  },

  onRetry() {
    this.loadSeasonalList(false);
  },

  onPickRegion(e) {
    const key = `${e.currentTarget.dataset.key || 'all'}`;
    if (key === this.data.selectedRegion) return;
    this.setData({ selectedRegion: key });
    this.loadSeasonalList(false);
  },

  onPickBudget(e) {
    const key = `${e.currentTarget.dataset.key || 'all'}`;
    if (key === this.data.selectedBudget) return;
    this.setData({ selectedBudget: key });
    this.loadSeasonalList(false);
  },

  onPickProduceType(e) {
    const key = `${e.currentTarget.dataset.key || 'all'}`;
    if (key === this.data.selectedProduceType) return;
    this.setData({ selectedProduceType: key });
    this.loadSeasonalList(false);
  },

  onPickSort(e) {
    const key = `${e.currentTarget.dataset.key || 'score'}`;
    if (key === this.data.selectedSort) return;
    this.setData({ selectedSort: key });
    this.loadSeasonalList(false);
  },

  onTapItem(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}&sourceType=SEASONAL&sourceScene=${encodeURIComponent('当季精选')}` });
  },

  onAddCart(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    if (this.data.addingId) return;
    const target = (this.data.items || []).find((it) => Number(it.id) === id);
    if (!target) return;
    if (Number(target.stock || 0) <= 0) {
      wx.showToast({ title: '库存不足', icon: 'none' });
      return;
    }
    app.requireLogin({ redirect: '/pages/seasonal/seasonal' })
      .then(() => {
        this.setData({ addingId: id });
        const targetSkuId = Number(target.defaultSkuId || target.skuId || 0);
        if (!targetSkuId) {
          throw new Error('当季商品缺少可用规格');
        }
        return post(`/cart/add?goodsId=${id}&skuId=${targetSkuId}&quantity=1&sourceType=SEASONAL&sourceScene=${encodeURIComponent('当季精选')}`, {}, { retry: 0 });
      })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success' });
        trackEvent('seasonal_add_cart', { goodsId: `${id}` });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) return;
        showRequestError(error, '加入购物车失败');
      })
      .finally(() => this.setData({ addingId: 0 }));
  }
});
