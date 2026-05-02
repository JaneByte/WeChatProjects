const { getTempFileUrls, processGoodsImages } = require('../../utils/cloud.js');
const { get, post } = require('../../utils/request.js');
const { showRequestError } = require('../../utils/ui.js');
const app = getApp();

Page({
  data: {
    currentTab: 'fruit',
    currentCategoryId: null,
    categoryList: [],
    goodsList: [],
    filteredGoodsList: [],
    currentCategory: {},
    fruitCategories: [],
    vegetableCategories: [],
    loading: false,
    loadError: false,
    filterKeyword: '',
    onlyInStock: false
  },

  onLoad() {
    this.loadCategoryTree();
  },

  onShow() {
    if (app && app.updateCartBadge) app.updateCartBadge();
  },

  loadCategoryTree() {
    this.setData({ loading: true });
    get('/category/tree', {}, { timeout: 60000 })
      .then((res) => {
        const treeData = res.data || [];
        this.setData({ loadError: false });
        this.processCategoryData(treeData);
      })
      .catch((err) => {
        this.setData({ loadError: true });
        showRequestError(err, '分类加载失败');
      })
      .finally(() => {
        this.setData({ loading: false });
        wx.stopPullDownRefresh();
      });
  },

  processCategoryData(treeData) {
    const vegetableData = treeData.find((item) => item.id === 1) || { children: [] };
    const fruitData = treeData.find((item) => item.id === 2) || { children: [] };

    this.setData({
      vegetableCategories: vegetableData.children || [],
      fruitCategories: fruitData.children || []
    });

    this.loadCategoryData();
  },

  loadCategoryData() {
    const { currentTab, fruitCategories, vegetableCategories } = this.data;
    const categories = currentTab === 'fruit' ? fruitCategories : vegetableCategories;

    if (!categories.length) {
      this.setData({ categoryList: [], currentCategoryId: null, currentCategory: {}, goodsList: [], filteredGoodsList: [] });
      return;
    }

    const categoryList = categories.map((item) => ({ ...item, iconUrl: item.icon || '' }));
    const firstCategory = categoryList[0];

    this.setData({ categoryList, currentCategoryId: firstCategory.id, currentCategory: firstCategory });
    this.convertCategoryIcons(categoryList);
    this.loadGoodsData(firstCategory.id);
  },

  async convertCategoryIcons(categoryList) {
    const fileList = categoryList
      .filter((item) => item.icon && item.icon.startsWith('cloud://'))
      .map((item) => item.icon);

    if (!fileList.length) return;

    const urlMap = await getTempFileUrls(fileList);
    const updatedList = categoryList.map((item) => ({
      ...item,
      iconUrl: item.icon && urlMap[item.icon] ? urlMap[item.icon] : item.icon
    }));

    this.setData({ categoryList: updatedList });
    const currentCategory = updatedList.find((item) => item.id === this.data.currentCategoryId);
    if (currentCategory) this.setData({ currentCategory });
  },

  loadGoodsData(categoryId) {
    this.setData({ loading: true });
    get('/goods/list', { categoryId }, { timeout: 30000 })
      .then((res) => {
        const rawData = res.data || [];
        this.setData({ loadError: false });
        this.processGoodsData(rawData);
      })
      .catch((err) => {
        this.setData({ goodsList: [], filteredGoodsList: [], loadError: true });
        showRequestError(err, '商品加载失败');
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  processGoodsData(rawData) {
    const goodsList = (rawData || []).map((item) => ({
      id: item.id,
      name: item.name,
      price: item.price,
      unit: item.unit || '件',
      desc: item.subtitle || '',
      sales: item.salesVolume || 0,
      image: item.mainImage,
      stock: item.stock !== undefined ? item.stock : 999
    }));

    this.setData({ goodsList }, () => this.applyFilters());
    processGoodsImages(goodsList, this.setData.bind(this), 'goodsList');
  },

  applyFilters() {
    const { goodsList, filterKeyword, onlyInStock } = this.data;
    const keyword = (filterKeyword || '').trim().toLowerCase();
    const filtered = goodsList.filter((item) => {
      const keywordMatch = !keyword || String(item.name || '').toLowerCase().includes(keyword);
      const stockMatch = !onlyInStock || Number(item.stock || 0) > 0;
      return keywordMatch && stockMatch;
    });
    this.setData({ filteredGoodsList: filtered });
  },

  onFilterInput(e) {
    this.setData({ filterKeyword: e.detail.value || '' }, () => this.applyFilters());
  },

  onToggleStock() {
    this.setData({ onlyInStock: !this.data.onlyInStock }, () => this.applyFilters());
  },

  onClearFilter() {
    this.setData({ filterKeyword: '', onlyInStock: false }, () => this.applyFilters());
  },

  switchTab(e) {
    const tab = e.currentTarget.dataset.tab;
    if (tab === this.data.currentTab) return;
    this.setData({ currentTab: tab, goodsList: [], filteredGoodsList: [] });
    this.loadCategoryData();
  },

  selectCategory(e) {
    const categoryId = e.currentTarget.dataset.id;
    const currentCategory = this.data.categoryList.find((item) => item.id === categoryId) || {};
    this.setData({ currentCategoryId: categoryId, currentCategory });
    this.loadGoodsData(categoryId);
  },

  goToSearch() {
    wx.navigateTo({ url: '/pages/search/search' });
  },

  goToDetail(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  },

  addToCart(e) {
    const goodsId = e.currentTarget.dataset.id;
    const goods = this.data.goodsList.find((item) => item.id === goodsId);
    if (!goods) return;

    if (Number(goods.stock || 0) <= 0) {
      wx.showToast({ title: '暂无库存', icon: 'none', duration: 1500 });
      return;
    }

    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none', duration: 1500 });
      return;
    }

    post(`/cart/add?userId=${userId}&goodsId=${goodsId}&quantity=1`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => showRequestError(error, '加入购物车失败'));
  },

  onPullDownRefresh() {
    this.loadCategoryTree();
  },

  onRetryLoad() {
    if (this.data.currentCategoryId) {
      this.loadGoodsData(this.data.currentCategoryId);
      return;
    }
    this.loadCategoryTree();
  }
});
