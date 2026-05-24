const { resolveImageUrl, uploadAvatarToCloud } = require('../../utils/cloud.js');
const { showRequestError } = require('../../utils/ui.js');
const app = getApp();
const DEFAULT_AVATAR = '/assets/icon/my.png';

function isLocalAvatarPath(path) {
  if (!path || typeof path !== 'string') return false;
  return /^(wxfile:|http:\/\/tmp\/|\/tmp\/|file:|blob:)/.test(path);
}

function normalizeAvatarFile(filePath) {
  return new Promise((resolve) => {
    if (!isLocalAvatarPath(filePath)) {
      resolve({
        tempFilePath: filePath || '',
        compressed: false
      });
      return;
    }
    wx.compressImage({
      src: filePath,
      quality: 82,
      compressedHeight: 720,
      compressedWidth: 720,
      success: (res) => resolve({
        tempFilePath: (res && res.tempFilePath) || filePath,
        compressed: true
      }),
      fail: () => resolve({
        tempFilePath: filePath,
        compressed: false
      })
    });
  });
}

Page({
  data: {
    loading: false,
    submitting: false,
    mode: 'edit',
    redirect: '',
    avatarPreview: DEFAULT_AVATAR,
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

  async syncLocalProfile() {
    const loginProfile = app.getLoginProfile() || {};
    const avatar = loginProfile.avatar || DEFAULT_AVATAR;
    const avatarPreview = await app.getResolvedAvatar(avatar);
    this.setData({
      avatarPreview: avatarPreview || DEFAULT_AVATAR,
      profile: {
        nickname: loginProfile.nickname || '微信用户',
        avatar
      }
    });
  },

  onChooseAvatar(e) {
    const avatarUrl = e?.detail?.avatarUrl || '';
    if (!avatarUrl) return;
    normalizeAvatarFile(avatarUrl).then((result) => {
      const nextPath = (result && result.tempFilePath) || avatarUrl;
      this.setData({
        avatarPreview: nextPath,
        'profile.avatar': nextPath
      });
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
      uploadPromise = uploadAvatarToCloud(avatarUrl, app.getUserId());
    }

    uploadPromise
      .then(async (serverAvatarUrl) => {
        if (isLocalAvatarPath(avatarUrl) && !serverAvatarUrl) {
          throw new Error('头像上传失败，请重试');
        }
        const nextAvatar = serverAvatarUrl || avatarUrl || DEFAULT_AVATAR;
        const avatarPreview = await resolveImageUrl(nextAvatar) || nextAvatar || DEFAULT_AVATAR;
        const finalProfile = {
          nickname,
          avatar: nextAvatar
        };
        this.setData({
          avatarPreview,
          profile: {
            ...finalProfile
          }
        });
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
