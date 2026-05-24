const { API_BASE_URL_MAP, REQUEST_LOG_ENABLE_MAP } = require('./config/env');
const {
  BASE_URL_OVERRIDE_KEY,
  getEnvVersion,
  getBaseUrlOverride,
  setBaseUrlOverride,
  clearBaseUrlOverride
} = require('./config/runtime');

const ENV_VERSION = getEnvVersion();
const REQUEST_LOG_ENABLED = REQUEST_LOG_ENABLE_MAP[ENV_VERSION] === true;

function getBaseUrl() {
  return getBaseUrlOverride() || API_BASE_URL_MAP[ENV_VERSION] || API_BASE_URL_MAP.develop;
}

module.exports = {
  BASE_URL: getBaseUrl(),
  getBaseUrl,
  ENV_VERSION,
  REQUEST_LOG_ENABLED,
  API_BASE_URL_MAP,
  REQUEST_LOG_ENABLE_MAP,
  BASE_URL_OVERRIDE_KEY,
  getBaseUrlOverride,
  setBaseUrlOverride,
  clearBaseUrlOverride
};
