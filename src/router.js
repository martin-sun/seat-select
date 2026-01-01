import { createRouter, createWebHistory } from 'vue-router'
import HallSeat from '@/pages/hallseat/HallSeat'
import ReservationStatus from '@/pages/reservation/ReservationStatus'
import MyOrders from '@/pages/myorders/MyOrders'

export default createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes: [
    {
      path: '/',
      name: 'HallSeat',
      component: HallSeat
    },
    {
      path: '/event/:eventId',
      name: 'HallSeatWithEvent',
      component: HallSeat
    },
    {
      path: '/reservation/:id',
      name: 'ReservationStatus',
      component: ReservationStatus
    },
    {
      path: '/my-orders',
      name: 'MyOrders',
      component: MyOrders
    }
  ]
})
