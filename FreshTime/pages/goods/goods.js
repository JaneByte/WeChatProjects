const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    currentType: '',
    title: '商品列表',
    scene: '',
    sceneMeta: null,
    sceneClass: '',
    list: [],
    fullList: [],
    sceneFilterOptions: [],
    activeSceneFilter: 'all',
    selectedSkuId: 0,
    comboPackTips: '',
    flashEndTimestamp: 0,
    addCartLoadingId: 0,
    specPopupVisible: false,
    specGoods: null,
    loading: false,
    loadError: false
  },

  onLoad(options) {
    this.pageActive = true;
    const type = options.type || '';
    const scene = this.normalizeSceneParam(options.scene || '');
    if (scene === '小份量') {
      wx.redirectTo({ url: '/pages/meal-config/meal-config' });
      return;
    }
    if (scene === '搭配') {
      wx.redirectTo({ url: '/pages/combo-config/combo-config' });
      return;
    }
    const sceneMetaMap = {
      '时令': {
        sceneClass: 'scene-seasonal',
        title: '当季精选',
        subtitle: '优先挑出口感更稳、更新鲜、也更适合买的当季蔬果',
        badge: '当季推荐',
        emptyText: '当前筛选下暂无当季商品，换个条件试试',
        panelTitle: '本季推荐理由'
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
      currentType: type,
      scene,
      sceneMeta,
      sceneClass: sceneMeta ? sceneMeta.sceneClass : '',
      sceneFilterOptions: sceneMeta && Array.isArray(sceneMeta.filterOptions) ? sceneMeta.filterOptions : [],
      activeSceneFilter: 'all',
      selectedSkuId: 0,
      comboPackTips: sceneMeta && sceneMeta.comboPackTips ? sceneMeta.comboPackTips : '',
      title: sceneMeta ? sceneMeta.title : (titleMap[type] || '商品列表')
    });
    wx.setNavigationBarTitle({ title: this.data.title });
    this.loadList(type, scene);
  },

  normalizeSceneParam(sceneValue = '') {
    const raw = `${sceneValue || ''}`.trim();
    if (!raw) return '';
    try {
      const decoded = decodeURIComponent(raw);
      return `${decoded || ''}`.trim();
    } catch (error) {
      return raw;
    }
  },

  loadList(type, scene) {
    this.setData({ loading: true, loadError: false });
    const mapSceneList = (rawList) => {
      const baseList = Array.isArray(rawList) ? rawList : [];
      return baseList.map((item) => {
        const compact = {
          id: item.id,
          categoryId: item.categoryId,
          name: item.name || '',
          mainImage: item.mainImage || '',
          price: item.price,
          originalPrice: item.originalPrice,
          stock: item.stock,
          isFlash: item.isFlash,
          flashPrice: item.flashPrice,
          flashStock: item.flashStock,
          flashStartTime: item.flashStartTime,
          flashEndTime: item.flashEndTime,
          unit: item.unit || '件',
          salesVolume: item.salesVolume || 0,
          origin: item.origin || '',
          keywords: item.keywords || '',
          sceneType: item.sceneType || '',
          comboMode: item.comboMode || '',
          packType: item.packType || '',
          couponThresholdHint: item.couponThresholdHint || '',
          skuList: Array.isArray(item.skuList) ? item.skuList.slice(0, 6) : []
        };
        const sceneHint = this.formatSceneHint(item);
        const sceneType = this.resolveSceneType(item);
        const firstSku = this.getFirstAvailableSku(item);
        const displayPrice = this.getSkuDisplayPrice(firstSku, item.price);
        const flashPrice = this.getFlashPrice(item);
        const flashStock = this.parseNumberField(item.flashStock || item.flash_stock, 0);
        const flashPercent = this.calcFlashDisplayPercent(item, item.stock, flashStock);
        const flashEndTimestamp = this.parseTimeToTimestamp(item.flashEndTime || item.flash_end_time || 0);
        const flashRemainText = this.formatFlashRemainText(flashEndTimestamp);
        const flashSpecText = this.buildFlashSpecText(item);
        const comboBadge = this.resolveComboBadge(sceneType);
        const couponThresholdHint = item.couponThresholdHint || this.resolveCouponThresholdHintByPrice(item);
        return {
          ...compact,
          sceneHint,
          sceneType,
          displayPrice,
          flashPrice,
          flashPercent,
          flashEndTimestamp,
          flashRemainText,
          flashSpecText,
          comboBadge,
          couponThresholdHint
        };
      });
    };
    const updateListState = (rawList) => {
      const fullList = mapSceneList(rawList).slice(0, 30);
      const filteredList = this.applySceneFilter(fullList, this.data.activeSceneFilter);
      this.setData({
        fullList,
        list: filteredList
      });
    };
    if (scene) {
      get('/goods/list', { scene }, { retry: 0 })
        .then((res) => {
          const list = (res && res.data) || [];
          updateListState(list);
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
          const flash = data.flash || {};
          const list = type === 'flash'
            ? (flash.list || [])
            : (data.newArrivalList || []);
          updateListState(list);
          if (type === 'flash') {
            const endTs = this.parseTimeToTimestamp(flash.endTime);
            this.setData({ flashEndTimestamp: endTs });
            if (endTs > Date.now()) this.startFlashCountdown();
          }
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
          updateListState(list);
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
        updateListState(list);
      })
      .catch((error) => {
        this.setData({ list: [], loadError: true });
        showRequestError(error, '商品加载失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onTapItem(e) {
    const { id } = e.currentTarget.dataset;
    const extra = this.data.currentType === 'flash'
      ? `&sourceType=FLASH&sourceScene=${encodeURIComponent('限时秒杀')}`
      : '';
    wx.navigateTo({ url: `/pages/goodsDetail/goodsDetail?id=${id}${extra}` });
  },

  onAddCart(e) {
    const id = Number(e.currentTarget.dataset.id || 0);
    if (!id) return;
    if (this.data.addCartLoadingId) return;
    const target = (this.data.list || []).find((item) => Number(item.id) === id) || null;
    if (!target) return;
    if (this.data.currentType === 'flash') {
      if (!app.getUserId()) {
        app.requireLogin({ redirect: '/pages/goods/goods?type=flash' }).catch(() => {});
        return;
      }
      const selectedSku = this.getFirstAvailableSku(target);
      if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
        wx.showToast({ title: '当前默认规格库存不足', icon: 'none' });
        return;
      }
      this.setData({ addCartLoadingId: Number(target.id) });
      post(`/cart/add?goodsId=${target.id}&skuId=${selectedSku.id}&quantity=1&sourceType=FLASH&sourceScene=${encodeURIComponent('限时秒杀')}`, {}, { retry: 0 })
        .then(() => {
          wx.showToast({ title: '已加入购物车', icon: 'success' });
          if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
        })
        .catch((error) => {
          if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
            return;
          }
          showRequestError(error, '加入购物车失败');
        })
        .finally(() => this.setData({ addCartLoadingId: 0 }));
      return;
    }
    this.setData({
      specPopupVisible: true,
      specGoods: target,
      selectedSkuId: Number((this.getFirstAvailableSku(target) || {}).id || 0)
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
    const target = this.data.specGoods;
    if (!target || !target.id) return;
    if (this.data.addCartLoadingId) return;
    const selectedSku = this.getSelectedSku(target, this.data.selectedSkuId);
    if (!selectedSku || Number(selectedSku.skuStock || 0) <= 0) {
      wx.showToast({ title: '该规格库存不足', icon: 'none' });
      return;
    }
    const quantity = 1;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: `/pages/goods/goods?type=${encodeURIComponent(this.options.type || '')}&scene=${encodeURIComponent(this.options.scene || '')}` }).catch(() => {});
      return;
    }
    this.setData({ addCartLoadingId: Number(target.id) });
    const sourceQuery = this.data.currentType === 'flash'
      ? `&sourceType=FLASH&sourceScene=${encodeURIComponent('限时秒杀')}`
      : '';
    post(`/cart/add?goodsId=${target.id}&skuId=${selectedSku.id}&quantity=${quantity}${sourceQuery}`, {}, { retry: 0 })
      .then(() => {
        wx.showToast({ title: `已加入购物车 x${quantity}`, icon: 'success' });
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
        this.setData({
          specPopupVisible: false,
          specGoods: null,
          selectedSkuId: 0
        });
      })
      .catch((error) => {
        if (error && (error.message === 'LOGIN_REQUIRED' || error.message === 'LOGIN_TIMEOUT' || error.message === 'MANUAL_LOGOUT')) {
          return;
        }
        showRequestError(error, '加入购物车失败');
      })
      .finally(() => this.setData({ addCartLoadingId: 0 }));
  },

  onSceneFilterTap(e) {
    const key = `${e.currentTarget.dataset.key || 'all'}`;
    const filteredList = this.applySceneFilter(this.data.fullList || [], key);
    this.setData({
      activeSceneFilter: key,
      list: filteredList
    });
  },

  applySceneFilter(list, filterKey) {
    const source = Array.isArray(list) ? list : [];
    if (!this.data.scene || filterKey === 'all') return source;
    return source.filter((item) => `${item.sceneType || 'all'}` === `${filterKey}`);
  },

  resolveSceneType(item = {}) {
    if (item.sceneType) return `${item.sceneType}`;
    return 'all';
  },

  resolveComboBadge(sceneType) {
    if (sceneType === 'single') return '小份装';
    if (sceneType === 'platter') return '拼盘';
    if (sceneType === 'fixed') return '固定搭配';
    if (sceneType === 'random') return '随机搭配';
    return '';
  },

  getFirstAvailableSku(item = {}) {
    const list = Array.isArray(item.skuList) ? item.skuList : [];
    const enabled = list.filter((sku) => Number(sku.status) === 1);
    if (!enabled.length) return null;
    const sorted = enabled.slice().sort((a, b) => Number(a.sort || 0) - Number(b.sort || 0));
    const standardSku = sorted.find((sku) => {
      const name = `${sku.skuName || ''}`.trim();
      return name.includes('标准') || name.includes('默认');
    });
    return standardSku || sorted[0];
  },

  getSelectedSku(item = {}, selectedSkuId = 0) {
    const list = Array.isArray(item.skuList) ? item.skuList : [];
    const skuId = Number(selectedSkuId || 0);
    if (skuId > 0) {
      const matched = list.find((sku) => Number(sku.id) === skuId);
      if (matched) return matched;
    }
    return this.getFirstAvailableSku(item);
  },

  getSkuDisplayPrice(sku, fallbackPrice) {
    if (sku && sku.skuPrice !== undefined && sku.skuPrice !== null) {
      return Number(sku.skuPrice || 0).toFixed(2);
    }
    return Number(fallbackPrice || 0).toFixed(2);
  },

  noop() {},

  getFlashPrice(item = {}) {
    const fp = Number(item.flashPrice || item.flash_price || 0);
    if (fp > 0) return fp.toFixed(2);
    return this.getSkuDisplayPrice(null, item.price);
  },

  getFlashSoldPercent(item = {}) {
    const stock = this.parseNumberField(item.stock, 0);
    const flashStock = this.parseNumberField(item.flashStock || item.flash_stock, 0);
    if (stock <= 0 || flashStock <= 0) return 0;
    const sold = Math.max(0, flashStock - stock);
    const p = Math.round((sold * 100) / flashStock);
    return Math.max(0, Math.min(100, p));
  },

  calcFlashDisplayPercent(item = {}, currentStock = 0, initialFlashStock = 0) {
    const startTs = this.parseTimeToTimestamp(item.flashStartTime || item.flash_start_time || 0);
    const endTs = this.parseTimeToTimestamp(item.flashEndTime || item.flash_end_time || 0);
    if (!(startTs > 0) || !(endTs > startTs)) {
      return 18;
    }
    const nowBucket = this.getFlashTimeBucket();
    const elapsed = Math.max(0, Math.min(nowBucket - startTs, endTs - startTs));
    const duration = endTs - startTs;
    const timeRatio = duration > 0 ? elapsed / duration : 0;
    const stagedPercent = Math.round(18 + (timeRatio * 68));
    return Math.max(18, Math.min(92, stagedPercent));
  },

  buildFlashSpecText(item = {}) {
    const standardSku = this.getFirstAvailableSku(item);
    if (!standardSku) {
      return '500g标准装';
    }
    const skuName = `${standardSku.skuName || ''}`.trim();
    const weight = Number(standardSku.skuWeightG || 0);
    if (weight > 0 && skuName) {
      return `${weight}g${skuName.includes('标准') ? skuName : skuName}`;
    }
    if (weight > 0) return `${weight}g标准装`;
    if (skuName) return skuName;
    return '500g标准装';
  },

  parseNumberField(value, fallback = 0) {
    const parsed = Number(value);
    return Number.isFinite(parsed) ? parsed : fallback;
  },

  getFlashTimeBucket() {
    const minuteMs = 60 * 1000;
    return Math.floor(Date.now() / minuteMs) * minuteMs;
  },

  parseTimeToTimestamp(timeValue) {
    if (!timeValue) return 0;
    if (typeof timeValue === 'number') return timeValue;
    const raw = String(timeValue).trim();
    if (!raw) return 0;
    const normalized = raw.includes('T')
      ? raw
      : raw.replace(' ', 'T');
    const ts = new Date(normalized).getTime();
    if (!Number.isNaN(ts)) return ts;
    const fallbackTs = new Date(raw.replace(/-/g, '/')).getTime();
    if (!Number.isNaN(fallbackTs)) return fallbackTs;
    const localTs = new Date(raw.replace(/-/g, '/').replace('T', ' ')).getTime();
    if (!Number.isNaN(localTs)) return localTs;
    return 0;
  },

  startFlashCountdown() {
    this.clearFlashCountdown();
    this.updateFlashCountdown();
    this.flashTimer = setInterval(() => this.updateFlashCountdown(), 1000);
  },

  clearFlashCountdown() {
    if (this.flashTimer) {
      clearInterval(this.flashTimer);
      this.flashTimer = null;
    }
  },

  updateFlashCountdown() {
    if (!this.pageActive) return;
    const remain = this.data.flashEndTimestamp - Date.now();
    if (remain <= 0) {
      this.clearFlashCountdown();
      return;
    }
    const hour = Math.floor(remain / (1000 * 60 * 60));
    const minute = Math.floor((remain % (1000 * 60 * 60)) / (1000 * 60));
    const second = Math.floor((remain % (1000 * 60)) / 1000);
    const list = (this.data.list || []).map((item) => ({
      ...item,
      flashRemainText: this.formatFlashRemainText(item.flashEndTimestamp),
      flashPercent: this.calcFlashDisplayPercent(item, item.stock, item.flashStock || item.flash_stock || 0)
    }));
    this.setData({ list });
  },

  pad2(num) { return num < 10 ? `0${num}` : `${num}`; },

  formatFlashRemainText(timestamp) {
    const ts = Number(timestamp || 0);
    if (!(ts > 0)) return '';
    const remain = ts - Date.now();
    if (remain <= 0) return '即将结束';
    const hour = Math.floor(remain / (1000 * 60 * 60));
    const minute = Math.floor((remain % (1000 * 60 * 60)) / (1000 * 60));
    const second = Math.floor((remain % (1000 * 60)) / 1000);
    return `还剩 ${this.pad2(hour)}:${this.pad2(minute)}:${this.pad2(second)}`;
  },

  onUnload() {
    this.pageActive = false;
    this.clearFlashCountdown();
  },

  onShow() {
    this.pageActive = true;
  },

  onHide() {
    this.pageActive = false;
    this.clearFlashCountdown();
  },

  formatSceneHint(item) {
    const scene = this.data.scene;
    if (scene === '时令') return item.origin ? `产地：${this.extractProvinceText(item.origin) || item.origin}` : '现在买更适合尝鲜';
    return item.unit ? `规格：${item.unit}` : '';
  },

  extractProvinceText(origin = '') {
    const text = `${origin}`.trim();
    if (!text) return '';
    const provinceMap = [
      ['北京市', ['北京']],
      ['天津市', ['天津']],
      ['上海市', ['上海']],
      ['重庆市', ['重庆']],
      ['河北省', ['河北']],
      ['山西省', ['山西']],
      ['辽宁省', ['辽宁']],
      ['吉林省', ['吉林']],
      ['黑龙江省', ['黑龙江']],
      ['江苏省', ['江苏']],
      ['浙江省', ['浙江']],
      ['安徽省', ['安徽']],
      ['福建省', ['福建']],
      ['江西省', ['江西']],
      ['山东省', ['山东']],
      ['河南省', ['河南']],
      ['湖北省', ['湖北']],
      ['湖南省', ['湖南']],
      ['广东省', ['广东']],
      ['海南省', ['海南']],
      ['四川省', ['四川']],
      ['贵州省', ['贵州']],
      ['云南省', ['云南']],
      ['陕西省', ['陕西']],
      ['甘肃省', ['甘肃']],
      ['青海省', ['青海']],
      ['台湾省', ['台湾']],
      ['内蒙古自治区', ['内蒙古']],
      ['广西壮族自治区', ['广西']],
      ['西藏自治区', ['西藏']],
      ['宁夏回族自治区', ['宁夏']],
      ['新疆维吾尔自治区', ['新疆']],
      ['香港特别行政区', ['香港']],
      ['澳门特别行政区', ['澳门']]
    ];
    for (let i = 0; i < provinceMap.length; i += 1) {
      const [fullName, aliases] = provinceMap[i];
      if ([fullName, ...aliases].some((alias) => text.startsWith(alias))) {
        return fullName;
      }
    }
    const firstPart = text.split(/[，,、\s]+/).find((item) => item && item.trim()) || text;
    const provinceMatch = firstPart.match(/(内蒙古|黑龙江|宁夏|广西|西藏|新疆|北京市|天津市|上海市|重庆市|香港|澳门|台湾|[^省市自治区特别行政区]+省|[^省市自治区特别行政区]+市|[^省市自治区特别行政区]+自治区)/);
    if (provinceMatch && provinceMatch[0]) {
      return provinceMatch[0];
    }
    return firstPart;
  },

  resolveCouponThresholdHintByPrice(item = {}) {
    const price = Number(item.price || 0);
    if (!this.data.scene) return '';
    if (price >= 99) return '满99可用大额券';
    if (price >= 50) return '满50可用满减券';
    if (price >= 39) return '满足新人券门槛';
    return '建议凑单更划算';
  }
});
