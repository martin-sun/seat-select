import { createRouter, createWebHistory } from 'vue-router'
import HallSeat from '@/pages/hallseat/HallSeat'

export default createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'HallSeat',
      component: HallSeat
    }
  ]
})
