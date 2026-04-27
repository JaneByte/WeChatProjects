// pages/profile/profile.js
Page({
  data: {
    userInfo: {
      nickname: '新鲜生活家',
      level: '普通会员',
      avatar: '/assets/icon/my.png'
    },
    orderTabs: [
      { key: 'pendingPay', label: '待付款', mark: '付' },
      { key: 'pendingShip', label: '待发货', mark: '发' },
      { key: 'pendingReceive', label: '待收货', mark: '收' },
      { key: 'afterSale', label: '售后', mark: '售' }
    ],
    menuList: [
      { key: 'address', label: '收货地址', desc: '管理常用地址' },
      { key: 'coupon', label: '优惠券', desc: '查看可用优惠' },
      { key: 'service', label: '在线客服', desc: '问题咨询与反馈' },
      { key: 'settings', label: '设置', desc: '账号与通知配置' }
    ]
  },

  onOrderTap(e) {
    const { key } = e.currentTarget.dataset;
    wx.showToast({
      title: `订单功能开发中：${key}`,
      icon: 'none'
    });
  },

  onMenuTap(e) {
    const { key } = e.currentTarget.dataset;
    wx.showToast({
      title: `功能开发中：${key}`,
      icon: 'none'
    });
  },

  onPullDownRefresh() {
    wx.stopPullDownRefresh();
  }
});
