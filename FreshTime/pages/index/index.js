const { get, post } = require('../../utils/request');
const { getTempFileUrls } = require('../../utils/cloud');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    brandName: 'FreshTime',
    brandSub: '鲜时达',
    greetingWords: '早安，新鲜蔬果已经到店',
    newArrivalCount: 0,
    searchIcon: '/assets/icon/search.png',
    searchPlaceholder: '搜索蔬果 / 产地 / 秒杀',

    heroTitle: '今日推荐',
    heroBadge: '每日精选',
    moreText: '更多 >',
    waterfallTitle: '本周热销',
    priceSymbol: '¥',
    addBtnText: '+',
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
    dailyRecommend: null,
    flashCountdown: '00:00:00',
    flashEndTimestamp: 0,
    flashSaleList: [],

    navList: [
      { type: 'seasonal', text: '时令优选', iconText: '时' },
      { type: 'hot', text: '热销爆款', iconText: '热' },
      { type: 'flash', text: '限时秒杀', iconText: '秒' },
      { type: 'category', text: '全部分类', iconText: '类' }
    ],

    traceList: [],
    goodsList: [],
    leftColumnList: [],
    rightColumnList: [],
    page: 1,
    pageSize: 10,
    loadingMore: false,
    noMore: false,
    loadMoreError: false
  },

  onLoad() {
    const systemInfo = wx.getSystemInfoSync();
    const statusBar = systemInfo.statusBarHeight || 20;
    let navSafeHeight = statusBar + 44;
    try {
      const menuRect = wx.getMenuButtonBoundingClientRect();
      if (menuRect && menuRect.top && menuRect.height) {
        const topGap = menuRect.top - statusBar;
        navSafeHeight = statusBar + topGap * 2 + menuRect.height;
      }
    } catch (error) {}
    this.setData({ statusBarHeight: navSafeHeight + 4 });
    this.generateGreeting();
    this.loadHomeIndex();
    this.loadGoods(true);
  },

  onShow() {
    if (this.data.flashEndTimestamp > Date.now() && !this.countdownTimer) this.startFlashCountdown();
  },

  onHide() { this.clearFlashCountdown(); },
  onUnload() { this.clearFlashCountdown(); },

  generateGreeting() {
    const hour = new Date().getHours();
    let greeting = '';
    if (hour >= 6 && hour < 11) greeting = '早安，新鲜蔬果已经到店';
    else if (hour >= 11 && hour < 14) greeting = '中午好，来点清爽蔬果';
    else if (hour >= 14 && hour < 18) greeting = '下午好，补充轻食能量';
    else if (hour >= 18 && hour < 22) greeting = '晚上好，精选好货在等你';
    else greeting = '夜深了，明早再来挑新鲜';
    this.setData({ greetingWords: greeting });
  },

  async loadHomeIndex(showError = false) {
    this.setData({ homeLoading: true, homeError: false });
    try {
      const res = await get('/home/index', {}, { retry: 1 });
      const data = this.unwrapData(res);
      const recommend = await this.normalizeGoodsImage(data.todayRecommend || null);
      const flashRaw = data.flash || {};
      const flashList = await this.normalizeGoodsImageList(flashRaw.list || []);
      const flashEndTimestamp = this.parseTimeToTimestamp(flashRaw.endTime);

      this.setData({
        newArrivalCount: data.newArrivalCount || 0,
        dailyRecommend: recommend,
        flashSaleList: flashList,
        traceList: data.traceList || [],
        flashEndTimestamp,
        homeLoading: false,
        homeError: false
      });

      if (flashEndTimestamp > Date.now() && flashList.length > 0) this.startFlashCountdown();
      else {
        this.setData({ flashCountdown: '00:00:00' });
        this.clearFlashCountdown();
      }
    } catch (error) {
      this.setData({
        dailyRecommend: null,
        flashSaleList: [],
        traceList: [],
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

  async normalizeGoodsImage(goods) {
    if (!goods) return null;
    const image = goods.mainImage || goods.image || '';
    if (!image || !image.startsWith('cloud://')) return { ...goods, image };
    const urlMap = await getTempFileUrls([image]);
    const finalImage = urlMap[image] || image;
    return { ...goods, mainImage: finalImage, image: finalImage };
  },

  async normalizeGoodsImageList(list) {
    if (!list || list.length === 0) return [];
    const fileIds = list.map((item) => item.mainImage || item.image).filter((id) => id && id.startsWith('cloud://'));
    const urlMap = fileIds.length > 0 ? await getTempFileUrls(fileIds) : {};
    return list.map((item) => {
      const rawImage = item.mainImage || item.image || '';
      const image = urlMap[rawImage] || rawImage;
      const stock = typeof item.stock === 'number' ? item.stock : (typeof item.flashStock === 'number' ? item.flashStock : 0);
      return { ...item, mainImage: image, image, stock };
    });
  },

  unwrapData(response) {
    if (response && typeof response === 'object' && Object.prototype.hasOwnProperty.call(response, 'data')) return response.data || {};
    return response || {};
  },

  parseTimeToTimestamp(timeValue) {
    if (!timeValue) return 0;
    if (typeof timeValue === 'number') return timeValue;
    const ts = new Date(String(timeValue).replace(/-/g, '/')).getTime();
    return Number.isNaN(ts) ? 0 : ts;
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
    const remain = this.data.flashEndTimestamp - Date.now();
    if (remain <= 0) {
      this.setData({ flashCountdown: '00:00:00' });
      this.clearFlashCountdown();
      return;
    }
    const hour = Math.floor(remain / (1000 * 60 * 60));
    const minute = Math.floor((remain % (1000 * 60 * 60)) / (1000 * 60));
    const second = Math.floor((remain % (1000 * 60)) / 1000);
    this.setData({ flashCountdown: `${this.pad2(hour)}:${this.pad2(minute)}:${this.pad2(second)}` });
  },

  pad2(num) { return num < 10 ? `0${num}` : `${num}`; },

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

  onSearchTap() { wx.navigateTo({ url: this.data.paths.search }); },
  onRecommendMoreTap() { wx.navigateTo({ url: `${this.data.paths.goods}?type=recommend` }); },

  onRecommendTap() {
    const { dailyRecommend, paths } = this.data;
    if (!dailyRecommend) return;
    wx.navigateTo({ url: `${paths.goodsDetail}?id=${dailyRecommend.id}` });
  },

  onRecommendAdd() {
    const { dailyRecommend } = this.data;
    if (!dailyRecommend || !dailyRecommend.id) return;
    this.addToCart(dailyRecommend.id);
  },
  onFlashMoreTap() { wx.navigateTo({ url: `${this.data.paths.goods}?type=flash` }); },

  onFlashTap(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `${this.data.paths.goodsDetail}?id=${id}` });
  },

  onFlashAdd(e) {
    const { id } = e.currentTarget.dataset;
    const target = this.data.flashSaleList.find((item) => `${item.id}` === `${id}`);
    if (!target) return;
    if (Number(target.stock || 0) <= 0) {
      wx.showToast({ title: '秒杀已售罄', icon: 'none' });
      return;
    }
    this.addToCart(id);
  },

  onNavTap(e) {
    const { type } = e.currentTarget.dataset;
    const { paths } = this.data;
    const urlMap = {
      seasonal: `${paths.goods}?type=seasonal`,
      hot: `${paths.goods}?type=hot`,
      flash: `${paths.goods}?type=flash`,
      category: paths.category
    };
    const target = urlMap[type] || paths.goods;
    if (target === paths.category) wx.switchTab({ url: target });
    else wx.navigateTo({ url: target });
  },

  onTraceTap(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    const goodsId = Number(e.currentTarget.dataset.goodsId || 0);
    const name = e.currentTarget.dataset.name || '';
    const desc = e.currentTarget.dataset.desc || '';
    const meta = e.currentTarget.dataset.meta || '';
    wx.navigateTo({
      url: `/pages/trace-detail/trace-detail?id=${id}&goodsId=${goodsId}&name=${encodeURIComponent(name)}&desc=${encodeURIComponent(desc)}&meta=${encodeURIComponent(meta)}`
    });
  },

  onTraceMoreTap() {
    wx.navigateTo({ url: '/pages/trace-detail/trace-detail' });
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
    this.addToCart(item.id);
  },

  addToCart(goodsId, quantity = 1) {
    const userId = app.getUserId && app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }
    post(`/cart/add?userId=${userId}&goodsId=${goodsId}&quantity=${quantity}`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => showRequestError(error, '加入购物车失败'));
  }
});

