// pages/category/category.js
const { getTempFileUrls, processGoodsImages } = require('../../utils/cloud.js');
const { get } = require('../../utils/request.js');
const { showRequestError } = require('../../utils/ui.js');
const app = getApp();

Page({
  data: {
    currentTab: 'fruit',
    currentCategoryId: null,
    categoryList: [],
    goodsList: [],
    currentCategory: {},
    fruitCategories: [],
    vegetableCategories: [],
    loading: false
  },

  onLoad() {
    this.loadCategoryTree();
  },

  onShow() {
    if (app && app.updateCartBadge) {
      app.updateCartBadge();
    }
  },

  loadCategoryTree() {
    this.setData({ loading: true });
    get('/category/tree', {}, { timeout: 60000 })
      .then((res) => {
        const treeData = res.data || [];
        this.processCategoryData(treeData);
      })
      .catch((err) => {
        console.error('接口请求失败: category/tree', err);
        showRequestError(err, '加载失败');
      })
      .finally(() => {
        this.setData({ loading: false });
        wx.stopPullDownRefresh();
      });
  },

  processCategoryData(treeData) {
    const vegetableData = treeData.find((item) => item.id === 1) || { children: [] };
    const fruitData = treeData.find((item) => item.id === 2) || { children: [] };

    const vegetableChildren = vegetableData.children || [];
    const fruitChildren = fruitData.children || [];

    this.setData({
      vegetableCategories: vegetableChildren,
      fruitCategories: fruitChildren
    });

    this.loadCategoryData();
  },

  loadCategoryData() {
    const { currentTab, fruitCategories, vegetableCategories } = this.data;
    const categories = currentTab === 'fruit' ? fruitCategories : vegetableCategories;

    if (categories.length === 0) {
      this.setData({
        categoryList: [],
        currentCategoryId: null,
        currentCategory: {},
        goodsList: []
      });
      return;
    }

    const firstCategoryId = categories[0].id;

    const categoryList = categories.map((item) => ({
      ...item,
      iconUrl: item.icon || ''
    }));

    this.setData({
      categoryList,
      currentCategoryId: firstCategoryId,
      currentCategory: categoryList[0] || {}
    });

    this.convertCategoryIcons(categoryList);

    if (firstCategoryId) {
      this.loadGoodsData(firstCategoryId);
    }
  },

  async convertCategoryIcons(categoryList) {
    const fileList = categoryList
      .filter((item) => item.icon && item.icon.startsWith('cloud://'))
      .map((item) => item.icon);

    if (fileList.length === 0) return;

    const urlMap = await getTempFileUrls(fileList);

    const updatedList = categoryList.map((item) => {
      if (item.icon && urlMap[item.icon]) {
        return { ...item, iconUrl: urlMap[item.icon] };
      }
      return { ...item, iconUrl: item.icon };
    });

    this.setData({ categoryList: updatedList });

    const currentCategory = updatedList.find((item) => item.id === this.data.currentCategoryId);
    if (currentCategory) {
      this.setData({ currentCategory });
    }
  },

  loadGoodsData(categoryId) {
    this.setData({ loading: true });
    get('/goods/list', { categoryId }, { timeout: 30000 })
      .then((res) => {
        const rawData = res.data || [];
        this.processGoodsData(rawData);
      })
      .catch((err) => {
        console.error('接口请求失败: goods/list', err);
        this.setData({ goodsList: [] });
        showRequestError(err, '加载失败');
      })
      .finally(() => {
        this.setData({ loading: false });
      });
  },

  processGoodsData(rawData) {
    if (rawData.length === 0) {
      this.setData({ goodsList: [] });
      return;
    }

    const goodsList = rawData.map((item) => ({
      id: item.id,
      name: item.name,
      price: item.price,
      unit: item.unit || '份',
      desc: item.subtitle || '',
      sales: item.salesVolume || 0,
      image: item.mainImage,
      stock: item.stock !== undefined ? item.stock : 999
    }));

    this.setData({ goodsList });
    processGoodsImages(goodsList, this.setData.bind(this), 'goodsList');
  },

  switchTab(e) {
    const tab = e.currentTarget.dataset.tab;
    if (tab === this.data.currentTab) return;

    this.setData({
      currentTab: tab,
      goodsList: []
    });

    this.loadCategoryData();
  },

  selectCategory(e) {
    const categoryId = e.currentTarget.dataset.id;
    const { categoryList } = this.data;
    const currentCategory = categoryList.find((item) => item.id === categoryId) || {};

    this.setData({
      currentCategoryId: categoryId,
      currentCategory
    });

    this.loadGoodsData(categoryId);
  },

  goToSearch() {
    wx.navigateTo({
      url: '/pages/search/search'
    });
  },

  goToDetail(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({
      url: `/pages/goodsDetail/goodsDetail?id=${id}`
    });
  },

  addToCart(e) {
    const goodsId = e.currentTarget.dataset.id;
    const { goodsList } = this.data;
    const goods = goodsList.find((item) => item.id === goodsId);

    if (!goods) return;

    if (goods.stock <= 0) {
      wx.showToast({
        title: '暂无库存',
        icon: 'none',
        duration: 1500
      });
      return;
    }

    const { cartList } = app.globalData;
    const existItemIndex = cartList.findIndex((item) => item.id === goodsId);

    if (existItemIndex !== -1) {
      const existItem = cartList[existItemIndex];
      const newQuantity = existItem.quantity + 1;

      if (newQuantity > goods.stock) {
        wx.showToast({
          title: `库存仅剩${goods.stock}件`,
          icon: 'none',
          duration: 1500
        });
        return;
      }
      cartList[existItemIndex].quantity = newQuantity;
    } else {
      cartList.push({
        id: goods.id,
        name: goods.name,
        price: goods.price,
        unit: goods.unit,
        desc: goods.desc,
        image: goods.image,
        stock: goods.stock,
        quantity: 1,
        selected: true
      });
    }

    app.syncCartToStorage();

    wx.showToast({
      title: '已加入购物车',
      icon: 'success',
      duration: 1500
    });
  },

  onPullDownRefresh() {
    this.loadCategoryTree();
  }
});
