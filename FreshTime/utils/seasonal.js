const { get, post } = require('./request');

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

function normalizeList(rawList) {
  const list = Array.isArray(rawList) ? rawList : [];
  return list.map((item) => ({
    id: toNumber(item.id || 0, 0),
    name: item.name || '',
    mainImage: item.mainImage || '',
    price: toNumber(item.price, 0),
    originalPrice: toNumber(item.originalPrice, 0),
    stock: toNumber(item.stock, 0),
    unit: item.unit || '件',
    defaultSkuId: toNumber(item.defaultSkuId || 0, 0),
    skuId: toNumber(item.skuId || 0, 0),
    skuName: item.skuName || '',
    skuWeightG: toNumber(item.skuWeightG, 0),
    salesVolume: toNumber(item.salesVolume, 0),
    origin: item.origin || '',
    keywords: item.keywords || '',
    totalScore: toNumber(item.totalScore, 0),
    seasonScore: toNumber(item.seasonScore, 0),
    freshnessScore: toNumber(item.freshnessScore, 0),
    salesScore: toNumber(item.salesScore, 0),
    marginScore: toNumber(item.marginScore, 0),
    stockScore: toNumber(item.stockScore, 0),
    seasonStage: item.seasonStage || '',
    seasonStageText: item.seasonStageText || '',
    seasonFreshnessHint: item.seasonFreshnessHint || '',
    seasonMarketingText: item.seasonMarketingText || '',
    seasonMonthRangeText: item.seasonMonthRangeText || '',
    recommendReason: item.recommendReason || '',
    tags: Array.isArray(item.tags) ? item.tags : []
  }));
}

function normalizeRegionOptions(rawList) {
  const list = Array.isArray(rawList) ? rawList : [];
  const normalized = list
    .map((item) => ({
      key: `${item && item.key ? item.key : ''}`.trim(),
      text: `${item && item.text ? item.text : ''}`.trim()
    }))
    .filter((item) => item.key && item.text);
  const hasAll = normalized.some((item) => item.key === 'all');
  if (!hasAll) {
    normalized.unshift({ key: 'all', text: '全部产地' });
  }
  return normalized;
}

function getSeasonalList(params = {}) {
  return get('/seasonal/list', params, { retry: 0 }).then((res) => {
    const { code, message, data } = unwrapApiResponse(res);
    if (code !== 200) {
      const err = new Error(message || '当季精选加载失败');
      err.code = code;
      throw err;
    }
    return {
      season: data.season || '',
      seasonText: data.seasonText || '',
      seasonStage: data.seasonStage || '',
      seasonStageText: data.seasonStageText || '',
      region: data.region || 'all',
      regionOptions: normalizeRegionOptions(data.regionOptions),
      budgetLevel: data.budgetLevel || 'all',
      produceType: data.produceType || 'all',
      sortBy: data.sortBy || 'score',
      strictTag: data.strictTag !== false,
      headline: data.headline || '当季精选',
      subHeadline: data.subHeadline || '',
      fallbackUsed: data.fallbackUsed === true,
      fallbackMessage: data.fallbackMessage || '',
      refreshTime: toNumber(data.refreshTime, 0),
      items: normalizeList(data.items)
    };
  });
}

function refreshSeasonal(params = {}) {
  return post('/seasonal/refresh', params, { retry: 0 }).then((res) => {
    const { code, message, data } = unwrapApiResponse(res);
    if (code !== 200) {
      const err = new Error(message || '当季精选刷新失败');
      err.code = code;
      throw err;
    }
    return {
      season: data.season || '',
      seasonText: data.seasonText || '',
      seasonStage: data.seasonStage || '',
      seasonStageText: data.seasonStageText || '',
      region: data.region || 'all',
      regionOptions: normalizeRegionOptions(data.regionOptions),
      budgetLevel: data.budgetLevel || 'all',
      produceType: data.produceType || 'all',
      sortBy: data.sortBy || 'score',
      strictTag: data.strictTag !== false,
      headline: data.headline || '当季精选',
      subHeadline: data.subHeadline || '',
      fallbackUsed: data.fallbackUsed === true,
      fallbackMessage: data.fallbackMessage || '',
      refreshTime: toNumber(data.refreshTime, 0),
      items: normalizeList(data.items)
    };
  });
}

function getSeasonalConfig() {
  return get('/seasonal/config', {}, { retry: 0 }).then((res) => {
    const { code, message, data } = unwrapApiResponse(res);
    if (code !== 200) {
      const err = new Error(message || '当季配置加载失败');
      err.code = code;
      throw err;
    }
    return data || {};
  });
}

module.exports = {
  getSeasonalList,
  refreshSeasonal,
  getSeasonalConfig
};
