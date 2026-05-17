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
    wx.getSetting({
      success: (settingRes) => {
        const auth = settingRes && settingRes.authSetting ? settingRes.authSetting['scope.userLocation'] : false;
        if (auth === false) {
          this.setData({ locating: false });
          wx.showModal({
            title: '需要定位权限',
            content: '请先授权定位后再获取当前地址',
            confirmText: '去授权',
            success: (modalRes) => {
              if (modalRes.confirm) {
                wx.openSetting({});
              }
            }
          });
          return;
        }
        this.requestLocationAndFill();
      },
      fail: () => {
        this.setData({ locating: false });
        wx.showToast({ title: '获取授权状态失败', icon: 'none' });
      }
    });
  },

  requestLocationAndFill() {
    wx.getLocation({
      type: 'gcj02',
      success: (locRes) => {
        const { latitude, longitude } = locRes || {};
        wx.chooseLocation({
          latitude,
          longitude,
          success: (chooseRes) => {
            const addressText = `${chooseRes.address || ''}`.trim();
            const nameText = `${chooseRes.name || ''}`.trim();
            const region = this.parseRegion(addressText);
            this.setData({
              'form.province': region.province,
              'form.city': region.city,
              'form.district': region.district,
              'form.detail': `${nameText}${addressText}`.slice(0, 100)
            });
          },
          fail: () => {
            wx.showToast({ title: '未选择地址，请手动填写', icon: 'none' });
          },
          complete: () => {
            this.setData({ locating: false });
          }
        });
      },
      fail: () => {
        this.setData({ locating: false });
        wx.showToast({ title: '定位失败，请检查定位权限', icon: 'none' });
      }
    });
  },

  parseRegion(addressText) {
    const text = `${addressText || ''}`;
    const provinceMatch = text.match(/^(.*?(省|自治区|行政区|特别行政区))/);
    const province = provinceMatch ? provinceMatch[1] : '';
    const restAfterProvince = province ? text.slice(province.length) : text;
    const cityMatch = restAfterProvince.match(/^(.*?市)/);
    const city = cityMatch ? cityMatch[1] : '';
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
