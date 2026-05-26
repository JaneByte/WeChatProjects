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
    excludedGoodsIds: [],
    planSummaryTitle: '',
    planSummaryText: ''
  },

  onLoad() {
    const payload = wx.getStorageSync('mealPlanPayload') || {};
    this.setData({ payload, excludedGoodsIds: [] });
    this.loadPlan(payload);
  },

  loadPlan(payload) {
    this.setData({ loading: true });
    return generateMealPlan(payload)
      .then((plan) => {
        this.setData({
          plan: this.decoratePlan(plan || null),
          planSummaryTitle: this.buildSummaryTitle(plan || {}, payload || {}),
          planSummaryText: this.buildSummaryText(plan || {}, payload || {})
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
        showRequestError(error, '这次没配出理想方案，已尽量为你放宽条件');
      })
      .finally(() => this.setData({ loading: false }));
  },

  onPullDownRefresh() {
    const payload = this.data.payload || wx.getStorageSync('mealPlanPayload') || {};
    this.loadPlan(payload).finally(() => wx.stopPullDownRefresh());
  },

  onRegenerate() {
    trackEvent('plan_regenerate', { planType: 'meal' });
    const currentPlan = this.data.plan || {};
    const previousPlanGoodsIds = Array.isArray(currentPlan.items)
      ? currentPlan.items.map((item) => Number(item && item.goodsId ? item.goodsId : 0)).filter((id) => id > 0)
      : [];
    const excludedGoodsIds = Array.isArray(this.data.excludedGoodsIds) ? this.data.excludedGoodsIds.slice() : [];
    (currentPlan.items || []).forEach((item) => {
      const goodsId = Number(item && item.goodsId ? item.goodsId : 0);
      if (goodsId > 0 && excludedGoodsIds.indexOf(goodsId) < 0) {
        excludedGoodsIds.push(goodsId);
      }
    });
    const nextPayload = {
      ...(this.data.payload || {}),
      shuffleSeed: Date.now(),
      dislikeGoodsIds: excludedGoodsIds,
      previousPlanGoodsIds
    };
    this.setData({ payload: nextPayload, excludedGoodsIds });
    this.loadPlan(nextPayload);
  },

  replaceItemLocal(itemIndex, replacement, priceSummary) {
    const list = Array.isArray(this.data.plan && this.data.plan.items) ? this.data.plan.items.slice() : [];
    if (itemIndex < 0 || itemIndex >= list.length) return;
    list[itemIndex] = this.decorateItem({ ...list[itemIndex], ...replacement }, itemIndex);
    const nextPriceSummary = this.buildPlanPriceSummary(list, priceSummary);
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
    const sceneText = this.formatSceneText(payload.sceneText || payload.sceneType || '');
    const goalText = this.formatGoalText(payload.dietGoal || '');
    if (sceneText && goalText) return `${sceneText}·${goalText}`;
    if (sceneText) return `${sceneText}已配好`;
    if (goalText) return `${goalText}方案已配好`;
    return '小份优选已配好';
  },

  buildSummaryText(plan = {}, payload = {}) {
    const budget = this.formatBudgetText(payload.budgetLabel || payload.budgetLevel || '');
    const servings = Number(plan.serving || payload.serving || 1);
    const goalKey = `${payload.dietGoal || ''}`.trim();
    const goalSummaryMap = {
      high_fiber: '更偏高纤和饱腹感，适合想吃得稳妥一点',
      light: '更偏清爽轻负担，整体口感会更轻一点',
      balanced: '更偏日常均衡，兼顾蔬菜、水果和顺手搭配'
    };
    const parts = [
      `${servings} 人份量`,
      goalSummaryMap[goalKey] || '已经帮你搭配好',
      budget ? budget : ''
    ].filter(Boolean);
    return parts.join(' · ');
  },

  formatSceneText(scene) {
    const text = `${scene || ''}`.trim();
    if (!text) return '';
    const sceneMap = {
      lunch: '午餐小份优选',
      dinner: '晚餐小份优选',
      breakfast: '早餐小份优选',
      light_meal: '轻食小份优选',
      small_portion: '小份优选'
    };
    return sceneMap[text] || text;
  },

  formatBudgetText(budget) {
    const text = `${budget || ''}`.trim();
    if (!text) return '';
    const budgetMap = {
      economy: '经济档',
      standard: '标准档',
      plus: '升级档'
    };
    return budgetMap[text] || text;
  },

  formatGoalText(goal) {
    const text = `${goal || ''}`.trim();
    if (!text) return '';
    const goalMap = {
      high_fiber: '高纤饱腹',
      light: '清爽轻负担',
      balanced: '均衡日常'
    };
    return goalMap[text] || text;
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

  buildPlanPriceSummary(items = [], sourcePriceSummary = {}) {
    const currentSummary = (this.data.plan && this.data.plan.priceSummary) || {};
    const originalTotalPrice = items.reduce((sum, item) => {
      const price = Number(item && item.price ? item.price : 0);
      const quantity = Number(item && item.quantity ? item.quantity : 1);
      return sum + (price * quantity);
    }, 0);
    const packDiscount = Number(
      sourcePriceSummary && sourcePriceSummary.packDiscount !== undefined
        ? sourcePriceSummary.packDiscount
        : currentSummary.packDiscount || 0
    );
    const totalPrice = Math.max(0, originalTotalPrice - packDiscount);
    return {
      ...currentSummary,
      ...sourcePriceSummary,
      originalTotalPrice: originalTotalPrice.toFixed(2),
      packDiscount: packDiscount.toFixed(2),
      totalPrice: totalPrice.toFixed(2),
      savedAmount: packDiscount.toFixed(2)
    };
  },

  onReplaceItem(e) {
    if (this.data.replacing) return;
    const rawIndex = e && e.currentTarget && e.currentTarget.dataset
      ? e.currentTarget.dataset.index
      : undefined;
    const itemIndex = rawIndex === undefined || rawIndex === null || rawIndex === ''
      ? -1
      : Number(rawIndex);
    const sourceItem = (this.data.plan && this.data.plan.items && this.data.plan.items[itemIndex]) || null;
    const plan = this.data.plan || {};
    if (!sourceItem || !plan.planId) return;
    this.setData({ replacing: true });
    replacePlanItem({
      planType: 'meal',
      planId: plan.planId,
      originGoodsId: sourceItem.goodsId,
      originSkuId: sourceItem.skuId,
      originRole: sourceItem.role || '',
      itemIndex,
      currentGoodsIds: (() => {
        const ids = Array.isArray(plan.items) ? plan.items.map((item) => Number(item.goodsId || 0)).filter((id) => id > 0) : [];
        const excluded = Array.isArray(this.data.excludedGoodsIds) ? this.data.excludedGoodsIds : [];
        excluded.forEach((id) => {
          const normalized = Number(id || 0);
          if (normalized > 0 && ids.indexOf(normalized) < 0) ids.push(normalized);
        });
        return ids;
      })()
    })
      .then((result) => {
        const next = result.item || {};
        const excludedGoodsIds = Array.isArray(this.data.excludedGoodsIds) ? this.data.excludedGoodsIds.slice() : [];
        const originGoodsId = Number(sourceItem.goodsId || 0);
        if (originGoodsId > 0 && excludedGoodsIds.indexOf(originGoodsId) < 0) {
          excludedGoodsIds.push(originGoodsId);
        }
        this.replaceItemLocal(itemIndex, {
          goodsId: Number(next.goodsId || sourceItem.goodsId || 0),
          skuId: Number(next.skuId || sourceItem.skuId || 0),
          name: next.name || sourceItem.name,
          price: Number(next.price || sourceItem.price || 0),
          reason: next.reason || '已为你换成更适合的一项'
        }, result.priceSummary);
        this.setData({ excludedGoodsIds });
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
