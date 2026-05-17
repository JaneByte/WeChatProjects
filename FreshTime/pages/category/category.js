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
    onlyInStock: false,
    specPopupVisible: false,
    specGoods: null,
    selectedSkuId: 0,
    addCartLoadingId: 0
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
      stock: item.stock !== undefined ? item.stock : 999,
      skuList: Array.isArray(item.skuList) ? item.skuList : []
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

    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/category/category' }).catch(() => {});
      return;
    }
    const selectedSku = this.getFirstAvailableSku(goods);
    if (!selectedSku) {
      wx.showToast({ title: '暂无可用规格', icon: 'none', duration: 1500 });
      return;
    }
    this.setData({
      specPopupVisible: true,
      specGoods: goods,
      selectedSkuId: Number(selectedSku.id || 0)
    });
  },

  onCloseSpecPopup() {
    if (this.data.addCartLoadingId) return;
    this.setData({
      specPopupVisible: false,
      specGoods: null,
      selectedSkuId: 0
    });
  },

  onSelectSku(e) {
    const skuId = Number(e.currentTarget.dataset.skuid || 0);
    if (!skuId) return;
    this.setData({ selectedSkuId: skuId });
  },

  onConfirmSpecAdd() {
    const goods = this.data.specGoods;
    if (!goods || !goods.id || this.data.addCartLoadingId) return;
    const selectedSku = this.getSelectedSku(goods, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '该规格库存不足', icon: 'none', duration: 1500 });
      return;
    }
    this.setData({ addCartLoadingId: Number(goods.id) });
    post(`/cart/add?goodsId=${goods.id}&skuId=${selectedSku.id}&quantity=1`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success', duration: 1200 });
        this.setData({
          specPopupVisible: false,
          specGoods: null,
          selectedSkuId: 0
        });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => showRequestError(error, '加入购物车失败'))
      .finally(() => this.setData({ addCartLoadingId: 0 }));
  },

  getFirstAvailableSku(goods = {}) {
    const list = Array.isArray(goods.skuList) ? goods.skuList : [];
    const enabled = list.filter((sku) => Number(sku.status) === 1 && Number(sku.skuStock || 0) > 0);
    if (!enabled.length) return null;
    const sorted = enabled.slice().sort((a, b) => Number(a.sort || 0) - Number(b.sort || 0));
    return sorted[0];
  },

  getSelectedSku(goods = {}, selectedSkuId = 0) {
    const list = Array.isArray(goods.skuList) ? goods.skuList : [];
    const matched = list.find((sku) => Number(sku.id) === Number(selectedSkuId || 0));
    return matched || this.getFirstAvailableSku(goods);
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
