// components/flash-sale-item/flash-sale-item.js
Component({
  properties: {
    item: {
      type: Object,
      value: {}
    }
  },
  methods: {
    onTap() {
      this.triggerEvent('tap', { item: this.properties.item })
    },
    onBuy(e) {
      e.stopPropagation()
      this.triggerEvent('buy', { item: this.properties.item })
    }
  }
})