const { get } = require('../../utils/request');

Page({
  data: {
    title: '商品列表',
    list: [],
    loading: false
  },

  onLoad(options) {
    const type = options.type || '';
    const titleMap = {
      recommend: '今日推荐',
      flash: '限时秒杀',
      hot: '热销爆款',
      seasonal: '时令优选',
      weeklyHot: '本周热销'
    };
    this.setData({ title: titleMap[type] || '商品列表' });
    wx.setNavigationBarTitle({ title: this.data.title });
    this.loadList(type);
  },

  loadList(type) {
    this.setData({ loading: true });
    const endpoint = type === 'recommend' ? '/goods/recommend' : '/goods/list';
    get(endpoint, {}, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ list: Array.isArray(list) ? list : [] });
      })
      .finally(() => this.setData({ loading: false }));
  },

  onTapItem(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  }
});
