Component({
  properties: {
    // 展示模式：scroll/grid
    mode: {
      type: String,
      value: 'scroll'
    },
    // 商品列表
    list: {
      type: Array,
      value: []
    },
    // 是否展示销量
    showSales: {
      type: Boolean,
      value: true
    }
  },

  methods: {
    onItemTap(e) {
      const { item } = e.currentTarget.dataset;
      this.triggerEvent('itemtap', { item });
    },

    onAddToCart(e) {
      e.stopPropagation();
      const { item } = e.currentTarget.dataset;
      this.triggerEvent('addtocart', { item });
    }
  }
});
