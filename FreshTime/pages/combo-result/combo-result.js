const { generateComboPlan, replacePlanItem } = require('../../utils/plan');
const { trackEvent } = require('../../utils/track');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    loading: true,
    submitting: false,
    replacing: false,
    combo: null,
    payload: null,
    comboSummaryTitle: '',
    comboSummaryText: '',
    replaceDeltaText: '',
    reasonExpandedMap: {}
  },

  onLoad() {
    const payload = wx.getStorageSync('comboPlanPayload') || {};
    this.setData({ payload });
    this.loadPlan(payload);
  },

  loadPlan(payload) {
    this.setData({ loading: true });
    generateComboPlan(payload)
      .then((combo) => {
        this.setData({
          combo: this.decorateCombo(combo || null),
          comboSummaryTitle: this.buildSummaryTitle(combo || {}, payload || {}),
          comboSummaryText: this.buildSummaryText(combo || {}, payload || {}),
          reasonExpandedMap: {}
        });
        if (combo && combo.comboId) {
          trackEvent('plan_generate_success', {
            planType: 'combo',
            planId: `${combo.comboId}`,
            itemCount: Array.isArray(combo.items) ? combo.items.length : 0,
            fallbackUsed: !!(combo._meta && combo._meta.fallbackUsed),
            errorCode: (combo._meta && combo._meta.errorCode) || ''
          });
        }
      })
      .catch((error) => {
        this.setData({ combo: null });
        showRequestError(error, '搭配方案生成失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onRegenerate() {
    trackEvent('plan_regenerate', { planType: 'combo' });
    const nextPayload = {
      ...(this.data.payload || {}),
      shuffleSeed: Date.now()
    };
    this.setData({ payload: nextPayload });
    this.loadPlan(nextPayload);
  },

  replaceItemLocal(itemIndex, replacement, priceSummary) {
    const list = Array.isArray(this.data.combo && this.data.combo.items) ? this.data.combo.items.slice() : [];
    if (itemIndex < 0 || itemIndex >= list.length) return;
    list[itemIndex] = this.decorateItem({ ...list[itemIndex], ...replacement }, itemIndex);
    const nextPriceSummary = priceSummary
      ? {
          ...this.data.combo.priceSummary,
          ...priceSummary
        }
      : this.data.combo.priceSummary;
    this.setData({
      'combo.items': list,
      'combo.priceSummary': nextPriceSummary
    });
  },

  decorateCombo(combo) {
    if (!combo || !Array.isArray(combo.items)) return combo;
    return {
      ...combo,
      items: combo.items.map((item, index) => this.decorateItem(item, index))
    };
  },

  decorateItem(item, index) {
    const reason = `${item && item.reason ? item.reason : ''}`.trim();
    const maxReasonLength = 18;
    const reasonShort = reason.length > maxReasonLength ? `${reason.slice(0, maxReasonLength)}...` : reason;
    const reasonTags = Array.isArray(item && item.reasonTags) ? item.reasonTags : [];
    const reasonTagShort = reasonTags.slice(0, 2).map((tag) => this.formatTagText(tag)).join(' / ');
    return {
      ...item,
      roleText: this.formatRoleText(item && (item.role || item.group)),
      priceText: this.formatPrice(item && item.price),
      _itemKey: `${item && item.goodsId ? item.goodsId : 'g'}-${item && item.skuId ? item.skuId : 's'}-${index}`,
      _reasonShort: reasonShort,
      _reasonTagShort: reasonTagShort,
      _reasonTagMore: reasonTags.length > 2 ? reasonTags.length - 2 : 0
    };
  },

  buildSummaryTitle(combo = {}, payload = {}) {
    const sceneText = `${payload.sceneText || payload.sceneType || combo.comboName || '蔬果搭配'}`.trim();
    return `${sceneText}已配好`;
  },

  buildSummaryText(combo = {}, payload = {}) {
    const budget = `${payload.budgetLabel || payload.budgetLevel || ''}`.trim();
    const parts = [
      '按场景配齐更省心',
      budget ? budget : ''
    ].filter(Boolean);
    return parts.join(' · ');
  },

  formatRoleText(role) {
    if (role === 'base') return '主食材';
    if (role === 'veg') return '蔬菜';
    if (role === 'fruit') return '水果';
    if (role === 'main') return '主食材';
    if (role === 'side') return '搭配食材';
    return '组合项';
  },

  formatTagText(tag) {
    const text = `${tag || ''}`.trim();
    if (text === '小份优先') return '份量合适';
    if (text === '维C补充') return '清爽加分';
    if (text === '均衡搭配') return '搭配均衡';
    if (text === '饱腹主菜') return '更有饱腹感';
    if (text === '搭配友好') return '适合一起买';
    if (text === '组合场景适配') return '适合当前场景';
    if (text === '库存充足') return '现货充足';
    return text;
  },

  formatPrice(price) {
    const amount = Number(price || 0);
    return `¥${amount.toFixed(2)}`;
  },

  onToggleReason(e) {
    const key = `${e.currentTarget.dataset.itemKey || ''}`;
    if (!key) return;
    const nextExpanded = !this.data.reasonExpandedMap[key];
    this.setData({
      [`reasonExpandedMap.${key}`]: nextExpanded
    });
  },

  onReplaceItem(e) {
    if (this.data.replacing) return;
    const itemIndex = Number(e.currentTarget.dataset.index || -1);
    const sourceItem = (this.data.combo && this.data.combo.items && this.data.combo.items[itemIndex]) || null;
    const combo = this.data.combo || {};
    if (!sourceItem || !combo.comboId) return;
    this.setData({ replacing: true });
    replacePlanItem({
      planType: 'combo',
      planId: combo.comboId,
      originGoodsId: sourceItem.goodsId,
      originSkuId: sourceItem.skuId
    })
      .then((result) => {
        const beforeTotal = Number((combo.priceSummary && combo.priceSummary.totalPrice) || 0);
        const nextTotal = Number((result.priceSummary && result.priceSummary.totalPrice) || beforeTotal);
        const next = result.item || {};
        this.replaceItemLocal(itemIndex, {
          goodsId: Number(next.goodsId || sourceItem.goodsId || 0),
          skuId: Number(next.skuId || sourceItem.skuId || 0),
          name: next.name || sourceItem.name,
          price: Number(next.price || sourceItem.price || 0),
          reason: next.reason || '已为你换成更适合的一项'
        }, result.priceSummary);
        this.setData({
          replaceDeltaText: `替换后总价：¥${beforeTotal.toFixed(2)} -> ¥${nextTotal.toFixed(2)}`
        });
        wx.showToast({ title: '已替换', icon: 'success' });
        trackEvent('plan_item_replace', {
          planType: 'combo',
          planId: `${combo.comboId}`,
          role: `${sourceItem.group || sourceItem.role || ''}`,
          fallbackUsed: !!(result._meta && result._meta.fallbackUsed),
          errorCode: (result._meta && result._meta.errorCode) || ''
        });
      })
      .catch((error) => {
        showRequestError(error, '替换失败，请稍后重试');
        trackEvent('plan_item_replace', {
          planType: 'combo',
          planId: `${combo.comboId}`,
          role: `${sourceItem.group || sourceItem.role || ''}`,
          fallbackUsed: false,
          errorCode: `${error && (error.code || error.message) ? (error.code || error.message) : 'replace_failed'}`
        });
      })
      .finally(() => {
        this.setData({ replacing: false });
      });
  },

  onBuyNow() {
    if (this.data.submitting) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/combo-result/combo-result' }).catch(() => {});
      return;
    }
    const combo = this.data.combo;
    if (!combo || !combo.comboId) {
      wx.showToast({ title: '暂无可购买方案', icon: 'none' });
      return;
    }
    this.setData({ submitting: true });
    const checkoutItems = (combo.items || []).map((item) => ({
        goodsId: Number(item.goodsId || 0),
        id: Number(item.goodsId || 0),
        skuId: Number(item.skuId || 0),
        name: item.name || '',
        image: item.image || '',
        price: Number(item.price || 0),
        skuName: item.skuName || '',
        skuWeightG: Number(item.gramsEstimate || item.skuWeightG || 0),
        quantity: Number(item.quantity || 1),
        sourceType: 'COMBO',
        sourcePlanId: Number(combo.comboId || 0),
        sourceScene: '蔬果搭配'
      }));
    wx.setStorageSync('checkoutItems', checkoutItems);
    wx.setStorageSync('checkoutMeta', {
      source: 'plan',
      planType: 'combo',
      planId: Number(combo.comboId || 0),
      packPrice: Number((combo.priceSummary && combo.priceSummary.totalPrice) || 0),
      packOriginalTotal: Number((combo.priceSummary && combo.priceSummary.originalTotalPrice) || 0),
      packDiscount: Number((combo.priceSummary && combo.priceSummary.packDiscount) || 0),
      tipText: '组合优惠仅限当前方案即时下单，加入普通购物车后不保留该优惠'
    });
    trackEvent('plan_buy_now', {
      planType: 'combo',
      planId: `${combo.comboId}`,
      itemCount: Array.isArray(combo.items) ? combo.items.length : 0
    });
    wx.navigateTo({
      url: '/pages/checkout/checkout',
      complete: () => this.setData({ submitting: false })
    });
  }
});
