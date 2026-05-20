const { get, post } = require('../../utils/request');
const { showRequestError } = require('../../utils/ui');
const app = getApp();

function isPhoneValid(phone) {
  return /^1[3-9]\d{9}$/.test(phone);
}

Page({
  data: {
    id: null,
    submitting: false,
    locating: false,
    locationPreview: '',
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
    if (!app.getUserId()) {
      app.requireLogin({ redirect: options && options.id ? `/pages/address-edit/address-edit?id=${options.id}` : '/pages/address-edit/address-edit', silent: true }).catch(() => {});
      return;
    }
    if (!id) return;

    this.setData({ id });

    get('/address/list', {}, { retry: 0 })
      .then((res) => {
        const list = (res && res.data) || [];
        const current = list.find((item) => item.id === id);
        if (!current) return;
        const preview = `${current.province || ''}${current.city || ''}${current.district || ''} ${(current.detail || '').slice(0, 20)}`;
        this.setData({
          locationPreview: preview,
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
    if (!receiverName || receiverName.length < 2 || receiverName.length > 20) {
      wx.showToast({ title: '收货人姓名需2到20个字符', icon: 'none' });
      return false;
    }
    if (!receiverPhone) {
      wx.showToast({ title: '请填写11位手机号', icon: 'none' });
      return false;
    }
    if (!isPhoneValid(receiverPhone)) {
      wx.showToast({ title: '手机号格式错误，应为1开头11位数字', icon: 'none' });
      return false;
    }
    if (!province || !city || !district) {
      wx.showToast({ title: '请填写完整省市区', icon: 'none' });
      return false;
    }
    if (!detail || detail.length < 5 || detail.length > 100) {
      wx.showToast({ title: '详细地址需5到100个字符', icon: 'none' });
      return false;
    }
    return true;
  },

  onLocateTap() {
    if (this.data.locating) return;
    this.setData({ locating: true });
    this.openLocationPicker();
  },

  openLocationPicker(latitude, longitude) {
    wx.chooseLocation({
      success: (chooseRes) => {
        const addressText = `${chooseRes.address || ''}`.trim();
        const nameText = `${chooseRes.name || ''}`.trim();
        const detailText = `${nameText}${addressText}`.trim().slice(0, 100);
        if (!addressText && !nameText) {
          wx.showToast({ title: '未获取到地址，请重新选择', icon: 'none' });
          return;
        }
        const region = this.parseRegion(addressText);
        const preview = `${region.province}${region.city}${region.district} ${detailText.slice(0, 20)}`;
        this.setData({
          'form.province': region.province,
          'form.city': region.city,
          'form.district': region.district,
          'form.detail': detailText,
          locationPreview: preview
        });
        wx.showToast({ title: '地址已回填', icon: 'success' });
      },
      fail: (error) => {
        const errMsg = `${error && error.errMsg ? error.errMsg : ''}`.toLowerCase();
        console.warn('[address-edit] chooseLocation failed:', error);
        if (errMsg.includes('cancel')) {
          wx.showToast({ title: '你已取消地图选址', icon: 'none' });
          return;
        }
        const shortMsg = `${error && error.errMsg ? error.errMsg : '地图选址失败'}`.slice(0, 28);
        wx.showToast({ title: shortMsg, icon: 'none' });
      },
      complete: () => {
        this.setData({ locating: false });
      }
    });
  },

  parseRegion(addressText) {
    const text = `${addressText || ''}`;
    const provinceMatch = text.match(/^(.*?(省|自治区|行政区|特别行政区))/);
    const directCityMatch = text.match(/^(北京市|上海市|天津市|重庆市)/);
    const province = provinceMatch ? provinceMatch[1] : (directCityMatch ? directCityMatch[1] : '');
    const restAfterProvince = province ? text.slice(province.length) : text;
    const cityMatch = restAfterProvince.match(/^(.*?市)/);
    const city = cityMatch ? cityMatch[1] : (directCityMatch ? directCityMatch[1] : '');
    const restAfterCity = city ? restAfterProvince.slice(city.length) : restAfterProvince;
    const districtMatch = restAfterCity.match(/^(.*?(区|县|旗))/);
    const district = districtMatch ? districtMatch[1] : '';
    return { province, city, district };
  },

  onSave() {
    if (this.data.submitting) return;
    if (!app.getUserId()) {
      app.requireLogin({ redirect: this.data.id ? `/pages/address-edit/address-edit?id=${this.data.id}` : '/pages/address-edit/address-edit' }).catch(() => {});
      return;
    }

    if (!this.validateForm()) return;

    const payload = {
      id: this.data.id || null,
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
