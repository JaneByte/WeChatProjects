<template>
  <div class="login-page">
    <div class="login-card">
      <div class="login-brand">
        <div class="brand-mark">鲜</div>
        <div>
          <h1 class="login-title">FreshTime 店铺后台</h1>
          <p class="login-subtitle">使用店铺账号和密码登录经营后台</p>
        </div>
      </div>

      <div class="form-grid login-form">
        <input v-model.trim="username" class="input" placeholder="店铺账号" />
        <input v-model.trim="password" class="input" type="password" placeholder="登录密码" />
      </div>

      <div v-if="error" class="error-box">{{ error }}</div>

      <div class="toolbar">
        <button class="primary-btn" @click="onLogin" :disabled="loading">
          {{ loading ? '校验中...' : '进入后台' }}
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';
import { useRouter } from 'vue-router';
import { authHttp, saveAdminSession } from '../services/http';

const router = useRouter();
const username = ref('');
const password = ref('');
const error = ref('');
const loading = ref(false);

async function onLogin() {
  if (!username.value) {
    error.value = '请输入店铺账号';
    return;
  }
  if (!password.value) {
    error.value = '请输入登录密码';
    return;
  }
  loading.value = true;
  error.value = '';
  try {
    const res = await authHttp.post('/auth/login', {
      username: username.value,
      password: password.value
    });
    const session = res?.data?.data || {};
    saveAdminSession({
      token: session.token,
      adminInfo: {
        id: session.adminId,
        username: session.username,
        shopName: session.shopName
      }
    });
    router.push('/');
  } catch (err) {
    error.value = err?.response?.data?.message || err.message || '登录失败';
  } finally {
    loading.value = false;
  }
}
</script>
