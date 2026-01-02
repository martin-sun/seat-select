import { createRouter, createWebHistory } from 'vue-router'
import HallSeat from '@/pages/hallseat/HallSeat'
import ReservationStatus from '@/pages/reservation/ReservationStatus'
import MyOrders from '@/pages/myorders/MyOrders'
import i18n, { setLocale } from '@/i18n'

const ChunwanHome = () => import('@/pages/home/ChunwanHome.vue')
const ChunwanPrograms = () => import('@/pages/home/ChunwanPrograms.vue')

const supportedLocales = ['zh', 'en']

const routes = [
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
    // 捕获旧的无语言前缀路由，重定向
    path: '/:pathMatch(.*)*',
    redirect: to => {
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

// 路由守卫：根据 URL 中的语言设置 i18n
router.beforeEach((to, from, next) => {
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
  } else {
    // 无效语言前缀，重定向到默认语言
    const stored = localStorage.getItem('locale')
    const defaultLang = stored === 'zh-CN' ? 'zh' : 'en'
    next(`/${defaultLang}${to.fullPath}`)
  }
})

export default router
