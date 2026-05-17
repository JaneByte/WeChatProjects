const app = getApp();

Page({
  data: {
    goalScene: 'salad',
    peopleCount: '1',
    budgetLevel: 'standard',
    tastePref: 'fresh',
    goalOptions: [
      { key: 'salad', label: '沙拉轻食' },
      { key: 'juice', label: '果蔬榨汁' },
      { key: 'hotpot', label: '火锅配菜' },
      { key: 'bento_side', label: '便当配菜' }
    ],
    peopleOptions: [
      { key: '1', label: '1人' },
      { key: '2', label: '2人' },
      { key: '3_4', label: '3-4人' }
    ],
    budgetOptions: [
      { key: 'economy', label: '经济' },
      { key: 'standard', label: '标准' },
      { key: 'plus', label: '升级' }
    ],
    tasteOptions: [
      { key: 'fresh', label: '清爽' },
      { key: 'sweet', label: '偏甜' },
      { key: 'crisp', label: '脆口' }
    ],
    submitting: false
  },

  onChooseOption(e) {
    const field = `${e.currentTarget.dataset.field || ''}`;
    const value = `${e.currentTarget.dataset.value || ''}`;
    if (!field || !value) return;
    this.setData({ [field]: value });
  },

  onGenerate() {
    if (this.data.submitting) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: '/pages/combo-config/combo-config' }).catch(() => {});
      return;
    }
    this.setData({ submitting: true });
    const payload = {
      goalScene: this.data.goalScene,
      peopleCount: this.data.peopleCount,
      budgetLevel: this.data.budgetLevel,
      tastePref: this.data.tastePref
    };
    wx.setStorageSync('comboPlanPayload', payload);
    wx.navigateTo({
      url: '/pages/combo-result/combo-result',
      complete: () => this.setData({ submitting: false })
    });
  }
});
