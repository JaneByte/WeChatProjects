Page({
  data: {
    notifyOrder: true,
    notifyPromo: false
  },

  onToggleOrder(e) {
    this.setData({ notifyOrder: !!e.detail.value });
  },

  onTogglePromo(e) {
    this.setData({ notifyPromo: !!e.detail.value });
  }
});

