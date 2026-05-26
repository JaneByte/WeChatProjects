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
    if (!app.getUserId()) {
      this.setData({ list: [] });
      app.requireLogin({ redirect: '/pages/address-list/address-list', silent: true }).catch(() => {});
      return;
    }

    this.setData({ loading: true });
    get('/address/list', {}, { retry: 0 })
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
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/address-list/address-list' }).catch(() => {});
      return;
    }
    wx.showModal({
      title: '确认删除',
      content: '删除后将无法恢复，是否继续？',
      confirmColor: '#c95f4a',
      success: (res) => {
        if (!res.confirm) return;
        del(`/address/delete?id=${id}`, {}, { retry: 0 })
          .then(() => {
            const selectedAddress = wx.getStorageSync('selectedAddress');
            if (selectedAddress && Number(selectedAddress.id) === Number(id)) {
              wx.removeStorageSync('selectedAddress');
            }
            wx.showToast({ title: '删除成功', icon: 'success' });
            this.loadList();
          })
          .catch((error) => showRequestError(error, '删除失败'));
      }
    });
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
