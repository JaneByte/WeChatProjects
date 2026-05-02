function showRequestError(error, fallback = '加载失败') {
  const title = (error && error.message) ? error.message : fallback;
  wx.showToast({
    title,
    icon: 'none',
    duration: 1500
  });
}

module.exports = {
  showRequestError
};
