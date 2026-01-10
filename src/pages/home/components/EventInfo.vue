<template>
  <section class="event-info py-12 px-4">
    <div class="max-w-4xl mx-auto">
      <!-- 时间地点卡片 -->
      <div class="bg-red-950/60 backdrop-blur-sm rounded-2xl p-6 md:p-8 border border-red-700/30 shadow-xl">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <!-- 时间 -->
          <div class="flex items-start space-x-4">
            <div class="flex-shrink-0 w-12 h-12 bg-yellow-500/20 rounded-full flex items-center justify-center">
              <div class="calendar-icon">
                <div class="calendar-month">{{ iconMonth }}</div>
                <div class="calendar-day">{{ iconDay }}</div>
              </div>
            </div>
            <div>
              <h3 class="text-yellow-400 font-semibold mb-1">{{ $t('chunwan.eventInfo.date') }}</h3>
              <p class="text-yellow-100 whitespace-nowrap"
                 style="font-size: clamp(0.875rem, 0.75rem + 0.3vw, 1.125rem);">
                {{ formattedDate }}
              </p>
              <!-- 时间安排 -->
              <div class="mt-2 space-y-1">
                <p class="text-yellow-200/70"
                   style="font-size: clamp(0.625rem, 0.5rem + 0.3vw, 0.875rem);">
                  {{ $t('chunwan.banner.schedule.afternoon') }}
                </p>
                <p class="text-yellow-200/70"
                   style="font-size: clamp(0.625rem, 0.5rem + 0.3vw, 0.875rem);">
                  {{ $t('chunwan.banner.schedule.admission') }}
                </p>
              </div>  
            </div>
          </div>

          <!-- 地点 -->
          <div class="flex items-start space-x-4">
            <div class="flex-shrink-0 w-12 h-12 bg-yellow-500/20 rounded-full flex items-center justify-center">
              <span class="text-2xl">📍</span>
            </div>
            <div>
              <h3 class="text-yellow-400 font-semibold mb-1">{{ $t('chunwan.eventInfo.location') }}</h3>
              <a href="https://www.google.com/maps/place/Lakeview+Church/@52.0863804,-106.5811565,17z/data=!3m1!4b1!4m6!3m5!1s0x5304f1803fe36201:0x70ecf16ef81613fa!8m2!3d52.0863804!4d-106.5811565!16s%2Fg%2F1tf_sjhf?entry=ttu&g_ep=EgoyMDI2MDEwNy4wIKXMDSoASAFQAw%3D%3D"
                 target="_blank" rel="noopener noreferrer"
                 class="block text-yellow-100 hover:text-yellow-400 underline whitespace-nowrap"
                 style="font-size: clamp(0.875rem, 0.75rem + 0.3vw, 1.125rem);">
                {{ location }}
              </a>
              <p class="text-yellow-100/70 whitespace-nowrap"
                 style="font-size: clamp(0.75rem, 0.65rem + 0.25vw, 0.875rem);">
                {{ address }}
              </p>
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
      default: ''
    },
    location: {
      type: String,
      default: ''
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

    const iconMonth = computed(() => {
      const d = new Date(props.date)
      if (isNaN(d.getTime())) return 'FEB'
      return d.toLocaleDateString('en-US', { month: 'short' }).toUpperCase()
    })

    const iconDay = computed(() => {
      const d = new Date(props.date)
      if (isNaN(d.getTime())) return '14'
      return d.getDate()
    })

    return {
      formattedDate,
      formattedTime,
      iconMonth,
      iconDay
    }
  }
}
</script>

<style scoped>
.calendar-icon {
  width: 32px;
  height: 32px;
  background: #fff;
  border-radius: 4px;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.3);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.calendar-month {
  background: #e11d48; /* Crimson/Red */
  color: white;
  width: 100%;
  font-size: 8px;
  font-weight: 800;
  text-align: center;
  padding: 1px 0;
  line-height: 1;
}

.calendar-day {
  color: #1a1a1a;
  font-size: 16px;
  font-weight: 800;
  line-height: 1.25;
  margin-top: -1px;
}
</style>
