// components/goods-card/goods-card.js
Component({
  properties: {
    item: {
      type: Object,
      value: {}
    }
  },
  methods: {
    onTap() {
      this.triggerEvent('goodstap', { item: this.properties.item });
    },
    onAdd(e) {
      e.stopPropagation();
      this.triggerEvent('add', { item: this.properties.item });
    }
  }
});