// pages/index/index.js
const { getTempFileUrls } = require('../../utils/cloud.js');
Page({
  data: {
    // ==================== 配置项（文案、路径统一管理） ====================
    brandName: 'FreshTime',
    brandSub: '· 鲜时刻',
    searchIcon: '/assets/icon/search.png',
    searchPlaceholder: '搜索蔬果...',
    heroTitle: '今日鲜采',
    heroBadge: '每日精选',
    moreText: '更多 >',
    waterfallTitle: '更多好货',
    priceSymbol: '¥',
    addBtnText: '+',
    loadingText: '正在加载...',
    noMoreText: '— 已经到底啦 —',
    // 页面路径配置
    paths: {
      search: '/pages/search/search',
      goods: '/pages/goods/goods',
      goodsDetail: '/pages/goodsDetail/goodsDetail',
      category: '/pages/category/category'
    },
    // ==================== 业务数据 ====================
    statusBarHeight: 44,
    greetingEmoji: '🍃',
    greetingWords: '下午好，今天适合来点新鲜的',
    bannerList: [],
    // 氛围图配置：根据日期自动切换（每天一张）
    atmosphereBannerIndex: 0,
    dailyRecommend: null,
    goodsList: [],
    leftColumnList: [],
    rightColumnList: [],
    // 快捷入口配置
    navList: [
      { type: 'seasonal', text: '时令', icon: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/others/leaf.png' },
      { type: 'hot', text: '热销', icon: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/others/hot.png' },
      { type: 'recent', text: '常买', icon: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/others/recent.png' }
    ],
    page: 1,
    pageSize: 10,
    loadingMore: false,
    noMore: false,
    // 标记banner是否已加载过
    bannerLoaded: false
  },
  async onLoad() {
    const systemInfo = wx.getSystemSetting();
    const safeAreaTop = systemInfo.safeArea?.top || systemInfo.statusBarHeight || 44;
    
    // 计算今日氛围图索引
    const today = new Date().getDate();
    const bannerCount = 3; // 假设有3张banner图
    const todayIndex = (today - 1) % bannerCount;
    
    this.setData({ 
      statusBarHeight: safeAreaTop + 10,
      atmosphereBannerIndex: todayIndex
    });
    
    await this.generateGreeting();
    await this.initBanner();
    await this.loadDailyRecommend();
    await this.loadGoods();
  },
  // ==================== 生成问候语（融合天气） ====================
  async generateGreeting() {
    const hour = new Date().getHours();
    let timeGreeting = '';
    let emoji = '🍃';
    
    if (hour >= 6 && hour < 9) { timeGreeting = '早上好'; emoji = '☀️'; }
    else if (hour >= 9 && hour < 12) { timeGreeting = '上午好'; emoji = '🌤️'; }
    else if (hour >= 12 && hour < 14) { timeGreeting = '中午好'; emoji = '☀️'; }
    else if (hour >= 14 && hour < 18) { timeGreeting = '下午好'; emoji = '🌿'; }
    else if (hour >= 18 && hour < 22) { timeGreeting = '晚上好'; emoji = '🌙'; }
    else { timeGreeting = '夜深了'; emoji = '✨'; }
    
    try {
      const weather = await this.getWeatherBrief();
      const weatherSuggest = this.getWeatherSuggestion(weather);
      this.setData({ 
        greetingEmoji: emoji,
        greetingWords: `${timeGreeting}，${weatherSuggest}` 
      });
    } catch (e) {
      const defaultSuggest = this.getDefaultSuggestion(hour);
      this.setData({ 
        greetingEmoji: emoji,
        greetingWords: `${timeGreeting}，${defaultSuggest}` 
      });
    }
  },
  // ==================== 今日推荐事件（带时段判断） ====================
  onRecommendMoreTap() {
    const hour = new Date().getHours();
    let type = 'recommend';
    
    if (hour >= 6 && hour < 11) type = 'breakfast';
    else if (hour >= 11 && hour < 14) type = 'lunch';
    else if (hour >= 14 && hour < 18) type = 'afternoon';
    
    wx.navigateTo({ 
      url: `${this.data.paths.goods}?type=${type}` 
    });
  },
  onRecommendTap() {
    const { dailyRecommend, paths } = this.data;
    if (dailyRecommend) {
      wx.navigateTo({ url: `${paths.goodsDetail}?id=${dailyRecommend.id}` });
    }
  },
  onRecommendAdd(e) {
    const { dailyRecommend } = this.data;
    if (!dailyRecommend) return;
    
    wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
    const app = getApp();
    if (app && app.updateCartBadge) app.updateCartBadge();
  },
  // ==================== 天气相关 ====================
  getWeatherBrief() {
    return new Promise((resolve, reject) => {
      wx.getLocation({
        type: 'wgs84',
        success: (res) => {
          const apiKey = '40be3514612649da82d4dd53d01743da';
          const apiHost = 'https://qf6r6yuuux.re.qweatherapi.com';
          wx.request({
            url: `${apiHost}/v7/weather/now?location=${res.longitude},${res.latitude}&key=${apiKey}&lang=zh`,
            timeout: 8000,
            success: (resp) => {
              if (resp.data && resp.data.code === '200') resolve(resp.data.now);
              else reject('天气获取失败');
            },
            fail: reject
          });
        },
        fail: reject
      });
    });
  },
  getWeatherSuggestion(weather) {
    const text = weather.text || '';
    const temp = parseInt(weather.temp) || 20;
    if (text.includes('雨')) return '下雨天，在家吃新鲜水果吧';
    if (text.includes('雪')) return '天冷了，来点维C增强抵抗力';
    if (temp > 30) return '天气热，冰镇水果最解暑';
    if (temp < 10) return '注意保暖，多吃果蔬身体好';
    if (text.includes('晴')) return '天气不错，来点清爽果蔬吧';
    return '今天适合来点新鲜的';
  },
  getDefaultSuggestion(hour) {
    if (hour >= 6 && hour < 11) return '早餐来点新鲜水果吧';
    if (hour >= 11 && hour < 14) return '午餐搭配清爽时蔬';
    if (hour >= 14 && hour < 18) return '下午茶时间，来点酸甜的';
    return '新鲜果蔬，随时补充能量';
  },
  // ==================== 轮播图（带加载缓存） ====================
  async initBanner() {
    // 如果已加载过，不再重复请求
    if (this.data.bannerLoaded) return;
    
    const cloudFileIDs = [
      'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/strawberry.webp',
      'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/blueberry.webp',
      'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/papaya.webp'
    ];
    const urlMap = await getTempFileUrls(cloudFileIDs);
    const bannerList = cloudFileIDs.map((fileID, idx) => ({
      id: idx + 1,
      image: urlMap[fileID] || fileID
    }));
    this.setData({ 
      bannerList, 
      bannerLoaded: true 
    });
  },
  // ==================== 今日推荐 ====================
  async loadDailyRecommend() {
    const hour = new Date().getHours();
    let recommend;
    if (hour >= 6 && hour < 11) {
      recommend = {
        id: 'r1', name: '奶油草莓', desc: '清晨采摘，带着露珠的新鲜',
        price: 19.9, unit: '300g',
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/strawberry.webp'
      };
    } else if (hour >= 11 && hour < 14) {
      recommend = {
        id: 'r2', name: '樱桃番茄 + 水果黄瓜', desc: '清爽开胃，午餐好搭档',
        price: 18.8, unit: '组合',
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cherry-tomato.webp'
      };
    } else {
      recommend = {
        id: 'r3', name: '蓝莓', desc: '饱满大颗，护眼小能手',
        price: 18.9, unit: '125g',
        image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/blueberry.webp'
      };
    }
    const urlMap = await getTempFileUrls([recommend.image]);
    recommend.image = urlMap[recommend.image] || recommend.image;
    this.setData({ dailyRecommend: recommend });
  },
  // ==================== 商品列表 ====================
  async loadGoods() {
    if (this.data.loadingMore || this.data.noMore) return;
    this.setData({ loadingMore: true });
    
    const newGoods = await this.fetchGoods(this.data.page);
    if (newGoods.length === 0) {
      this.setData({ noMore: true, loadingMore: false });
      return;
    }
    
    const allGoods = [...this.data.goodsList, ...newGoods];
    
    const leftList = [];
    const rightList = [];
    
    allGoods.forEach((item, index) => {
      if (index % 2 === 0) leftList.push(item);
      else rightList.push(item);
    });
    
    this.setData({
      goodsList: allGoods,
      leftColumnList: leftList,
      rightColumnList: rightList,
      page: this.data.page + 1,
      loadingMore: false
    });
  },
  fetchGoods(page) {
    return new Promise((resolve) => {
      setTimeout(() => {
        if (page > 2) { resolve([]); return; }
        const mockGoods = [
          { id: 'g1', name: '樱桃番茄', price: 12.9, unit: '500g', image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cherry-tomato.webp', desc: '清甜多汁' },
          { id: 'g2', name: '蓝莓', price: 18.9, unit: '125g', image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/blueberry.webp', desc: '饱满大颗' },
          { id: 'g3', name: '草莓', price: 19.9, unit: '300g', image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/strawberry.webp', desc: '奶油草莓' },
          { id: 'g4', name: '水果黄瓜', price: 5.9, unit: '500g', image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/cucumber.webp', desc: '脆嫩爽口' },
          { id: 'g5', name: '普罗旺斯西红柿', price: 8.9, unit: '500g', image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/tomato.webp', desc: '沙瓤多汁' },
          { id: 'g6', name: '香蕉', price: 4.9, unit: '500g', image: 'cloud://cloudbase-0gymwbii3e34c141.636c-cloudbase-0gymwbii3e34c141-1422222822/banner/banana.webp', desc: '自然熟' }
        ];
        getTempFileUrls(mockGoods.map(g => g.image)).then(urlMap => {
          const goodsWithUrls = mockGoods.map(g => ({ ...g, image: urlMap[g.image] || g.image }));
          resolve(goodsWithUrls);
        });
      }, 500);
    });
  },
  // ==================== 事件处理 ====================
  onScrollToLower() { this.loadGoods(); },
  async onPullDownRefresh() {
    this.setData({
      goodsList: [], leftColumnList: [], rightColumnList: [],
      page: 1, noMore: false
    });
    await this.generateGreeting();
    // 刷新时不重置banner，保留缓存
    await this.loadDailyRecommend();
    await this.loadGoods();
    wx.stopPullDownRefresh();
  },
  onSearchTap() { wx.navigateTo({ url: this.data.paths.search }); },
  onNavTap(e) {
    const { type } = e.currentTarget.dataset;
    const { paths } = this.data;
    const urlMap = {
      seasonal: `${paths.goods}?type=seasonal`,
      hot: `${paths.goods}?type=hot`,
      recent: `${paths.goods}?type=recent`
    };
    wx.navigateTo({ url: urlMap[type] || paths.goods });
  },
  onBannerTap(e) {
    const { id } = e.currentTarget.dataset;
    console.log('氛围图点击', id);
  },
  // 新增：更多好货点击事件
  onMoreTap() {
    wx.switchTab({ url: this.data.paths.category });
  },
  onGoodsTap(e) {
    const { item } = e.detail;
    wx.navigateTo({ url: `${this.data.paths.goodsDetail}?id=${item.id}` });
  },
  onAddToCart(e) {
    const { item } = e.detail;
    wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
    const app = getApp();
    if (app && app.updateCartBadge) app.updateCartBadge();
  }
});