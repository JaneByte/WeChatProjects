const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

function isPhoneValid(phone) {
  return /^1\d{10}$/.test(phone);
}

Page({
  data: {
    id: null,
    submitting: false,
    form: {
      receiverName: '',
      receiverPhone: '',
      province: '',
      city: '',
      district: '',
      detail: '',
      isDefault: 0
    }
  },

  onLoad(options) {
    const id = Number(options.id || 0);
    if (!id) return;

    this.setData({ id });
    const userId = app.getUserId();
    if (!userId) return;

    get('/address/list', { userId }, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        const current = list.find((item) => item.id === id);
        if (!current) return;
        this.setData({
          form: {
            receiverName: current.receiverName || '',
            receiverPhone: current.receiverPhone || '',
            province: current.province || '',
            city: current.city || '',
            district: current.district || '',
            detail: current.detail || '',
            isDefault: current.isDefault || 0
          }
        });
      })
      .catch((error) => showRequestError(error, '地址读取失败'));
  },

  onInput(e) {
    const { field } = e.currentTarget.dataset;
    this.setData({ [`form.${field}`]: (e.detail.value || '').trim() });
  },

  onToggleDefault(e) {
    this.setData({ 'form.isDefault': e.detail.value ? 1 : 0 });
  },

  validateForm() {
    const { receiverName, receiverPhone, province, city, district, detail } = this.data.form;
    if (!receiverName) {
      wx.showToast({ title: '请填写收货人', icon: 'none' });
      return false;
    }
    if (!receiverPhone) {
      wx.showToast({ title: '请填写手机号', icon: 'none' });
      return false;
    }
    if (!isPhoneValid(receiverPhone)) {
      wx.showToast({ title: '手机号格式不正确', icon: 'none' });
      return false;
    }
    if (!province || !city || !district) {
      wx.showToast({ title: '请填写完整省市区', icon: 'none' });
      return false;
    }
    if (!detail) {
      wx.showToast({ title: '请填写详细地址', icon: 'none' });
      return false;
    }
    return true;
  },

  onSave() {
    if (this.data.submitting) return;
    const userId = app.getUserId();
    if (!userId) {
      wx.showToast({ title: '登录中，请稍后重试', icon: 'none' });
      return;
    }

    if (!this.validateForm()) return;

    const payload = {
      id: this.data.id || null,
      userId,
      ...this.data.form
    };

    this.setData({ submitting: true });
    post('/address/save', payload, { retry: 0 })
      .then(() => {
        wx.showToast({ title: '保存成功', icon: 'success' });
        setTimeout(() => wx.navigateBack(), 500);
      })
      .catch((error) => showRequestError(error, '保存失败'))
      .finally(() => this.setData({ submitting: false }));
  }
});
