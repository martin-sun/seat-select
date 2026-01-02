<template>
  <div class="chunwan-home min-h-screen bg-gradient-to-b from-red-900 via-red-800 to-red-900">
    <!-- 导航栏 -->
    <nav class="sticky top-0 z-50 bg-red-900/95 backdrop-blur-sm border-b border-red-700/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <div class="flex items-center space-x-2">
            <span class="text-2xl">🏮</span>
            <span class="text-xl font-bold text-yellow-400">{{ $t('chunwan.nav.title') }}</span>
          </div>
          <div class="hidden md:flex items-center space-x-6">
            <a href="#about" class="text-yellow-100 hover:text-yellow-400 transition-colors">{{ $t('chunwan.nav.about') }}</a>
            <a href="#tickets" class="text-yellow-100 hover:text-yellow-400 transition-colors">{{ $t('chunwan.nav.tickets') }}</a>
            <a href="#history" class="text-yellow-100 hover:text-yellow-400 transition-colors">{{ $t('chunwan.nav.history') }}</a>
            <router-link
              v-if="settings.showProgramsLink"
              :to="`/${lang}/programs`"
              class="text-yellow-100 hover:text-yellow-400 transition-colors"
            >
              {{ $t('chunwan.nav.programs') }}
            </router-link>
          </div>
          <!-- 语言切换 -->
          <div class="flex items-center space-x-2">
            <button
              @click="switchLocale('zh')"
              :class="['px-2 py-1 rounded text-sm', lang === 'zh' ? 'bg-yellow-500 text-red-900' : 'text-yellow-100']"
            >中</button>
            <button
              @click="switchLocale('en')"
              :class="['px-2 py-1 rounded text-sm', lang === 'en' ? 'bg-yellow-500 text-red-900' : 'text-yellow-100']"
            >EN</button>
          </div>
        </div>
      </div>
    </nav>

    <!-- Hero Banner -->
    <HeroBanner
      :title="settings.bannerTitle"
      :subtitle="settings.bannerSubtitle"
      :year="settings.eventYear"
    />

    <!-- 活动信息 -->
    <EventInfo
      id="about"
      :date="settings.eventDate"
      :location="settings.eventLocation"
      :address="settings.eventAddress"
      :aboutContent="settings.aboutContent"
    />

    <!-- 节目单入口 -->
    <section v-if="settings.showProgramsLink" class="py-8 px-4">
      <div class="max-w-4xl mx-auto text-center">
        <router-link
          :to="`/${lang}/programs`"
          class="inline-flex items-center space-x-2 bg-gradient-to-r from-yellow-500 to-yellow-600 text-red-900 px-8 py-4 rounded-full text-lg font-bold hover:from-yellow-400 hover:to-yellow-500 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-1"
        >
          <span>{{ $t('chunwan.viewPrograms') }}</span>
          <span>→</span>
        </router-link>
      </div>
    </section>

    <!-- 票价信息 -->
    <section id="tickets" class="py-12 px-4">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl font-bold text-center text-yellow-400 mb-8">{{ $t('chunwan.ticketSection.title') }}</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <TicketCard
            v-for="ticket in tickets"
            :key="ticket.id"
            :ticket="ticket"
          />
        </div>
        <div class="text-center mt-8">
          <router-link
            :to="`/${lang}/tickets`"
            class="inline-block bg-gradient-to-r from-yellow-500 to-yellow-600 text-red-900 px-10 py-4 rounded-full text-xl font-bold hover:from-yellow-400 hover:to-yellow-500 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-1"
          >
            {{ $t('chunwan.buyTicket') }}
          </router-link>
        </div>
      </div>
    </section>

    <!-- 往期回顾 -->
    <section id="history" class="py-12 px-4 bg-red-950/50">
      <div class="max-w-6xl mx-auto">
        <h2 class="text-3xl font-bold text-center text-yellow-400 mb-8">{{ $t('chunwan.historySection.title') }}</h2>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <HistoryCard
            v-for="item in history"
            :key="item.id"
            :item="item"
          />
        </div>
      </div>
    </section>

    <!-- 页脚 -->
    <footer class="bg-red-950 py-8 px-4 border-t border-red-800">
      <div class="max-w-6xl mx-auto text-center text-yellow-100/70 text-sm">
        <p>{{ $t('chunwan.footer.organizer') }}</p>
        <p class="mt-2">{{ $t('chunwan.footer.contact') }}</p>
      </div>
    </footer>

    <!-- 移动端固定购票按钮 -->
    <div class="fixed bottom-0 left-0 right-0 p-4 bg-gradient-to-t from-red-900 to-transparent md:hidden">
      <router-link
        :to="`/${lang}/tickets`"
        class="block w-full bg-gradient-to-r from-yellow-500 to-yellow-600 text-red-900 text-center py-4 rounded-full text-lg font-bold shadow-lg"
      >
        {{ $t('chunwan.buyTicket') }}
      </router-link>
    </div>
  </div>
</template>

<script>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import HeroBanner from './components/HeroBanner.vue'
import EventInfo from './components/EventInfo.vue'
import TicketCard from './components/TicketCard.vue'
import HistoryCard from './components/HistoryCard.vue'
import { getSettings, getTickets, getHistory, getAssetUrl } from '@/directus'

export default {
  name: 'ChunwanHome',
  components: {
    HeroBanner,
    EventInfo,
    TicketCard,
    HistoryCard
  },
  setup() {
    const route = useRoute()
    const router = useRouter()
    const { locale } = useI18n()

    const lang = computed(() => route.params.lang || 'zh')
    const loading = ref(true)
    const error = ref(null)

    const settings = ref({})
    const tickets = ref([])
    const history = ref([])

    // 从 Directus 获取数据
    const fetchData = async () => {
      loading.value = true
      error.value = null
      try {
        const [settingsData, ticketsData, historyData] = await Promise.all([
          getSettings(),
          getTickets(),
          getHistory()
        ])

        // 设置数据 - 映射 Directus 字段名
        if (settingsData) {
          settings.value = {
            siteTitle: settingsData.site_title,
            eventYear: settingsData.event_year,
            eventTheme: settingsData.event_theme,
            eventDate: settingsData.event_date,
            eventLocation: settingsData.event_location,
            eventAddress: settingsData.event_address,
            bannerTitle: settingsData.banner_title,
            bannerSubtitle: settingsData.banner_subtitle,
            aboutContent: settingsData.about_content,
            showProgramsLink: settingsData.show_programs_link || false,
            bannerImage: getAssetUrl(settingsData.banner_image)
          }
        }

        // 票价数据
        if (ticketsData) {
          tickets.value = ticketsData
        }

        // 往期回顾数据
        if (historyData) {
          history.value = historyData.map(item => ({
            ...item,
            thumbnail: getAssetUrl(item.thumbnail)
          }))
        }
      } catch (err) {
        error.value = err.message
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      fetchData()
    })

    const switchLocale = (newLang) => {
      const newLocale = newLang === 'zh' ? 'zh-CN' : 'en-US'
      locale.value = newLocale
      localStorage.setItem('locale', newLocale)
      router.push(`/${newLang}`)
    }

    return {
      lang,
      loading,
      error,
      settings,
      tickets,
      history,
      switchLocale
    }
  }
}
</script>

<style scoped>
.chunwan-home {
  padding-bottom: 80px;
}

@media (min-width: 768px) {
  .chunwan-home {
    padding-bottom: 0;
  }
}
</style>
