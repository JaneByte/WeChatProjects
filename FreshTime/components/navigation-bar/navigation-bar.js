Component({
  properties: {
    // 标题文字
    title: {
      type: String,
      value: 'FreshTime'
    },
    // 是否显示返回按钮
    back: {
      type: Boolean,
      value: false
    },
    // 是否显示 Logo 艺术字（首页用，优先级高于 title）
    showLogo: {
      type: Boolean,
      value: false
    },
    // 消息角标数量
    messageCount: {
      type: Number,
      value: 0
    }
  },

  data: {
    statusBarHeight: 20
  },

  lifetimes: {
    attached() {
      // 获取状态栏高度
      const systemInfo = wx.getSystemInfoSync()
      this.setData({
        statusBarHeight: systemInfo.statusBarHeight
      })
    }
  },

  methods: {
    // 返回上一页
    onBack() {
      if (this.properties.back) {
        wx.navigateBack({
          fail: () => {
            wx.switchTab({
              url: '/pages/index/index'
            });
          }
        });
      }
    },

    // 点击搜索
    onSearch() {
      this.triggerEvent('search')
    },

    // 点击消息
    onMessage() {
      this.triggerEvent('message')
    }
  }
})