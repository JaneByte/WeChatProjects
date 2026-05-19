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
    fallbackUsed: false,
    fallbackMessage: '',
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
            ? this.normalizeRegionOptions(res.regionOptions)
            : this.data.regionOptions,
          selectedRegion: res.region || this.data.selectedRegion,
          selectedBudget: res.budgetLevel || this.data.selectedBudget,
          selectedProduceType: res.produceType || this.data.selectedProduceType,
          selectedSort: res.sortBy || this.data.selectedSort,
          headline: res.headline || '当季精选',
          subHeadline: res.subHeadline || '',
          refreshText: this.formatRefreshText(res.refreshTime),
          fallbackUsed: !!res.fallbackUsed,
          fallbackMessage: res.fallbackMessage || '',
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
        peak: '最佳赏味期',
        late: '临近过季'
      };
      const statusTagText = stageLabelMap[stage] || (item.seasonStageText || '');
      const supplyText = item.seasonMonthRangeText || '';
      const marketingText = item.seasonMarketingText || '';
      const freshnessText = item.seasonFreshnessHint || '';
      const urgencyText = stage === 'late' ? '建议尽快下单' : '';
      const listReason = this.buildListReason(item.recommendReason, freshnessText, marketingText);
      return {
        ...item,
        statusTagText,
        supplyText,
        freshnessText,
        marketingText,
        urgencyText,
        listReason
      };
    });
  },

  buildListReason(recommendReason = '', freshnessText = '', marketingText = '') {
    const raw = `${recommendReason || ''}`.trim();
    const hasOriginLikeText = /(省|市|自治区|特别行政区|地区|州|县|镇|乡|大道|街道|枣阳|寿光|赣州|怀化|新乡|广州|南宁|东莞|云南)/.test(raw);
    const clean = raw
      .replace(/[A-Za-z0-9]+/g, '')
      .replace(/[·•]/g, '，')
      .replace(/\s+/g, '')
      .replace(/^[^，,。；;：:]*(当季适配高|供应期接近尾声|风味稳定|适合作为当季备选|适合本周购买|用户复购表现稳定)/, '$1')
      .replace(/^[^，,。；;：:]+[，,]/, '')
      .trim();
    if (clean && !hasOriginLikeText && clean.length <= 24) return clean;
    if (freshnessText) return freshnessText;
    if (marketingText) return marketingText;
    if (clean && clean.length <= 24 && !/(省|市|自治区|特别行政区|地区|州|县|镇|乡)/.test(clean)) return clean;
    return '当前时令适配度较高，适合现在下单';
  },

  extractProvinceText(origin = '') {
    const text = `${origin}`.trim();
    if (!text) return '';
    const provinceMap = [
      ['北京市', ['北京']],
      ['天津市', ['天津']],
      ['上海市', ['上海']],
      ['重庆市', ['重庆']],
      ['河北省', ['河北']],
      ['山西省', ['山西']],
      ['辽宁省', ['辽宁']],
      ['吉林省', ['吉林']],
      ['黑龙江省', ['黑龙江']],
      ['江苏省', ['江苏']],
      ['浙江省', ['浙江']],
      ['安徽省', ['安徽']],
      ['福建省', ['福建']],
      ['江西省', ['江西']],
      ['山东省', ['山东']],
      ['河南省', ['河南']],
      ['湖北省', ['湖北']],
      ['湖南省', ['湖南']],
      ['广东省', ['广东']],
      ['海南省', ['海南']],
      ['四川省', ['四川']],
      ['贵州省', ['贵州']],
      ['云南省', ['云南']],
      ['陕西省', ['陕西']],
      ['甘肃省', ['甘肃']],
      ['青海省', ['青海']],
      ['台湾省', ['台湾']],
      ['内蒙古自治区', ['内蒙古']],
      ['广西壮族自治区', ['广西']],
      ['西藏自治区', ['西藏']],
      ['宁夏回族自治区', ['宁夏']],
      ['新疆维吾尔自治区', ['新疆']],
      ['香港特别行政区', ['香港']],
      ['澳门特别行政区', ['澳门']]
    ];
    for (let i = 0; i < provinceMap.length; i += 1) {
      const [fullName, aliases] = provinceMap[i];
      if ([fullName, ...aliases].some((alias) => text.startsWith(alias))) {
        return fullName;
      }
    }
    const firstPart = text.split(/[，,、\s]+/).find((item) => item && item.trim()) || text;
    const provinceMatch = firstPart.match(/(内蒙古|黑龙江|宁夏|广西|西藏|新疆|北京市|天津市|上海市|重庆市|香港|澳门|台湾|[^省市自治区特别行政区]+省|[^省市自治区特别行政区]+市|[^省市自治区特别行政区]+自治区)/);
    if (provinceMatch && provinceMatch[0]) {
      return provinceMatch[0];
    }
    return firstPart;
  },

  normalizeRegionOptions(list = []) {
    return (Array.isArray(list) ? list : []).map((item) => {
      const key = `${(item && item.key) || ''}`.trim();
      const text = `${(item && item.text) || ''}`.trim();
      if (key === 'all') {
        return { key, text: text || '全部产地' };
      }
      const provinceText = this.extractProvinceText(text);
      return {
        ...item,
        key,
        text: provinceText || text
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
