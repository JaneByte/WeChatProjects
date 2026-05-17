const { uploadFile } = require('../../utils/request.js');
const { showRequestError } = require('../../utils/ui.js');
const app = getApp();
const DEFAULT_AVATAR = '/assets/icon/my.png';

function isLocalAvatarPath(path) {
  if (!path || typeof path !== 'string') return false;
  return /^(wxfile:|http:\/\/tmp\/|\/tmp\/|file:|blob:)/.test(path);
}

Page({
  data: {
    loading: false,
    submitting: false,
    mode: 'edit',
    redirect: '',
    profile: {
      nickname: '微信用户',
      avatar: DEFAULT_AVATAR
    }
  },

  onLoad(options) {
    this.setData({
      mode: options && options.mode === 'onboarding' ? 'onboarding' : 'edit',
      redirect: options && options.redirect ? decodeURIComponent(options.redirect) : ''
    });
  },

  onShow() {
    if (!app.getUserId()) {
      const redirect = this.data.mode === 'onboarding'
        ? `/pages/profile-edit/profile-edit?mode=onboarding${this.data.redirect ? `&redirect=${encodeURIComponent(this.data.redirect)}` : ''}`
        : '/pages/profile-edit/profile-edit';
      app.requireLogin({ redirect, silent: true }).catch(() => {});
      return;
    }
    this.syncLocalProfile();
  },

  syncLocalProfile() {
    const loginProfile = app.getLoginProfile() || {};
    this.setData({
      profile: {
        nickname: loginProfile.nickname || '微信用户',
        avatar: loginProfile.avatar || DEFAULT_AVATAR
      }
    });
  },

  onChooseAvatar(e) {
    const avatarUrl = e?.detail?.avatarUrl || '';
    if (!avatarUrl) return;
    
    const that = this;
    wx.getImageInfo({
      src: avatarUrl,
      success: () => {
        that.setData({ 'profile.avatar': avatarUrl });
      },
      fail: () => {
        wx.showToast({ title: '头像加载失败，请重试', icon: 'none' });
        that.setData({ 'profile.avatar': DEFAULT_AVATAR });
      }
    });
  },

  onInputNickname(e) {
    const nickname = e?.detail?.value || '';
    this.setData({ 'profile.nickname': nickname.trimStart() });
  },

  finishProfileFlow() {
    const { mode, redirect } = this.data;
    if (mode === 'onboarding') {
      if (redirect) {
        const tabPages = [
          '/pages/index/index',
          '/pages/category/category',
          '/pages/cart/cart',
          '/pages/profile/profile'
        ];
        if (tabPages.includes(redirect)) {
          wx.switchTab({ url: redirect });
          return;
        }
        wx.redirectTo({
          url: redirect,
          fail: () => wx.switchTab({ url: '/pages/profile/profile' })
        });
        return;
      }
      wx.switchTab({ url: '/pages/profile/profile' });
      return;
    }
    wx.navigateBack({ delta: 1, fail: () => wx.switchTab({ url: '/pages/profile/profile' }) });
  },

  onSubmit() {
    if (this.data.submitting || this.data.loading) return;
    
    const nickname = this.data.profile.nickname?.trim() || '';
    if (!nickname) {
      wx.showToast({ title: '请输入昵称', icon: 'none' });
      return;
    }
  
    this.setData({ submitting: true });

    const avatarUrl = this.data.profile.avatar;
    let uploadPromise = Promise.resolve(avatarUrl);

    if (isLocalAvatarPath(avatarUrl)) {
      uploadPromise = uploadFile('/upload/image', avatarUrl)
        .then((res) => ((res && res.data && res.data.url) || ''));
    }

    uploadPromise
      .then((serverAvatarUrl) => {
        if (isLocalAvatarPath(avatarUrl) && !serverAvatarUrl) {
          throw new Error('头像上传失败，请重试');
        }
        const finalProfile = {
          nickname,
          avatar: serverAvatarUrl || avatarUrl || DEFAULT_AVATAR
        };
        this.setData({ profile: finalProfile });
        app.setLoginProfile({
          ...app.getLoginProfile(),
          ...finalProfile
        });

        return app.updateProfile(finalProfile);
      })
      .then(() => {
        wx.showToast({ title: '资料已保存', icon: 'success', duration: 1200 });
        setTimeout(() => {
          this.finishProfileFlow();
        }, 300);
      })
      .catch((error) => {
        showRequestError(error, '保存失败');
      })
      .finally(() => {
        this.setData({ submitting: false });
      });
  },

  onSkip() {
    if (this.data.loading || this.data.submitting) return;
    this.finishProfileFlow();
  }
});
