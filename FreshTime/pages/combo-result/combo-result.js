const { addPlanToCart, generateComboPlan, replacePlanItem } = require('../../utils/plan');
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
    addCartFailedItems: [],
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
    const maxReasonLength = 26;
    const reasonShort = reason.length > maxReasonLength ? `${reason.slice(0, maxReasonLength)}...` : reason;
    const reasonTags = Array.isArray(item && item.reasonTags) ? item.reasonTags : [];
    const reasonTagShort = reasonTags.slice(0, 2).join(' / ');
    return {
      ...item,
      _itemKey: `${item && item.goodsId ? item.goodsId : 'g'}-${item && item.skuId ? item.skuId : 's'}-${index}`,
      _reasonShort: reasonShort,
      _reasonLong: reason,
      _reasonTagShort: reasonTagShort,
      _reasonTagMore: reasonTags.length > 2 ? reasonTags.length - 2 : 0
    };
  },

  buildSummaryTitle(combo = {}, payload = {}) {
    const sceneText = `${payload.sceneText || payload.sceneType || combo.comboName || '蔬果搭配'}`.trim();
    return `${sceneText}方案已配好`;
  },

  buildSummaryText(combo = {}, payload = {}) {
    const budget = `${payload.budgetLabel || payload.budgetLevel || ''}`.trim();
    const fitScore = `${combo.fitScore || ''}`.trim();
    const prepHint = `${combo.prepHint || ''}`.trim();
    const parts = [
      fitScore ? `匹配度：${fitScore}` : '',
      budget ? `预算档位：${budget}` : '',
      prepHint || '优先保证场景完整度与可直接下单性'
    ].filter(Boolean);
    return parts.join(' · ');
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
          reason: next.reason || '已为你替换同类组合项'
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

  handleAddCartResult(result = {}) {
    const resultType = result.resultType || 'SUCCESS';
    if (resultType === 'SUCCESS') {
      this.setData({ addCartFailedItems: [] });
      wx.showToast({ title: '方案已加入购物车', icon: 'success' });
      return;
    }
    if (resultType === 'PARTIAL_SUCCESS') {
      this.setData({ addCartFailedItems: result.failedItems || [] });
      wx.showToast({ title: `部分成功：${result.successCount}/${result.totalCount}`, icon: 'none' });
      return;
    }
    this.setData({ addCartFailedItems: result.failedItems || [] });
    const firstFailed = Array.isArray(result.failedItems) && result.failedItems[0] ? result.failedItems[0].reason : '';
    wx.showToast({ title: firstFailed || '方案加购失败', icon: 'none' });
  },

  onAddPlanToCart() {
    if (this.data.submitting) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/combo-result/combo-result' }).catch(() => {});
      return;
    }
    const combo = this.data.combo;
    if (!combo || !combo.comboId) {
      wx.showToast({ title: '暂无可加购方案', icon: 'none' });
      return;
    }
    this.setData({ submitting: true });
    addPlanToCart({
      planType: 'combo',
      planId: combo.comboId,
      items: (combo.items || []).map((item) => ({
        goodsId: Number(item.goodsId || 0),
        skuId: Number(item.skuId || 0),
        quantity: Number(item.quantity || 1),
        sourceType: 'COMBO',
        sourcePlanId: Number(combo.comboId || 0),
        sourceScene: '蔬果搭配'
      }))
    })
      .then((result) => {
        trackEvent('plan_add_cart_success', {
          planType: 'combo',
          planId: `${combo.comboId}`,
          resultType: result.resultType,
          itemCount: Array.isArray(combo.items) ? combo.items.length : 0,
          fallbackUsed: false,
          errorCode: ''
        });
        this.handleAddCartResult(result);
        if (app && app.refreshCartBadgeFromServer) app.refreshCartBadgeFromServer();
      })
      .catch((error) => {
        this.setData({ addCartFailedItems: [] });
        showRequestError(error, '方案加购失败');
        return null;
      })
      .finally(() => this.setData({ submitting: false }));
  }
});
