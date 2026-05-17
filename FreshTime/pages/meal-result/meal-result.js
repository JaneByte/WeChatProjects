const { addPlanToCart, generateMealPlan, replacePlanItem } = require('../../utils/plan');
const { trackEvent } = require('../../utils/track');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

Page({
  data: {
    loading: true,
    submitting: false,
    replacing: false,
    plan: null,
    payload: null,
    planSummaryTitle: '',
    planSummaryText: '',
    replaceDeltaText: '',
    addCartFailedItems: [],
    reasonExpandedMap: {}
  },

  onLoad() {
    const payload = wx.getStorageSync('mealPlanPayload') || {};
    this.setData({ payload });
    this.loadPlan(payload);
  },

  loadPlan(payload) {
    this.setData({ loading: true });
    generateMealPlan(payload)
      .then((plan) => {
        this.setData({
          plan: this.decoratePlan(plan || null),
          planSummaryTitle: this.buildSummaryTitle(plan || {}, payload || {}),
          planSummaryText: this.buildSummaryText(plan || {}, payload || {}),
          reasonExpandedMap: {}
        });
        if (plan && plan.planId) {
          trackEvent('plan_generate_success', {
            planType: 'meal',
            planId: `${plan.planId}`,
            itemCount: Array.isArray(plan.items) ? plan.items.length : 0,
            fallbackUsed: !!(plan._meta && plan._meta.fallbackUsed),
            errorCode: (plan._meta && plan._meta.errorCode) || ''
          });
        }
      })
      .catch((error) => {
        this.setData({ plan: null });
        showRequestError(error, '一人食方案生成失败');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onRegenerate() {
    trackEvent('plan_regenerate', { planType: 'meal' });
    const nextPayload = {
      ...(this.data.payload || {}),
      shuffleSeed: Date.now()
    };
    this.setData({ payload: nextPayload });
    this.loadPlan(nextPayload);
  },

  replaceItemLocal(itemIndex, replacement, priceSummary) {
    const list = Array.isArray(this.data.plan && this.data.plan.items) ? this.data.plan.items.slice() : [];
    if (itemIndex < 0 || itemIndex >= list.length) return;
    list[itemIndex] = this.decorateItem({ ...list[itemIndex], ...replacement }, itemIndex);
    const nextPriceSummary = priceSummary
      ? {
          ...this.data.plan.priceSummary,
          ...priceSummary
        }
      : this.data.plan.priceSummary;
    this.setData({
      'plan.items': list,
      'plan.priceSummary': nextPriceSummary
    });
  },

  decoratePlan(plan) {
    if (!plan || !Array.isArray(plan.items)) return plan;
    return {
      ...plan,
      items: plan.items.map((item, index) => this.decorateItem(item, index))
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

  buildSummaryTitle(plan = {}, payload = {}) {
    const sceneText = `${payload.sceneText || payload.sceneType || '一人食'}`.trim();
    return sceneText ? `${sceneText}推荐已配好` : '一人食推荐已配好';
  },

  buildSummaryText(plan = {}, payload = {}) {
    const budget = `${payload.budgetLabel || payload.budgetLevel || ''}`.trim();
    const servings = Number(plan.serving || payload.serving || 1);
    const wasteLevel = `${plan.wasteEstimate && plan.wasteEstimate.level ? plan.wasteEstimate.level : ''}`.trim();
    const parts = [
      `按 ${servings} 人份量控制`,
      budget ? `预算档位：${budget}` : '',
      wasteLevel ? `浪费预估：${wasteLevel}` : '优先减少囤多吃不完'
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
    const sourceItem = (this.data.plan && this.data.plan.items && this.data.plan.items[itemIndex]) || null;
    const plan = this.data.plan || {};
    if (!sourceItem || !plan.planId) return;
    this.setData({ replacing: true });
    replacePlanItem({
      planType: 'meal',
      planId: plan.planId,
      originGoodsId: sourceItem.goodsId,
      originSkuId: sourceItem.skuId
    })
      .then((result) => {
        const beforeTotal = Number((plan.priceSummary && plan.priceSummary.totalPrice) || 0);
        const nextTotal = Number((result.priceSummary && result.priceSummary.totalPrice) || beforeTotal);
        const next = result.item || {};
        this.replaceItemLocal(itemIndex, {
          goodsId: Number(next.goodsId || sourceItem.goodsId || 0),
          skuId: Number(next.skuId || sourceItem.skuId || 0),
          name: next.name || sourceItem.name,
          price: Number(next.price || sourceItem.price || 0),
          reason: next.reason || '已为你替换同类食材'
        }, result.priceSummary);
        this.setData({
          replaceDeltaText: `替换后总价：¥${beforeTotal.toFixed(2)} -> ¥${nextTotal.toFixed(2)}`
        });
        wx.showToast({ title: '已替换', icon: 'success' });
        trackEvent('plan_item_replace', {
          planType: 'meal',
          planId: `${plan.planId}`,
          role: `${sourceItem.role || ''}`,
          fallbackUsed: !!(result._meta && result._meta.fallbackUsed),
          errorCode: (result._meta && result._meta.errorCode) || ''
        });
      })
      .catch((error) => {
        showRequestError(error, '替换失败，请稍后重试');
        trackEvent('plan_item_replace', {
          planType: 'meal',
          planId: `${plan.planId}`,
          role: `${sourceItem.role || ''}`,
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
      app.requireLogin({ redirect: '/pages/meal-result/meal-result' }).catch(() => {});
      return;
    }
    const plan = this.data.plan;
    if (!plan || !plan.planId) {
      wx.showToast({ title: '暂无可加购方案', icon: 'none' });
      return;
    }
    this.setData({ submitting: true });
    addPlanToCart({
      planType: 'meal',
      planId: plan.planId,
      items: (plan.items || []).map((item) => ({
        goodsId: Number(item.goodsId || 0),
        skuId: Number(item.skuId || 0),
        quantity: Number(item.quantity || 1),
        sourceType: 'MEAL',
        sourcePlanId: Number(plan.planId || 0),
        sourceScene: '一人食'
      }))
    })
      .then((result) => {
        trackEvent('plan_add_cart_success', {
          planType: 'meal',
          planId: `${plan.planId}`,
          resultType: result.resultType,
          itemCount: Array.isArray(plan.items) ? plan.items.length : 0,
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
