const { post } = require('./request');

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function normalizeAmount(amount) {
  const value = Number(amount || 0);
  if (!Number.isFinite(value) || value < 0) {
    return '0.00';
  }
  return value.toFixed(2);
}

function buildPayTip(orderNo, actualAmount) {
  const orderTail = String(orderNo || '').slice(-4) || '----';
  return `订单尾号 ${orderTail}\n支付金额 ¥${normalizeAmount(actualAmount)}`;
}

async function runMockPayFlow(options = {}) {
  const { orderId, orderNo, actualAmount, userId } = options;
  if (!orderId) {
    throw new Error('orderId不能为空');
  }
  const createPath = userId
    ? `/order/pay/mock-create?orderId=${orderId}&userId=${Number(userId)}`
    : `/order/pay/mock-create?orderId=${orderId}`;
  const createRes = await post(createPath, {}, { retry: 0 });
  const payData = (createRes && createRes.data) || {};
  const payTradeNo = payData.payTradeNo || '';
  if (!payTradeNo) {
    throw new Error('支付单创建失败');
  }

  const confirmRes = await new Promise((resolve) => {
    wx.showModal({
      title: '微信支付（模拟）',
      content: buildPayTip(orderNo, actualAmount),
      confirmText: '确认支付',
      cancelText: '取消',
      success: resolve,
      fail: () => resolve({ confirm: false, cancel: true })
    });
  });

  if (!confirmRes.confirm) {
    const cancelError = new Error('用户取消支付');
    cancelError.code = 'PAY_CANCELLED';
    throw cancelError;
  }

  await wait(400);
  const confirmPayload = userId
    ? { orderId, payTradeNo, userId: Number(userId) }
    : { orderId, payTradeNo };
  return post('/order/pay/mock-confirm', confirmPayload, { retry: 0 }).then((res) => {
    const data = (res && res.data) || {};
    return {
      orderId,
      payTradeNo: data.payTradeNo || payTradeNo,
      payChannel: data.payChannel || 'mock_wechat'
    };
  });
}

module.exports = {
  runMockPayFlow
};
