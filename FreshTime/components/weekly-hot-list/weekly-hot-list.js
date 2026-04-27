Component({
  properties: {
    // 展示模式：scroll（横向滚动）/ grid（网格）
    mode: {
      type: String,
      value: 'scroll'
    },
    // 商品列表数据
    list: {
      type: Array,
      value: []
    },
    // 是否显示销量
    showSales: {
      type: Boolean,
      value: true
    }
  },

  methods: {
    // 点击商品
    onItemTap(e) {
      const { item } = e.currentTarget.dataset
      this.triggerEvent('itemtap', { item })
    },

    // 点击加购
    onAddToCart(e) {
      e.stopPropagation()
      const { item } = e.currentTarget.dataset
      this.triggerEvent('addtocart', { item })
    }
  }
})