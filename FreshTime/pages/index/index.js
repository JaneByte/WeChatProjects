// pages/index/index.js
const { getTempFileUrls } = require('../../utils/cloud.js');

Page({
  data: {
    // 基础文案
    brandName: 'FreshTime',
    brandSub: '鲜时刻',
    greetingWords: '早安，新鲜蔬果已经到店',
    newArrivalCount: 12,
    searchIcon: '/assets/icon/search.png',
    searchPlaceholder: '搜索蔬果 / 产地 / 秒杀',

    // 模块文案
    heroTitle: '今日推荐',
    heroBadge: '每日精选',
    moreText: '更多 >',
    waterfallTitle: '本周热销',
    priceSymbol: '¥',
    addBtnText: '+',
    loadingText: '正在加载...',
    noMoreText: '—— 已经到底啦 ——',

    // 路由配置
    paths: {
      search: '/pages/search/search',
      goods: '/pages/goods/goods',
      goodsDetail: '/pages/goodsDetail/goodsDetail',
      category: '/pages/category/category'
    },

    // 顶部与推荐
    statusBarHeight: 44,
    dailyRecommend: null,

    // 秒杀
    flashCountdown: '00:00:00',
    flashEndTimestamp: 0,
    flashSaleList: [],

    // 功能入口
    navList: [
      { type: 'seasonal', text: '时令优选', iconText: '时' },
      { type: 'hot', text: '热销爆款', iconText: '热' },
      { type: 'flash', text: '限时秒杀', iconText: '秒' },
      { type: 'category', text: '全部分类', iconText: '分' }
    ],

    // 产地溯源
    traceList: [
      { id: 't1', name: '山东寿光', desc: '当日采收，次日发货', meta: '蔬菜基地直采' },
      { id: 't2', name: '云南高原', desc: '高海拔慢生长，更香甜', meta: '水果产区直供' },
      { id: 't3', name: '海南乐东', desc: '热带日照足，口感更稳定', meta: '产地溯源可查' }
    ],

    // 商品流
    goodsList: [],
    leftColumnList: [],
    rightColumnList: [],
    page: 1,
    pageSize: 10,
    loadingMore: false,
    noMore: false
  },

  onLoad() {
    const systemInfo = wx.getSystemInfoSync();
    const safeAreaTop = systemInfo.safeArea?.top || systemInfo.statusBarHeight || 44;
    this.setData({ statusBarHeight: safeAreaTop + 8 });

    this.generateGreeting();
    this.loadDailyRecommend();
    this.loadFlashSale();
    this.loadGoods();
  },

  onShow() {
    if (this.data.flashEndTimestamp > Date.now() && !this.countdownTimer) {
      this.startFlashCountdown();
    }
  },

  onHide() {
    this.clearFlashCountdown();
  },

  onUnload() {
    this.clearFlashCountdown();
  },

  // 时间段问候
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

  // 今日推荐
  async loadDailyRecommend() {
    const hour = new Date().getHours();
    let recommend = {};

    if (hour >= 6 && hour < 11) {
      recommend = {
        id: 'r1',
        name: '奶油草莓',
        desc: '清晨采摘，果香浓郁，甜感稳定',
        price: 19.9,
        unit: '300g',
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/strawberry.webp'
      };
    } else if (hour >= 11 && hour < 18) {
      recommend = {
        id: 'r2',
        name: '樱桃番茄组合',
        desc: '沙瓤多汁，午后轻食的高频选择',
        price: 16.8,
        unit: '组合',
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cherry-tomato.webp'
      };
    } else {
      recommend = {
        id: 'r3',
        name: '蓝莓大果',
        desc: '颗粒饱满，酸甜平衡，晚间轻负担',
        price: 18.9,
        unit: '125g',
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/blueberry.webp'
      };
    }

    const urlMap = await getTempFileUrls([recommend.image]);
    recommend.image = urlMap[recommend.image] || recommend.image;
    this.setData({ dailyRecommend: recommend });
  },

  // 秒杀模块
  async loadFlashSale() {
    const flashSaleList = [
      {
        id: 'f1',
        name: '脆甜黄瓜',
        price: 4.9,
        originPrice: 7.9,
        stock: 36,
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cucumber.webp'
      },
      {
        id: 'f2',
        name: '精品香蕉',
        price: 5.9,
        originPrice: 8.8,
        stock: 22,
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/banana.webp'
      },
      {
        id: 'f3',
        name: '鲜番茄',
        price: 6.9,
        originPrice: 9.8,
        stock: 28,
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/tomato.webp'
      }
    ];

    const urlMap = await getTempFileUrls(flashSaleList.map((item) => item.image));
    const listWithUrls = flashSaleList.map((item) => ({
      ...item,
      image: urlMap[item.image] || item.image
    }));

    const flashEndTimestamp = Date.now() + 2 * 60 * 60 * 1000;
    this.setData({ flashSaleList: listWithUrls, flashEndTimestamp });
    this.startFlashCountdown();
  },

  startFlashCountdown() {
    this.clearFlashCountdown();
    this.updateFlashCountdown();
    this.countdownTimer = setInterval(() => {
      this.updateFlashCountdown();
    }, 1000);
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
    const flashCountdown = `${this.pad2(hour)}:${this.pad2(minute)}:${this.pad2(second)}`;
    this.setData({ flashCountdown });
  },

  pad2(num) {
    return num < 10 ? `0${num}` : `${num}`;
  },

  // 商品列表
  async loadGoods() {
    if (this.data.loadingMore || this.data.noMore) return;
    this.setData({ loadingMore: true });

    const newGoods = await this.fetchGoods(this.data.page);
    if (newGoods.length === 0) {
      this.setData({ noMore: true, loadingMore: false });
      return;
    }

    const allGoods = [...this.data.goodsList, ...newGoods];
    const leftColumnList = [];
    const rightColumnList = [];

    allGoods.forEach((item, index) => {
      if (index % 2 === 0) leftColumnList.push(item);
      else rightColumnList.push(item);
    });

    this.setData({
      goodsList: allGoods,
      leftColumnList,
      rightColumnList,
      page: this.data.page + 1,
      loadingMore: false
    });
  },

  fetchGoods(page) {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (page > 2) {
          resolve([]);
          return;
        }

        const mockGoods = [
          {
            id: 'g1',
            name: '樱桃番茄',
            price: 12.9,
            unit: '500g',
            image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cherry-tomato.webp',
            desc: '清甜多汁'
          },
          {
            id: 'g2',
            name: '蓝莓',
            price: 18.9,
            unit: '125g',
            image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/blueberry.webp',
            desc: '饱满大颗'
          },
          {
            id: 'g3',
            name: '奶油草莓',
            price: 19.9,
            unit: '300g',
            image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/strawberry.webp',
            desc: '果香浓郁'
          },
          {
            id: 'g4',
            name: '水果黄瓜',
            price: 5.9,
            unit: '500g',
            image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cucumber.webp',
            desc: '脆嫩爽口'
          },
          {
            id: 'g5',
            name: '普罗旺斯西红柿',
            price: 8.9,
            unit: '500g',
            image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/tomato.webp',
            desc: '沙瓤多汁'
          },
          {
            id: 'g6',
            name: '精品香蕉',
            price: 4.9,
            unit: '500g',
            image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/banana.webp',
            desc: '自然香甜'
          }
        ];

        getTempFileUrls(mockGoods.map((item) => item.image)).then((urlMap) => {
          const goodsWithUrls = mockGoods.map((item) => ({
            ...item,
            image: urlMap[item.image] || item.image
          }));
          resolve(goodsWithUrls);
        });
      }, 400);
    });
  },

  // 交互事件
  onScrollToLower() {
    this.loadGoods();
  },

  async onPullDownRefresh() {
    this.setData({
      page: 1,
      noMore: false,
      goodsList: [],
      leftColumnList: [],
      rightColumnList: []
    });

    this.generateGreeting();
    await this.loadDailyRecommend();
    await this.loadFlashSale();
    await this.loadGoods();
    wx.stopPullDownRefresh();
  },

  onSearchTap() {
    wx.navigateTo({ url: this.data.paths.search });
  },

  onRecommendMoreTap() {
    wx.navigateTo({ url: `${this.data.paths.goods}?type=recommend` });
  },

  onRecommendTap() {
    const { dailyRecommend, paths } = this.data;
    if (!dailyRecommend) return;
    wx.navigateTo({ url: `${paths.goodsDetail}?id=${dailyRecommend.id}` });
  },

  onRecommendAdd() {
    wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
  },

  onFlashMoreTap() {
    wx.navigateTo({ url: `${this.data.paths.goods}?type=flash` });
  },

  onFlashTap(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `${this.data.paths.goodsDetail}?id=${id}` });
  },

  onFlashAdd(e) {
    const { id } = e.currentTarget.dataset;
    const flashSaleList = this.data.flashSaleList.map((item) => {
      if (item.id === id && item.stock > 0) {
        return { ...item, stock: item.stock - 1 };
      }
      return item;
    });
    this.setData({ flashSaleList });
    wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
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
    const { id } = e.currentTarget.dataset;
    wx.showToast({ title: `查看 ${id} 产地信息`, icon: 'none', duration: 1200 });
  },

  onTraceMoreTap() {
    wx.showToast({ title: '产地溯源功能开发中', icon: 'none', duration: 1200 });
  },

  onMoreTap() {
    wx.navigateTo({ url: `${this.data.paths.goods}?type=weeklyHot` });
  },

  onGoodsTap(e) {
    const { item } = e.detail;
    wx.navigateTo({ url: `${this.data.paths.goodsDetail}?id=${item.id}` });
  },

  onAddToCart() {
    wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
  }
});
