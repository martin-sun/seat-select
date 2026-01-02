<template>
  <div
    :class="[
      'ticket-card relative overflow-hidden rounded-2xl p-6 transition-all duration-300 hover:scale-105 hover:shadow-2xl',
      cardClasses
    ]"
  >
    <!-- 装饰角标 -->
    <div v-if="ticket.color === 'gold'" class="absolute top-0 right-0 bg-yellow-400 text-red-900 text-xs font-bold px-3 py-1 rounded-bl-lg">
      VIP
    </div>

    <!-- 票种名称 -->
    <h3 :class="['text-xl font-bold mb-2', titleClasses]">
      {{ ticket.name }}
    </h3>

    <!-- 价格 -->
    <div class="mb-4">
      <span :class="['text-4xl font-bold', priceClasses]">${{ ticket.price }}</span>
      <span class="text-yellow-100/70 text-sm ml-1">/ {{ $t('chunwan.ticketCard.perPerson') }}</span>
    </div>

    <!-- 描述 -->
    <p class="text-yellow-100/80 text-sm mb-4">
      {{ ticket.description }}
    </p>

    <!-- 购票按钮 -->
    <router-link
      :to="`/${$route.params.lang || 'zh'}/tickets`"
      :class="[
        'block w-full text-center py-3 rounded-lg font-semibold transition-all',
        buttonClasses
      ]"
    >
      {{ ticket.available ? $t('chunwan.ticketCard.select') : $t('chunwan.ticketCard.soldOut') }}
    </router-link>
  </div>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'TicketCard',
  props: {
    ticket: {
      type: Object,
      required: true
    }
  },
  setup(props) {
    const cardClasses = computed(() => {
      switch (props.ticket.color) {
        case 'gold':
          return 'bg-gradient-to-br from-yellow-600 via-yellow-500 to-yellow-700 border-2 border-yellow-400'
        case 'silver':
          return 'bg-gradient-to-br from-gray-600 via-gray-500 to-gray-700 border border-gray-400'
        case 'bronze':
          return 'bg-gradient-to-br from-amber-700 via-amber-600 to-amber-800 border border-amber-500'
        default:
          return 'bg-red-800 border border-red-700'
      }
    })

    const titleClasses = computed(() => {
      switch (props.ticket.color) {
        case 'gold':
          return 'text-red-900'
        default:
          return 'text-yellow-100'
      }
    })

    const priceClasses = computed(() => {
      switch (props.ticket.color) {
        case 'gold':
          return 'text-red-900'
        default:
          return 'text-yellow-400'
      }
    })

    const buttonClasses = computed(() => {
      if (!props.ticket.available) {
        return 'bg-gray-500 text-gray-300 cursor-not-allowed'
      }
      switch (props.ticket.color) {
        case 'gold':
          return 'bg-red-900 text-yellow-400 hover:bg-red-800'
        default:
          return 'bg-yellow-500 text-red-900 hover:bg-yellow-400'
      }
    })

    return {
      cardClasses,
      titleClasses,
      priceClasses,
      buttonClasses
    }
  }
}
</script>

<style scoped>
.ticket-card {
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.3);
}
</style>
