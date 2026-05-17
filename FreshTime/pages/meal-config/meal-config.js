const app = getApp();

Page({
  data: {
    mealType: 'dinner',
    budgetLevel: 'standard',
    dietGoal: 'balanced',
    cookMode: 'quick_cook',
    dislikeTags: [],
    mealTypeOptions: [
      { key: 'lunch', label: '午餐' },
      { key: 'dinner', label: '晚餐' }
    ],
    budgetOptions: [
      { key: 'economy', label: '经济' },
      { key: 'standard', label: '标准' },
      { key: 'plus', label: '升级' }
    ],
    goalOptions: [
      { key: 'light', label: '清爽轻负担' },
      { key: 'high_fiber', label: '高纤饱腹' },
      { key: 'balanced', label: '均衡日常' }
    ],
    cookModeOptions: [
      { key: 'no_cook', label: '免烹饪' },
      { key: 'quick_cook', label: '快手烹饪' }
    ],
    dislikeOptions: [
      { key: 'spicy', label: '不吃辣', selected: false },
      { key: 'cold_food', label: '不吃生冷', selected: false },
      { key: 'sweet', label: '控糖', selected: false }
    ],
    submitting: false
  },

  onLoad() {
    this.syncDislikeSelected(this.data.dislikeTags);
  },

  onChooseOption(e) {
    const field = `${e.currentTarget.dataset.field || ''}`;
    const value = `${e.currentTarget.dataset.value || ''}`;
    if (!field || !value) return;
    if (Number(e.currentTarget.dataset.multi || 0) === 1) {
      const current = Array.isArray(this.data[field]) ? this.data[field].slice() : [];
      const index = current.indexOf(value);
      if (index >= 0) {
        current.splice(index, 1);
      } else {
        current.push(value);
      }
      const nextOptions = (this.data.dislikeOptions || []).map((item) => ({
        ...item,
        selected: current.indexOf(item.key) >= 0
      }));
      this.setData({
        [field]: current,
        dislikeOptions: nextOptions
      });
      return;
    }
    this.setData({ [field]: value });
  },

  onGenerate() {
    if (this.data.submitting) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/meal-config/meal-config' }).catch(() => {});
      return;
    }
    this.setData({ submitting: true });
    const payload = {
      mealType: this.data.mealType,
      budgetLevel: this.data.budgetLevel,
      dietGoal: this.data.dietGoal,
      cookMode: this.data.cookMode,
      dislikeTags: this.data.dislikeTags
    };
    wx.setStorageSync('mealPlanPayload', payload);
    wx.navigateTo({
      url: '/pages/meal-result/meal-result',
      complete: () => this.setData({ submitting: false })
    });
  },

  syncDislikeSelected(dislikeTags = []) {
    const selectedTags = Array.isArray(dislikeTags) ? dislikeTags : [];
    const nextOptions = (this.data.dislikeOptions || []).map((item) => ({
      ...item,
      selected: selectedTags.indexOf(item.key) >= 0
    }));
    this.setData({
      dislikeTags: selectedTags,
      dislikeOptions: nextOptions
    });
  }
});
