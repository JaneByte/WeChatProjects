const { post } = require('./request');

function normalizeList(list) {
  return Array.isArray(list) ? list : [];
}

function toNumber(value, fallback = 0) {
  const n = Number(value);
  return Number.isFinite(n) ? n : fallback;
}

function unwrapApiResponse(res) {
  const payload = (res && typeof res === 'object') ? res : {};
  const code = toNumber(payload.code, 200);
  const message = payload.message || '';
  const data = Object.prototype.hasOwnProperty.call(payload, 'data') ? payload.data : payload;
  return { code, message, data };
}

function createContractError(message, responseMeta = {}) {
  const error = new Error(message || '接口返回结构异常');
  error.code = 'PLAN_CONTRACT_ERROR';
  error.meta = responseMeta;
  return error;
}

function normalizePriceSummary(source = {}, fallbackPrice = 0) {
  return {
    totalPrice: toNumber(source.totalPrice, fallbackPrice),
    originalTotalPrice: toNumber(source.originalTotalPrice, fallbackPrice),
    packDiscount: toNumber(source.packDiscount, 0),
    savedAmount: toNumber(source.savedAmount, 0),
    couponHint: source.couponHint || ''
  };
}

function normalizePlanItem(item = {}) {
  return {
    goodsId: toNumber(item.goodsId || item.id || 0, 0),
    skuId: toNumber(item.skuId || 0, 0),
    name: item.name || '',
    image: item.image || item.mainImage || '',
    quantity: toNumber(item.quantity, 1),
    role: item.role || item.group || '',
    reason: item.reason || '',
    price: toNumber(item.price, 0),
    gramsEstimate: toNumber(item.gramsEstimate, 0),
    skuName: item.skuName || '',
    reasonTags: Array.isArray(item.reasonTags) ? item.reasonTags : []
  };
}

function normalizeMealPlan(raw = {}, fallbackType = 'meal') {
  const items = normalizeList(raw.items).map((item) => normalizePlanItem(item));
  const totalPriceFromItems = items.reduce((sum, item) => sum + toNumber(item.price, 0) * toNumber(item.quantity, 0), 0);
  return {
    planType: raw.planType || fallbackType,
    planId: toNumber(raw.planId || raw.id || 0, 0),
    planName: raw.planName || raw.name || '推荐方案',
    serving: toNumber(raw.serving, 1),
    items,
    nutritionSummary: raw.nutritionSummary || {},
    wasteEstimate: raw.wasteEstimate || {},
    priceSummary: normalizePriceSummary(raw.priceSummary || {}, totalPriceFromItems),
    replaceOptions: raw.replaceOptions || {}
  };
}

function normalizeComboPlan(raw = {}) {
  const items = normalizeList(raw.items).map((item) => normalizePlanItem(item));
  const totalPriceFromItems = items.reduce((sum, item) => sum + toNumber(item.price, 0) * toNumber(item.quantity, 0), 0);
  return {
    comboId: toNumber(raw.comboId || raw.id || 0, 0),
    comboName: raw.comboName || raw.name || '推荐搭配',
    items,
    prepHint: raw.prepHint || '',
    priceSummary: normalizePriceSummary(raw.priceSummary || {}, totalPriceFromItems),
    replaceOptions: raw.replaceOptions || {}
  };
}

function normalizeReplaceResult(raw = {}) {
  const item = raw.item ? normalizePlanItem(raw.item) : null;
  const priceSummary = raw.priceSummary ? normalizePriceSummary(raw.priceSummary, 0) : null;
  return {
    item,
    priceSummary,
    message: raw.message || ''
  };
}

function normalizeAddCartResult(raw = {}) {
  const failedItems = normalizeList(raw.failedItems).map((item) => ({
    goodsId: toNumber(item.goodsId || 0, 0),
    skuId: toNumber(item.skuId || 0, 0),
    quantity: toNumber(item.quantity || 0, 0),
    reason: item.reason || '加入失败'
  }));
  const successCount = toNumber(raw.successCount, 0);
  const failedCount = toNumber(raw.failedCount, failedItems.length);
  const totalCount = toNumber(raw.totalCount, successCount + failedCount);
  const resultType = raw.resultType || (failedCount > 0 ? (successCount > 0 ? 'PARTIAL_SUCCESS' : 'FAILED') : 'SUCCESS');
  return {
    resultType,
    successCount,
    failedCount,
    totalCount,
    failedItems,
    message: raw.message || ''
  };
}

function generateMealPlan(payload = {}) {
  return post('/meal-plan/generate', payload, { retry: 0 })
    .then((res) => {
      const { code, message, data } = unwrapApiResponse(res);
      if (code !== 200) {
      const err = new Error(message || '小份优选方案生成失败');
        err.code = code;
        throw err;
      }
      const normalized = normalizeMealPlan(data, 'meal');
      if (!normalized.planId || normalized.items.length === 0) {
      throw createContractError('小份优选方案字段缺失', { code, message });
      }
      return {
        ...normalized,
        _meta: {
          fallbackUsed: false,
          errorCode: ''
        }
      };
    });
}

function generateComboPlan(payload = {}) {
  return post('/combo-plan/generate', payload, { retry: 0 })
    .then((res) => {
      const { code, message, data } = unwrapApiResponse(res);
      if (code !== 200) {
        const err = new Error(message || '搭配方案生成失败');
        err.code = code;
        throw err;
      }
      const normalized = normalizeComboPlan(data);
      if (!normalized.comboId || normalized.items.length === 0) {
        throw createContractError('搭配方案字段缺失', { code, message });
      }
      return {
        ...normalized,
        _meta: {
          fallbackUsed: false,
          errorCode: ''
        }
      };
    });
}

function replacePlanItem(payload = {}) {
  return post('/plan/item/replace', payload, { retry: 0 })
    .then((res) => {
      const { code, message, data } = unwrapApiResponse(res);
      if (code !== 200) {
        const err = new Error(message || '替换失败');
        err.code = code;
        throw err;
      }
      return {
        ...normalizeReplaceResult(data || {}),
        _meta: {
          fallbackUsed: false,
          errorCode: ''
        }
      };
    });
}

module.exports = {
  generateMealPlan,
  generateComboPlan,
  replacePlanItem
};
