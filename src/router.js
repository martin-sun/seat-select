import { createRouter, createWebHistory } from 'vue-router'
import HallSeat from '@/pages/hallseat/HallSeat'
import ReservationStatus from '@/pages/reservation/ReservationStatus'
import MyOrders from '@/pages/myorders/MyOrders'
import i18n, { setLocale } from '@/i18n'
import { isAdminLoggedIn } from '@/supabase'

const ChunwanHome = () => import('@/pages/home/ChunwanHome.vue')
const ChunwanPrograms = () => import('@/pages/home/ChunwanPrograms.vue')

// Admin pages (lazy loaded)
const AdminLogin = () => import('@/pages/admin/AdminLogin.vue')
const AdminLayout = () => import('@/pages/admin/AdminLayout.vue')
const OrdersManagement = () => import('@/pages/admin/OrdersManagement.vue')
const ContentManagement = () => import('@/pages/admin/ContentManagement.vue')
const SeatsManagement = () => import('@/pages/admin/SeatsManagement.vue')
const ProgramsManagement = () => import('@/pages/admin/ProgramsManagement.vue')

const supportedLocales = ['zh', 'en']

const routes = [
  // Admin routes (no language prefix)
  {
    path: '/admin/login',
    name: 'AdminLogin',
    component: AdminLogin,
    meta: { isAdmin: true, requiresAuth: false }
  },
  {
    path: '/admin',
    component: AdminLayout,
    meta: { isAdmin: true, requiresAuth: true },
    children: [
      {
        path: '',
        redirect: '/admin/orders'
      },
      {
        path: 'orders',
        name: 'AdminOrders',
        component: OrdersManagement
      },
      {
        path: 'programs',
        name: 'AdminPrograms',
        component: ProgramsManagement
      },
      {
        path: 'content',
        name: 'AdminContent',
        component: ContentManagement
      },
      {
        path: 'seats',
        name: 'AdminSeats',
        component: SeatsManagement
      }
    ]
  },
  // Public routes with language prefix
  {
    path: '/:lang',
    children: [
      {
        path: '',
        name: 'ChunwanHome',
        component: ChunwanHome
      },
      {
        path: 'tickets',
        name: 'HallSeat',
        component: HallSeat
      },
      {
        path: 'tickets/event/:eventId',
        name: 'HallSeatWithEvent',
        component: HallSeat
      },
      {
        path: 'programs',
        name: 'ChunwanPrograms',
        component: ChunwanPrograms
      },
      {
        path: 'reservation/:id',
        name: 'ReservationStatus',
        component: ReservationStatus
      },
      {
        path: 'my-orders',
        name: 'MyOrders',
        component: MyOrders
      }
    ]
  },
  {
    // 根路径重定向到默认语言
    path: '/',
    redirect: () => {
      const stored = localStorage.getItem('locale')
      if (stored) {
        return stored === 'zh-CN' ? '/zh' : '/en'
      }
      const browserLang = navigator.language || navigator.userLanguage
      return browserLang.startsWith('zh') ? '/zh' : '/en'
    }
  },
  {
    // 捕获旧的无语言前缀路由，重定向（排除 admin 路由）
    path: '/:pathMatch(.*)*',
    redirect: to => {
      // 不要重定向 admin 路由
      if (to.fullPath.startsWith('/admin')) {
        return to.fullPath
      }
      const stored = localStorage.getItem('locale')
      const lang = stored === 'zh-CN' ? 'zh' : 'en'
      return `/${lang}${to.fullPath}`
    }
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  // Admin routes authentication check
  if (to.meta.isAdmin) {
    if (to.meta.requiresAuth && !isAdminLoggedIn()) {
      return next('/admin/login')
    }
    // Admin routes don't need language handling
    return next()
  }

  // Public routes - handle language
  const lang = to.params.lang

  if (lang && supportedLocales.includes(lang)) {
    const locale = lang === 'zh' ? 'zh-CN' : 'en-US'
    if (i18n.global.locale !== locale) {
      setLocale(locale)
    }
    next()
  } else if (to.path === '/') {
    // 根路径会被上面的 redirect 处理
    next()
  } else if (to.path.startsWith('/admin')) {
    // Admin 路由不需要语言前缀
    next()
  } else {
    // 无效语言前缀，重定向到默认语言
    const stored = localStorage.getItem('locale')
    const defaultLang = stored === 'zh-CN' ? 'zh' : 'en'
    next(`/${defaultLang}${to.fullPath}`)
  }
})

export default router

