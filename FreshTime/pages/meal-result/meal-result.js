const { generateMealPlan, replacePlanItem } = require('../../utils/plan');
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
        showRequestError(error, '小份优选方案生成失败');
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
    const maxReasonLength = 18;
    const reasonShort = reason.length > maxReasonLength ? `${reason.slice(0, maxReasonLength)}...` : reason;
    const reasonTags = Array.isArray(item && item.reasonTags) ? item.reasonTags : [];
    const reasonTagShort = reasonTags.slice(0, 2).map((tag) => this.formatTagText(tag)).join(' / ');
    return {
      ...item,
      roleText: this.formatRoleText(item && item.role),
      priceText: this.formatPrice(item && item.price),
      _itemKey: `${item && item.goodsId ? item.goodsId : 'g'}-${item && item.skuId ? item.skuId : 's'}-${index}`,
      _reasonShort: reasonShort,
      _reasonTagShort: reasonTagShort,
      _reasonTagMore: reasonTags.length > 2 ? reasonTags.length - 2 : 0
    };
  },

  buildSummaryTitle(plan = {}, payload = {}) {
    const sceneText = `${payload.sceneText || payload.sceneType || '小份优选'}`.trim();
    return sceneText ? `${sceneText}已配好` : '小份优选已配好';
  },

  buildSummaryText(plan = {}, payload = {}) {
    const budget = `${payload.budgetLabel || payload.budgetLevel || ''}`.trim();
    const servings = Number(plan.serving || payload.serving || 1);
    const parts = [
      `${servings} 人份量`,
      '优先蔬菜搭水果',
      budget ? budget : ''
    ].filter(Boolean);
    return parts.join(' · ');
  },

  formatRoleText(role) {
    if (role === 'main') return '主食材';
    if (role === 'side') return '搭配食材';
    if (role === 'fruit') return '水果';
    if (role === 'base') return '主搭配';
    if (role === 'veg') return '蔬菜';
    return '推荐项';
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
          reason: next.reason || '已为你换成更适合的一项'
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

  onBuyNow() {
    if (this.data.submitting) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/meal-result/meal-result' }).catch(() => {});
      return;
    }
    const plan = this.data.plan;
    if (!plan || !plan.planId) {
      wx.showToast({ title: '暂无可购买方案', icon: 'none' });
      return;
    }
    this.setData({ submitting: true });
    const checkoutItems = (plan.items || []).map((item) => ({
        goodsId: Number(item.goodsId || 0),
        id: Number(item.goodsId || 0),
        skuId: Number(item.skuId || 0),
        name: item.name || '',
        image: item.image || '',
        price: Number(item.price || 0),
        skuName: item.skuName || '',
        skuWeightG: Number(item.gramsEstimate || item.skuWeightG || 0),
        quantity: Number(item.quantity || 1),
        sourceType: 'MEAL',
        sourcePlanId: Number(plan.planId || 0),
        sourceScene: '小份优选'
      }));
    wx.setStorageSync('checkoutItems', checkoutItems);
    wx.setStorageSync('checkoutMeta', {
      source: 'plan',
      planType: 'meal',
      planId: Number(plan.planId || 0),
      packPrice: Number((plan.priceSummary && plan.priceSummary.totalPrice) || 0),
      packOriginalTotal: Number((plan.priceSummary && plan.priceSummary.originalTotalPrice) || 0),
      packDiscount: Number((plan.priceSummary && plan.priceSummary.packDiscount) || 0),
      tipText: '组合优惠仅限当前方案即时下单，加入普通购物车后不保留该优惠'
    });
    trackEvent('plan_buy_now', {
      planType: 'meal',
      planId: `${plan.planId}`,
      itemCount: Array.isArray(plan.items) ? plan.items.length : 0
    });
    wx.navigateTo({
      url: '/pages/checkout/checkout',
      complete: () => this.setData({ submitting: false })
    });
  }
});
