<template>
  <RouterView v-if="isLoginPage" />

  <div v-else class="app-shell">
    <aside class="sidebar">
      <div class="brand">
        <div class="brand-mark">鲜</div>
        <div>
          <div class="brand-title">FreshTime 店铺后台</div>
          <div class="brand-sub">商品、订单与店铺运营</div>
        </div>
      </div>
      <nav class="nav-list">
        <RouterLink to="/" class="nav-item">数据概览</RouterLink>
        <RouterLink to="/shop" class="nav-item">店铺信息</RouterLink>
        <RouterLink to="/categories" class="nav-item">分类管理</RouterLink>
        <RouterLink to="/goods" class="nav-item">商品管理</RouterLink>
        <RouterLink to="/orders" class="nav-item">订单管理</RouterLink>
        <RouterLink to="/coupons" class="nav-item">优惠券管理</RouterLink>
        <RouterLink to="/plan-rules" class="nav-item">方案规则</RouterLink>
        <RouterLink to="/operations-config" class="nav-item">运营配置</RouterLink>
      </nav>
    </aside>

    <main class="main-panel">
      <header class="topbar">
        <div>
          <h1 class="page-title">FreshTime 店铺经营后台</h1>
          <p class="page-subtitle">当前为单商户模式，支持商品、订单、分类与营销管理</p>
        </div>
        <div class="topbar-actions">
          <div class="topbar-tag">SpringBoot + Vue</div>
          <button class="ghost-btn" @click="onLogout">退出</button>
        </div>
      </header>

      <section class="content-panel">
        <RouterView />
      </section>
    </main>
  </div>
</template>

<script setup>
import { computed } from 'vue';
import { useRoute, useRouter, RouterLink, RouterView } from 'vue-router';
import { clearAdminSession } from './services/http';

const route = useRoute();
const router = useRouter();
const isLoginPage = computed(() => route.path === '/login');

function onLogout() {
  clearAdminSession();
  router.push('/login');
}
</script>
