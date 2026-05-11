const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    title: '商品列表',
    scene: '',
    sceneMeta: null,
    sceneClass: '',
    list: [],
    loading: false,
    loadError: false
  },

  onLoad(options) {
    const type = options.type || '';
    const scene = options.scene || '';
    const sceneMetaMap = {
      '时令': {
        sceneClass: 'scene-seasonal',
        title: '当季鲜选',
        subtitle: '根据当季时令推荐，优先新鲜、口感稳定的蔬果',
        badge: '当季推荐',
        emptyText: '当前暂无当季商品，稍后再来看看',
        panelTitle: '本季推荐理由'
      },
      '小份量': {
        sceneClass: 'scene-small',
        title: '一人食小份',
        subtitle: '更适合一人餐桌，减少浪费，随买随吃',
        badge: '轻负担',
        emptyText: '当前暂无小份量商品，稍后再来看看',
        panelTitle: '一人食建议'
      },
      '搭配': {
        sceneClass: 'scene-combo',
        title: '蔬果搭配',
        subtitle: '按食用场景搭配组合，做饭和备餐更省心',
        badge: '组合推荐',
        emptyText: '当前暂无搭配商品，稍后再来看看',
        panelTitle: '搭配思路'
      }
    };
    const titleMap = {
      recommend: '今日推荐',
      newArrival: '今日上新',
      flash: '限时秒杀',
      hot: '热销爆款',
      seasonal: '时令优选',
      weeklyHot: '本周热销'
    };
    const sceneMeta = sceneMetaMap[scene] || null;
    this.setData({
      scene,
      sceneMeta,
      sceneClass: sceneMeta ? sceneMeta.sceneClass : '',
      title: sceneMeta ? sceneMeta.title : (titleMap[type] || '商品列表')
    });
    wx.setNavigationBarTitle({ title: this.data.title });
    this.loadList(type, scene);
  },

  loadList(type, scene) {
    this.setData({ loading: true, loadError: false });
    const mapSceneList = (rawList) => {
      const baseList = Array.isArray(rawList) ? rawList : [];
      return baseList.map((item) => ({ ...item, sceneHint: this.formatSceneHint(item) }));
    };
    if (scene) {
      get('/goods/list', { scene }, { retry: 0 })
        .then((res) => {
          const list = (res && res.data) || [];
          this.setData({ list: mapSceneList(list) });
        })
        .catch((error) => {
          this.setData({ list: [], loadError: true });
          showRequestError(error, '场景商品加载失败');
        })
        .finally(() => this.setData({ loading: false }));
      return;
    }
    if (type === 'newArrival' || type === 'flash') {
      get('/home/index', {}, { retry: 0 })
        .then((res) => {
          const data = (res && res.data) || {};
          const list = type === 'flash'
            ? (((data.flash || {}).list) || [])
            : (data.newArrivalList || []);
          this.setData({ list: mapSceneList(list) });
        })
        .catch((error) => {
          this.setData({ list: [], loadError: true });
          showRequestError(error, type === 'flash' ? '秒杀商品加载失败' : '上新商品加载失败');
        })
        .finally(() => this.setData({ loading: false }));
      return;
    }
    if (type === 'weeklyHot' || type === 'hot') {
      get('/home/goods', { page: 1, pageSize: 30 }, { retry: 0 })
        .then((res) => {
          const data = (res && res.data) || {};
          const list = data.list || [];
          this.setData({ list: mapSceneList(list) });
        })
        .catch((error) => {
          this.setData({ list: [], loadError: true });
          showRequestError(error, '热销商品加载失败');
        })
        .finally(() => this.setData({ loading: false }));
      return;
    }
    const endpoint = type === 'recommend' ? '/goods/recommend' : '/goods/list';
    get(endpoint, {}, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        this.setData({ list: mapSceneList(list) });
      })
      .catch((error) => {
        this.setData({ list: [], loadError: true });
        showRequestError(error, '商品加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onTapItem(e) {
    const { id } = e.currentTarget.dataset;
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}` });
  },

  onAddCart(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    const userId = app.getUserId && app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }
    post(`/cart/add?userId=${userId}&goodsId=${id}&quantity=1`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '已加入购物车', icon: 'success' });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => showRequestError(error, '加入购物车失败'));
  },

  formatSceneHint(item) {
    const scene = this.data.scene;
    if (scene === '时令') return item.origin ? `产地：${item.origin}` : '当季新鲜直达';
    if (scene === '小份量') return item.unit ? `小规格·${item.unit}` : '小规格更轻松';
    if (scene === '搭配') return item.keywords ? `搭配关键词：${item.keywords}` : '适合组合购买';
    return item.unit ? `规格：${item.unit}` : '';
  },

  formatSceneTag() {
    if (this.data.scene === '时令') return '当季';
    if (this.data.scene === '小份量') return '小份';
    if (this.data.scene === '搭配') return '搭配';
    return '';
  }
});
