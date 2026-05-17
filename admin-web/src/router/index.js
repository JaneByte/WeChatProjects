import { createRouter, createWebHistory } from 'vue-router';
import DashboardPage from '../views/DashboardPage.vue';
import GoodsPage from '../views/GoodsPage.vue';
import CategoryPage from '../views/CategoryPage.vue';
import OrdersPage from '../views/OrdersPage.vue';
import CouponsPage from '../views/CouponsPage.vue';
import LoginPage from '../views/LoginPage.vue';
import ShopPage from '../views/ShopPage.vue';
import PlanRulesPage from '../views/PlanRulesPage.vue';
import OperationsConfigPage from '../views/OperationsConfigPage.vue';
import { getAdminToken } from '../services/http';

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', component: LoginPage, meta: { public: true } },
    { path: '/', component: DashboardPage },
    { path: '/shop', component: ShopPage },
    { path: '/categories', component: CategoryPage },
    { path: '/goods', component: GoodsPage },
    { path: '/orders', component: OrdersPage },
    { path: '/coupons', component: CouponsPage },
    { path: '/plan-rules', component: PlanRulesPage },
    { path: '/operations-config', component: OperationsConfigPage }
  ]
});

router.beforeEach((to) => {
  if (to.meta.public) {
    return true;
  }
  if (!getAdminToken()) {
    return '/login';
  }
  return true;
});

export default router;
