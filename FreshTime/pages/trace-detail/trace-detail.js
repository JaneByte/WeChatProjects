const { get } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');

Page({
  data: {
    trace: {
      id: null,
      name: '产地专题',
      desc: '查看蔬果来源、采收与检测信息',
      meta: 'FreshTime 溯源中心'
    },
    list: [
      { label: '产地位置', value: '广西百色' },
      { label: '采收日期', value: '2026-04-26' },
      { label: '质检批次', value: 'FT-TRACE-240426' },
      { label: '冷链状态', value: '全程冷链在途' }
    ],
    loading: false
  },

  onLoad(options) {
    const id = Number(options.id || 0) || null;
    const goodsId = Number(options.goodsId || options.id || 0) || null;
    const name = options.name ? decodeURIComponent(options.name) : '';
    const desc = options.desc ? decodeURIComponent(options.desc) : '';
    const meta = options.meta ? decodeURIComponent(options.meta) : '';
    this.setData({
      trace: {
        id,
        name: name || this.data.trace.name,
        desc: desc || this.data.trace.desc,
        meta: meta || this.data.trace.meta
      }
    });
    if (goodsId) {
      this.loadTraceDetail(goodsId);
    }
  },

  loadTraceDetail(goodsId) {
    this.setData({ loading: true });
    get('/trace/detail', { goodsId }, { retry: 0 })
      .then((res) => {
        const data = (res && res.data) || {};
        this.setData({
          trace: data.trace || this.data.trace,
          list: Array.isArray(data.list) ? data.list : this.data.list
        });
      })
      .catch((error) => showRequestError(error, '溯源信息加载失败'))
      .finally(() => this.setData({ loading: false }));
  }
});
