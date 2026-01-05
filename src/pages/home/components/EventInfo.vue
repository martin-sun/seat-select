<template>
  <section class="event-info py-12 px-4">
    <div class="max-w-4xl mx-auto">
      <!-- 时间地点卡片 -->
      <div class="bg-red-950/60 backdrop-blur-sm rounded-2xl p-6 md:p-8 border border-red-700/30 shadow-xl">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- 时间 -->
          <div class="flex items-start space-x-4">
            <div class="flex-shrink-0 w-12 h-12 bg-yellow-500/20 rounded-full flex items-center justify-center">
              <span class="text-2xl">📅</span>
            </div>
            <div>
              <h3 class="text-yellow-400 font-semibold mb-1">{{ $t('chunwan.eventInfo.date') }}</h3>
              <p class="text-yellow-100 text-lg">{{ formattedDate }}</p>
              <p class="text-yellow-100/70 text-sm">{{ formattedTime }}</p>
            </div>
          </div>

          <!-- 地点 -->
          <div class="flex items-start space-x-4">
            <div class="flex-shrink-0 w-12 h-12 bg-yellow-500/20 rounded-full flex items-center justify-center">
              <span class="text-2xl">📍</span>
            </div>
            <div>
              <h3 class="text-yellow-400 font-semibold mb-1">{{ $t('chunwan.eventInfo.location') }}</h3>
              <p class="text-yellow-100 text-lg">{{ location }}</p>
              <p class="text-yellow-100/70 text-sm">{{ address }}</p>
            </div>
          </div>
        </div>
      </div>

      <!-- 活动介绍 -->
      <div class="mt-8 text-center">
        <h2 class="text-2xl md:text-3xl font-bold text-yellow-400 mb-6">{{ $t('chunwan.eventInfo.aboutTitle') }}</h2>
        <p class="text-yellow-100/90 text-lg leading-relaxed max-w-3xl mx-auto">
          {{ aboutContent }}
        </p>
      </div>
    </div>
  </section>
</template>

<script>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

export default {
  name: 'EventInfo',
  props: {
    date: {
      type: String,
      required: true
    },
    location: {
      type: String,
      required: true
    },
    address: {
      type: String,
      default: ''
    },
    aboutContent: {
      type: String,
      default: ''
    }
  },
  setup(props) {
    const { locale } = useI18n()

    const formattedDate = computed(() => {
      const d = new Date(props.date)
      if (isNaN(d.getTime())) return props.date
      const options = { year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' }
      return d.toLocaleDateString(locale.value === 'zh-CN' ? 'zh-CN' : 'en-US', options)
    })

    const formattedTime = computed(() => {
      const d = new Date(props.date)
      if (isNaN(d.getTime())) return ''
      const options = { hour: '2-digit', minute: '2-digit' }
      return d.toLocaleTimeString(locale.value === 'zh-CN' ? 'zh-CN' : 'en-US', options)
    })

    return {
      formattedDate,
      formattedTime
    }
  }
}
</script>
