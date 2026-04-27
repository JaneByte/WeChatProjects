const BASE_URL_OVERRIDE_KEY = 'baseUrlOverride';

function getEnvVersion() {
  try {
    const accountInfo = wx.getAccountInfoSync();
    if (accountInfo && accountInfo.miniProgram && accountInfo.miniProgram.envVersion) {
      return accountInfo.miniProgram.envVersion;
    }
    return 'develop';
  } catch (error) {
    return 'develop';
  }
}

function isValidHttpUrl(url) {
  return typeof url === 'string' && /^https?:\/\//.test(url);
}

function getBaseUrlOverride() {
  try {
    const overrideUrl = wx.getStorageSync(BASE_URL_OVERRIDE_KEY);
    if (isValidHttpUrl(overrideUrl)) {
      return overrideUrl;
    }
    return '';
  } catch (error) {
    return '';
  }
}

function setBaseUrlOverride(url) {
  if (!isValidHttpUrl(url)) {
    throw new Error('baseUrl override must start with http:// or https://');
  }
  wx.setStorageSync(BASE_URL_OVERRIDE_KEY, url);
}

function clearBaseUrlOverride() {
  wx.removeStorageSync(BASE_URL_OVERRIDE_KEY);
}

module.exports = {
  BASE_URL_OVERRIDE_KEY,
  getEnvVersion,
  isValidHttpUrl,
  getBaseUrlOverride,
  setBaseUrlOverride,
  clearBaseUrlOverride
};
