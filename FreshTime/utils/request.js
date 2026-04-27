const { BASE_URL, ENV_VERSION, REQUEST_LOG_ENABLED } = require('./config');

const DEFAULT_TIMEOUT = 10000;
const TOKEN_STORAGE_KEY = 'token';

const HTTP_ERROR_MESSAGE_MAP = {
  400: '请求参数有误',
  401: '登录已过期，请重新登录',
  403: '无权限访问',
  404: '接口不存在',
  408: '请求超时，请稍后重试',
  429: '请求过于频繁，请稍后再试',
  500: '服务器开小差了，请稍后重试',
  502: '网关异常，请稍后重试',
  503: '服务暂不可用，请稍后重试',
  504: '网关超时，请稍后重试'
};

function getAuthHeader() {
  try {
    const token = wx.getStorageSync(TOKEN_STORAGE_KEY);
    if (!token) return {};
    return {
      Authorization: `Bearer ${token}`
    };
  } catch (error) {
    return {};
  }
}

function shouldRetry(statusCode, retryLeft) {
  if (!retryLeft || retryLeft <= 0) {
    return false;
  }
  return statusCode >= 500;
}

function getHttpErrorMessage(statusCode) {
  return HTTP_ERROR_MESSAGE_MAP[statusCode] || `请求失败（${statusCode}）`;
}

function normalizeNetworkError(error) {
  const errMsg = (error && error.errMsg) || '';
  if (errMsg.includes('timeout')) {
    return new Error('网络超时，请稍后重试');
  }
  if (errMsg.includes('fail')) {
    return new Error('网络连接失败，请检查网络');
  }
  return new Error('网络请求失败，请稍后重试');
}

function logRequestStart(traceId, method, url, data) {
  if (!REQUEST_LOG_ENABLED) return;
  console.info(`[request:start] id=${traceId} env=${ENV_VERSION} ${method} ${url}`, data || {});
}

function logRequestEnd(traceId, method, url, duration, statusCode, businessCode) {
  if (!REQUEST_LOG_ENABLED) return;
  console.info(
    `[request:end] id=${traceId} ${method} ${url} duration=${duration}ms status=${statusCode} code=${businessCode}`
  );
}

function logRequestFail(traceId, method, url, duration, error) {
  if (!REQUEST_LOG_ENABLED) return;
  console.warn(`[request:fail] id=${traceId} ${method} ${url} duration=${duration}ms`, error);
}

/**
 * 统一网络请求方法
 * @param {Object} options - 请求配置
 * @param {String} options.url - 接口路径（支持相对路径或完整 URL）
 * @param {String} [options.method='GET'] - 请求方法
 * @param {Object} [options.data={}] - 请求参数
 * @param {Object} [options.header={}] - 请求头
 * @param {Number} [options.timeout=DEFAULT_TIMEOUT] - 超时时间
 * @param {Number} [options.retry=0] - 失败重试次数（仅 5xx/网络失败生效）
 * @returns {Promise<any>} 请求结果
 */
function request(options = {}) {
  const {
    url = '',
    method = 'GET',
    data = {},
    header = {},
    timeout = DEFAULT_TIMEOUT,
    retry = 0
  } = options;

  if (!url) {
    return Promise.reject(new Error('request url is required'));
  }

  const finalUrl = /^https?:\/\//.test(url) ? url : `${BASE_URL}${url}`;
  const traceId = `${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;

  return new Promise((resolve, reject) => {
    const sendRequest = (retryLeft) => {
      const startTime = Date.now();
      logRequestStart(traceId, method, finalUrl, data);

      wx.request({
        url: finalUrl,
        method,
        data,
        timeout,
        header: {
          'Content-Type': 'application/json',
          ...getAuthHeader(),
          ...header
        },
        success: (res) => {
          const duration = Date.now() - startTime;
          const responseData = res.data || {};
          const businessCode = typeof responseData === 'object' ? responseData.code : '-';
          logRequestEnd(traceId, method, finalUrl, duration, res.statusCode, businessCode);

          if (res.statusCode === 401) {
            const unauthorizedError = new Error(getHttpErrorMessage(401));
            unauthorizedError.code = 401;
            reject(unauthorizedError);
            return;
          }

          if (res.statusCode >= 200 && res.statusCode < 300) {
            if (
              responseData &&
              typeof responseData === 'object' &&
              Object.prototype.hasOwnProperty.call(responseData, 'code') &&
              responseData.code !== 200
            ) {
              const error = new Error(responseData.message || '业务处理失败');
              error.response = responseData;
              reject(error);
              return;
            }

            resolve(responseData);
            return;
          }

          if (shouldRetry(res.statusCode, retryLeft)) {
            sendRequest(retryLeft - 1);
            return;
          }

          reject(new Error(getHttpErrorMessage(res.statusCode)));
        },
        fail: (error) => {
          const duration = Date.now() - startTime;
          logRequestFail(traceId, method, finalUrl, duration, error);

          if (retryLeft > 0) {
            sendRequest(retryLeft - 1);
            return;
          }
          reject(normalizeNetworkError(error));
        }
      });
    };

    sendRequest(retry);
  });
}

/**
 * GET 请求快捷方法
 * @param {String} url - 接口路径
 * @param {Object} [data={}] - 查询参数
 * @param {Object} [options={}] - 额外配置
 * @returns {Promise<any>} 请求结果
 */
function get(url, data = {}, options = {}) {
  return request({
    url,
    data,
    method: 'GET',
    ...options
  });
}

/**
 * POST 请求快捷方法
 * @param {String} url - 接口路径
 * @param {Object} [data={}] - 请求体
 * @param {Object} [options={}] - 额外配置
 * @returns {Promise<any>} 请求结果
 */
function post(url, data = {}, options = {}) {
  return request({
    url,
    data,
    method: 'POST',
    ...options
  });
}

/**
 * PUT 请求快捷方法
 * @param {String} url - 接口路径
 * @param {Object} [data={}] - 请求体
 * @param {Object} [options={}] - 额外配置
 * @returns {Promise<any>} 请求结果
 */
function put(url, data = {}, options = {}) {
  return request({
    url,
    data,
    method: 'PUT',
    ...options
  });
}

/**
 * DELETE 请求快捷方法
 * @param {String} url - 接口路径
 * @param {Object} [data={}] - 请求参数
 * @param {Object} [options={}] - 额外配置
 * @returns {Promise<any>} 请求结果
 */
function del(url, data = {}, options = {}) {
  return request({
    url,
    data,
    method: 'DELETE',
    ...options
  });
}

module.exports = {
  request,
  get,
  post,
  put,
  del
};
