const { get, del } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    list: [],
    loading: false,
    selecting: false,
    loadError: false
  },

  onLoad(options) {
    this.setData({ selecting: options.select === '1' });
  },

  onShow() {
    this.loadList();
  },

  loadList() {
    const userId = app.getUserId();
    if (!userId) {
      this.setData({ list: [] });
      return;
    }

    this.setData({ loading: true });
    get('/address/list', { userId }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ list: Array.isArray(list) ? list : [], loadError: false });
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '地址加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onAdd() {
    wx.navigateTo({ url: '/pages/address-edit/address-edit' });
  },

  onEdit(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/address-edit/address-edit?id=${id}` });
  },

  onDelete(e) {
    const { id } = e.currentTarget.dataset;
    const userId = app.getUserId();
    if (!userId) return;

    del('/address/delete', { userId, id }, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '删除成功', icon: 'success' });
        this.loadList();
      })
      .catch((error) => showRequestError(error, '删除失败'));
  },

  onChoose(e) {
    if (!this.data.selecting) return;
    const { index } = e.currentTarget.dataset;
    const address = this.data.list[index];
    if (!address) return;
    wx.setStorageSync('selectedAddress', address);
    wx.navigateBack();
  },

  onRetryLoad() {
    this.loadList();
  }
});

