const { get, post } = require('../../utils/request');
const { getTempFileUrls } = require('../../utils/cloud');
const { showRequestError } = require('../../utils/ui');
const { trackEvent } = require('../../utils/track');
const app = getApp();

Page({
  data: {
    brandName: 'FreshTime',
    brandSub: '鲜时刻',
    greetingWords: '早安，新鲜蔬果已经到店',
    searchIcon: '/assets/icon/search.png',
    searchPlaceholder: '搜苹果、小份蔬菜、当季水果',

    moreText: '更多 >',
    noticePrefix: '公告',
    waterfallTitle: '这周大家都在买',
    priceSymbol: '¥',
    loadingText: '正在加载...',
    noMoreText: '已经到底啦',
    homeLoading: true,
    homeError: false,

    paths: {
      search: '/pages/search/search',
      goods: '/pages/goods/goods',
      goodsDetail: '/pages/goodsDetail/goodsDetail',
      category: '/pages/category/category'
    },

    statusBarHeight: 44,
    flashEndTimestamp: 0,
    flashSaleList: [],
    homeHero: null,
    noticeList: [],
    hotKeyword: '',

    navList: [
      { type: 'couponZone', text: '领券福利', subText: '先领券再下单', iconText: '券', linkType: 'coupon', linkValue: '' },
      { type: 'seasonalFresh', text: '当季鲜选', subText: '应季更新更划算', iconText: '时', linkType: 'scene', linkValue: '时令' },
      { type: 'smallPortion', text: '小份优选', subText: '单人份量少浪费', iconText: '小', linkType: 'scene', linkValue: '小份量' },
      { type: 'comboMix', text: '蔬果搭配', subText: '按场景一次配齐', iconText: '搭', linkType: 'scene', linkValue: '搭配' }
    ],

    goodsList: [],
    leftColumnList: [],
    rightColumnList: [],
    page: 1,
    pageSize: 10,
    loadingMore: false,
    noMore: false,
    loadMoreError: false,
    bannerHeightPx: 180,
    addingCart: false
  },

  onLoad() {
    this.pageActive = true;
    const systemInfo = wx.getSystemInfoSync();
    const statusBar = systemInfo.statusBarHeight || 20;
    let compactSafeHeight = statusBar + 28;
    try {
      const menuRect = wx.getMenuButtonBoundingClientRect();
      if (menuRect && menuRect.top && menuRect.height) {
        const topGap = Math.max(menuRect.top - statusBar, 2);
        compactSafeHeight = statusBar + topGap + 20;
      }
    } catch (error) {}
    compactSafeHeight = Math.max(statusBar + 24, Math.min(compactSafeHeight, statusBar + 36));
    this.setData({ statusBarHeight: compactSafeHeight });
    this.generateGreeting();
    this.loadHomeIndex();
    this.loadGoods(true);
  },

  onShow() {
    this.pageActive = true;
    if (this.data.flashEndTimestamp > Date.now() && !this.countdownTimer) this.startFlashCountdown();
  },

  onHide() {
    this.pageActive = false;
    this.clearFlashCountdown();
  },

  onUnload() {
    this.pageActive = false;
    this.clearFlashCountdown();
  },

  generateGreeting() {
    const hour = new Date().getHours();
    let greeting = '';
    if (hour >= 6 && hour < 11) greeting = '早安，今天的当季鲜果已上新';
    else if (hour >= 11 && hour < 14) greeting = '中午好，来挑点清爽又好搭配的蔬果';
    else if (hour >= 14 && hour < 18) greeting = '下午好，补点轻食水果刚刚好';
    else if (hour >= 18 && hour < 22) greeting = '晚上好，今晚下厨的食材已经帮你备好';
    else greeting = '夜深了，明早再来挑更新鲜的好物';
    this.setData({ greetingWords: greeting });
  },

  async loadHomeIndex(showError = false) {
    this.setData({ homeLoading: true, homeError: false });
    try {
      const res = await get('/home/index', {}, { retry: 1 });
      const data = this.unwrapData(res);
      const flashRaw = data.flash || {};
      const flashList = await this.normalizeGoodsImageList(flashRaw.list || [], true);
      const homeHero = await this.normalizeHomeHero(data.homeHero || {});
      const flashEndTimestamp = this.parseTimeToTimestamp(flashRaw.endTime);
      const noticeList = Array.isArray(data.notices) ? data.notices : [];
      const navList = this.normalizeNavList(data.navList);
      const hotKeyword = this.buildHotKeyword(flashList);

      this.setData({
        flashSaleList: flashList,
        homeHero,
        noticeList,
        navList,
        hotKeyword,
        flashEndTimestamp,
        homeLoading: false,
        homeError: false
      });

      if (flashEndTimestamp > Date.now() && flashList.length > 0) this.startFlashCountdown();
      else {
        this.clearFlashCountdown();
      }
    } catch (error) {
      this.setData({
        flashSaleList: [],
        homeHero: null,
        noticeList: [],
        homeLoading: false,
        homeError: true
      });
      this.clearFlashCountdown();
      if (showError) showRequestError(error, '首页数据加载失败');
    }
  },

  async loadGoods(reset = false) {
    if (this.data.loadingMore) return;
    if (!reset && this.data.noMore) return;

    const nextPage = reset ? 1 : this.data.page;
    this.setData({ loadingMore: true, loadMoreError: false });

    try {
      const res = await get('/home/goods', { page: nextPage, pageSize: this.data.pageSize }, { retry: 1 });
      const data = this.unwrapData(res);
      const list = await this.normalizeGoodsImageList(data.list || []);
      const mergedList = reset ? list : this.data.goodsList.concat(list);
      const split = this.splitWaterfallColumns(mergedList);
      const hasMore = data.hasMore === true;

      this.setData({
        goodsList: mergedList,
        leftColumnList: split.leftColumnList,
        rightColumnList: split.rightColumnList,
        page: nextPage + 1,
        noMore: !hasMore,
        loadingMore: false,
        loadMoreError: false
      });
    } catch (error) {
      this.setData({ loadingMore: false, loadMoreError: true });
      showRequestError(error, '商品加载失败');
    }
  },

  splitWaterfallColumns(goodsList) {
    const leftColumnList = [];
    const rightColumnList = [];
    goodsList.forEach((item, index) => {
      if (index % 2 === 0) leftColumnList.push(item);
      else rightColumnList.push(item);
    });
    return { leftColumnList, rightColumnList };
  },

  async normalizeGoodsImageList(list, asFlash = false) {
    if (!list || list.length === 0) return [];
    const fileIds = list.map((item) => item.mainImage || item.image).filter((id) => id && id.startsWith('cloud://'));
    const urlMap = fileIds.length > 0 ? await getTempFileUrls(fileIds) : {};
    return list.map((item) => {
      const rawImage = item.mainImage || item.image || '';
      const image = urlMap[rawImage] || rawImage;
      const stock = this.parseNumberField(item.stock, 0);
      if (!asFlash) {
        return {
          ...item,
          mainImage: image,
          image,
          stock,
          skuList: Array.isArray(item.skuList) ? item.skuList : []
        };
      }
      const originPrice = Number(item.originalPrice || item.originPrice || item.price || 0);
      const flashPrice = Number(item.flashPrice || item.price || 0);
      const flashStock = this.parseNumberField(item.flashStock || item.flash_stock, 0);
      const soldPercent = this.calcFlashDisplayPercent(item, stock, flashStock);
      const flashEndTimestamp = this.parseTimeToTimestamp(item.flashEndTime || item.flash_end_time || 0);
      const flashRemainText = this.formatFlashRemainText(flashEndTimestamp);
      const flashSpecText = this.buildFlashSpecText(item);
      return {
        ...item,
        mainImage: image,
        image,
        stock,
        skuList: Array.isArray(item.skuList) ? item.skuList : [],
        originPrice: originPrice.toFixed(2),
        flashPrice: flashPrice.toFixed(2),
        soldPercent,
        flashEndTimestamp,
        flashRemainText,
        flashSpecText
      };
    });
  },

  calcSoldPercent(currentStock, initialFlashStock) {
    const nowStock = this.parseNumberField(currentStock, 0);
    const totalStock = this.parseNumberField(initialFlashStock, 0);
    if (totalStock <= 0) return 0;
    const sold = Math.max(0, totalStock - nowStock);
    const ratio = Math.round((sold * 100) / totalStock);
    return Math.max(0, Math.min(100, ratio));
  },

  calcFlashDisplayPercent(item = {}, currentStock = 0, initialFlashStock = 0) {
    const startTs = this.parseTimeToTimestamp(item.flashStartTime || item.flash_start_time || 0);
    const endTs = this.parseTimeToTimestamp(item.flashEndTime || item.flash_end_time || 0);
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

  getFlashTimeBucket() {
    const minuteMs = 60 * 1000;
    return Math.floor(Date.now() / minuteMs) * minuteMs;
  },

  buildFlashSpecText(item = {}) {
    const skuList = Array.isArray(item.skuList) ? item.skuList : [];
    const standardSku = skuList.find((sku) => {
      const name = `${sku.skuName || ''}`.trim();
      return name.includes('标准') || name.includes('默认');
    }) || skuList[0] || null;
    if (!standardSku) {
      return item.unit ? `${item.unit}标准装` : '标准装';
    }
    const skuName = `${standardSku.skuName || ''}`.trim();
    const weight = Number(standardSku.skuWeightG || 0);
    if (skuName && weight > 0) return `${weight}g${skuName.includes('标准') ? skuName : `${skuName}`}`;
    if (weight > 0) return `${weight}g标准装`;
    if (skuName) return skuName;
    return item.unit ? `${item.unit}标准装` : '标准装';
  },

  parseNumberField(value, fallback = 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  },

  async normalizeHomeHero(hero = {}) {
    if (!hero || !hero.image) return null;
    const rawImage = hero.image || '';
    const urlMap = rawImage && rawImage.startsWith('cloud://') ? await getTempFileUrls([rawImage]) : {};
    return {
      image: urlMap[rawImage] || rawImage,
      linkType: hero.linkType || 'none',
      linkValue: hero.linkValue || ''
    };
  },

  onBannerImageLoad(e) {
    const { width, height } = e.detail || {};
    if (!width || !height) return;
    this.updateBannerHeight(width, height);
  },

  updateBannerHeight(imageWidth, imageHeight) {
    const query = wx.createSelectorQuery();
    query.select('.banner-swiper').boundingClientRect();
    query.exec((res) => {
      const rect = res && res[0];
      if (!rect || !rect.width) return;
      const nextHeight = Math.max(120, Math.round((rect.width * imageHeight) / imageWidth));
      if (Math.abs(nextHeight - this.data.bannerHeightPx) < 1) return;
      this.setData({ bannerHeightPx: nextHeight });
    });
  },

  normalizeNavList(sourceList = []) {
    return this.data.navList;
  },

  buildHotKeyword(list) {
    if (!Array.isArray(list) || list.length === 0) return '';
    const first = list[0] || {};
    return (first.name || '').trim();
  },

  unwrapData(response) {
    if (response && typeof response === 'object' && Object.prototype.hasOwnProperty.call(response, 'data')) return response.data || {};
    return response || {};
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

  startFlashCountdown() {
    this.clearFlashCountdown();
    this.updateFlashCountdown();
    this.countdownTimer = setInterval(() => this.updateFlashCountdown(), 1000);
  },

  clearFlashCountdown() {
    if (this.countdownTimer) {
      clearInterval(this.countdownTimer);
      this.countdownTimer = null;
    }
  },

  updateFlashCountdown() {
    if (!this.pageActive) return;
    const remain = this.data.flashEndTimestamp - Date.now();
    if (remain <= 0) {
      this.clearFlashCountdown();
      return;
    }
    const hour = Math.floor(remain / (1000 * 60 * 60));
    const minute = Math.floor((remain % (1000 * 60 * 60)) / (1000 * 60));
    const second = Math.floor((remain % (1000 * 60)) / 1000);
    const flashSaleList = (this.data.flashSaleList || []).map((item) => ({
      ...item,
      flashRemainText: this.formatFlashRemainText(item.flashEndTimestamp),
      soldPercent: this.calcFlashDisplayPercent(item, item.stock, item.flashStock || item.flash_stock || 0)
    }));
    this.setData({
      flashSaleList
    });
  },

  pad2(num) { return num < 10 ? `0${num}` : `${num}`; },

  formatFlashRemainText(timestamp) {
    const ts = Number(timestamp || 0);
    if (!(ts > 0)) return '';
    const remain = ts - Date.now();
    if (remain <= 0) return '即将结束';
    const hour = Math.floor(remain / (1000 * 60 * 60));
    const minute = Math.floor((remain % (1000 * 60 * 60)) / (1000 * 60));
    const second = Math.floor((remain % (1000 * 60)) / 1000);
    return `还剩 ${this.pad2(hour)}:${this.pad2(minute)}:${this.pad2(second)}`;
  },

  onScrollToLower() { this.loadGoods(false); },

  async onPullDownRefresh() {
    this.setData({ page: 1, noMore: false, goodsList: [], leftColumnList: [], rightColumnList: [] });
    this.generateGreeting();
    await this.loadHomeIndex(true);
    await this.loadGoods(true);
    wx.stopPullDownRefresh();
  },

  onRetryHome() {
    this.loadHomeIndex(true);
    this.loadGoods(true);
  },

  onSearchTap() {
    const keyword = this.data.hotKeyword;
    const query = keyword ? `?keyword=${encodeURIComponent(keyword)}` : '';
    wx.navigateTo({ url: `${this.data.paths.search}${query}` });
  },
  onFlashMoreTap() { wx.navigateTo({ url: `${this.data.paths.goods}?type=flash` }); },

  onFlashTap(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `${this.data.paths.goodsDetail}?id=${id}&sourceType=FLASH&sourceScene=${encodeURIComponent('限时秒杀')}` });
  },

  onFlashAdd(e) {
    const { id } = e.currentTarget.dataset;
    const target = this.data.flashSaleList.find((item) => `${item.id}` === `${id}`);
    if (!target) return;
    if (Number(target.stock || 0) <= 0) {
      wx.showToast({ title: '秒杀已售罄', icon: 'none' });
      return;
    }
    this.addToCart(target, 1, () => trackEvent('flash_add', { goodsId: `${id}` }), {
      sourceType: 'FLASH',
      sourceScene: '限时秒杀'
    });
  },

  onNavTap(e) {
    const { type } = e.currentTarget.dataset;
    const { paths } = this.data;
    const targetConfig = this.data.navList.find((item) => `${item.type}` === `${type}`) || {};
    const linkType = targetConfig.linkType || 'goods';
    const linkValue = targetConfig.linkValue || type;
    trackEvent('scene_click', {
      sceneType: `${type}`,
      linkType: `${linkType}`,
      linkValue: `${linkValue}`
    });
    const target = this.buildTargetUrl(linkType, linkValue, paths);
    if (target === paths.category) wx.switchTab({ url: target });
    else wx.navigateTo({ url: target });
  },

  onBannerTap(e) {
    const { linkType = 0, linkValue = '' } = e.currentTarget.dataset;
    if (`${linkType}` === 'none' || `${linkType}` === '0') return;
    trackEvent('banner_click', { linkType: `${linkType}`, linkValue: `${linkValue}` });
    this.navigateByLinkType(linkType, linkValue);
  },

  onNoticeTap(e) {
    const { linkType = 'none', linkValue = '' } = e.currentTarget.dataset;
    this.navigateByLinkType(linkType, linkValue);
  },

  buildTargetUrl(linkType, linkValue, paths) {
    if (linkType === 'category') return paths.category;
    if (linkType === 'coupon') return '/pages/coupon/coupon';
    if (linkType === 'scene') {
      if (linkValue === '时令') return '/pages/seasonal/seasonal';
      if (linkValue === '小份量') return '/pages/meal-config/meal-config';
      if (linkValue === '搭配') return '/pages/combo-config/combo-config';
      return `${paths.goods}?scene=${encodeURIComponent(linkValue || '')}`;
    }
    if (linkType === 'search') return `${paths.search}?keyword=${encodeURIComponent(linkValue || '')}`;
    return `${paths.goods}?type=${encodeURIComponent(linkValue || 'hot')}`;
  },

  navigateByLinkType(linkType, linkValue) {
    const { paths } = this.data;
    const type = `${linkType}`;
    const value = `${linkValue || ''}`;
    if (type === '1' || type === 'goodsDetail') {
      if (!value) return;
      wx.navigateTo({ url: `${paths.goodsDetail}?id=${value}` });
      return;
    }
    if (type === '2' || type === 'category') {
      wx.switchTab({ url: paths.category });
      return;
    }
    if (type === 'goods') {
      wx.navigateTo({ url: `${paths.goods}?type=${encodeURIComponent(value || 'hot')}` });
      return;
    }
    if (type === 'search') {
      wx.navigateTo({ url: `${paths.search}?keyword=${encodeURIComponent(value)}` });
      return;
    }
    if (type === 'scene') {
      if (value === '时令') {
        wx.navigateTo({ url: '/pages/seasonal/seasonal' });
        return;
      }
      if (value === '小份量') {
        wx.navigateTo({ url: '/pages/meal-config/meal-config' });
        return;
      }
      if (value === '搭配') {
        wx.navigateTo({ url: '/pages/combo-config/combo-config' });
        return;
      }
      wx.navigateTo({ url: `${paths.goods}?scene=${encodeURIComponent(value)}` });
      return;
    }
    if (type === 'coupon') {
      wx.navigateTo({ url: '/pages/coupon/coupon' });
      return;
    }
  },

  onMoreTap() { wx.navigateTo({ url: `${this.data.paths.goods}?type=weeklyHot` }); },

  onGoodsTap(e) {
    const { item } = e.detail;
    wx.navigateTo({ url: `${this.data.paths.goodsDetail}?id=${item.id}` });
  },

  onAddToCart(e) {
    const item = (e && e.detail && e.detail.item) || null;
    if (!item || !item.id) return;
    if (Number(item.stock || 0) <= 0) {
      wx.showToast({ title: '商品已售罄', icon: 'none' });
      return;
    }
    this.addToCart(item, 1, () => trackEvent('hot_add', { goodsId: `${item.id}` }));
  },

  getFirstAvailableSku(goods = {}) {
    const list = Array.isArray(goods.skuList) ? goods.skuList : [];
    const enabled = list.filter((sku) => Number(sku.status) === 1 && Number(sku.skuStock || 0) > 0);
    if (!enabled.length) return null;
    const sorted = enabled.slice().sort((a, b) => Number(a.sort || 0) - Number(b.sort || 0));
    const standardSku = sorted.find((sku) => {
      const name = `${sku.skuName || ''}`.trim();
      return name.includes('标准') || name.includes('默认');
    });
    return standardSku || sorted[0];
  },

  addToCart(goods, quantity = 1, onSuccess, extra = {}) {
    if (this.data.addingCart) return;
    const target = goods && typeof goods === 'object'
      ? goods
      : ((this.data.goodsList || []).find((item) => Number(item.id) === Number(goods)) || (this.data.flashSaleList || []).find((item) => Number(item.id) === Number(goods)));
    if (!target || !target.id) return;
    const selectedSku = this.getFirstAvailableSku(target);
    if (!selectedSku || !selectedSku.id) {
      wx.showToast({ title: '暂无可用规格', icon: 'none', duration: 1500 });
      return;
    }
    const query = [];
    if (extra.sourceType) query.push(`sourceType=${encodeURIComponent(extra.sourceType)}`);
    if (extra.sourceScene) query.push(`sourceScene=${encodeURIComponent(extra.sourceScene)}`);
    const suffix = query.length ? `&${query.join('&')}` : '';
    this.setData({ addingCart: true });
    app.requireLogin({ redirect: '/pages/index/index', message: '正在登录，请稍候' })
      .then(() => post(`/cart/add?goodsId=${target.id}&skuId=${selectedSku.id}&quantity=${quantity}${suffix}`, {}, { retry: 0 }))
      .then(() => {
        if (typeof onSuccess === 'function') onSuccess();
        wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
          return;
        }
        showRequestError(error, '加入购物车失败');
      })
      .finally(() => this.setData({ addingCart: false }));
  }
});
