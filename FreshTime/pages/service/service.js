const { get } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');

Page({
  data: {
    hotline: '400-888-1024',
    serviceTime: '09:00 - 21:00',
    faqList: [],
    loading: false,
    loadError: false
  },

  onShow() {
    this.loadData();
  },

  loadData() {
    this.setData({ loading: true });
    get('/service/info', {}, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        this.setData({
          hotline: data.hotline || '400-888-1024',
          serviceTime: data.serviceTime || '09:00 - 21:00',
          faqList: Array.isArray(data.faqList) ? data.faqList : [],
          loadError: false
        });
      })
      .catch((error) => {
        this.setData({ loadError: true });
        showRequestError(error, '客服信息加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  }
});
