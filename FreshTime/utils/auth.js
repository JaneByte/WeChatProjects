const app = getApp();

function getUserId() {
  return app.getUserId();
}

function ensureLogin() {
  return app.ensureLoginReady().then((userId) => {
    if (!userId) {
      throw new Error('登录失败，请稍后重试');
    }
    return userId;
  });
}

function loginByOpenid(openid, nickname, requestPost) {
  return requestPost('/auth/login', { openid, nickname }, { retry: 0 }).then((res) => {
    const data = (res && res.data) || {};
    if (!data.userId) {
      throw new Error('登录失败');
    }
    app.setUserId(data.userId);
    return data;
  });
}

module.exports = {
  getUserId,
  ensureLogin,
  loginByOpenid
};
