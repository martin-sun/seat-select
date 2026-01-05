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

    <!-- 赞助商板块 -->
    <SponsorSection :sponsors="sponsors" />

    <!-- 主办与协办单位 -->
    <OrganizerSection :items="organizers" />

    <!-- 页脚 -->
    <footer class="bg-red-950 py-12 px-4 border-t border-red-800">
      <div class="max-w-6xl mx-auto text-center">
        <!-- 社交媒体 -->
        <div class="flex justify-center space-x-6 mb-8">
          <a v-if="settings.facebookUrl" :href="settings.facebookUrl" target="_blank" class="text-yellow-100/50 hover:text-yellow-400 transition-colors">
            <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24"><path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/></svg>
          </a>
          <a v-if="settings.twitterUrl" :href="settings.twitterUrl" target="_blank" class="text-yellow-100/50 hover:text-yellow-400 transition-colors">
            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24"><path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/></svg>
          </a>
          <a v-if="settings.youtubeUrl" :href="settings.youtubeUrl" target="_blank" class="text-yellow-100/50 hover:text-yellow-400 transition-colors">
            <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24"><path d="M23.498 6.186a3.016 3.016 0 0 0-2.122-2.136C19.505 3.545 12 3.545 12 3.545s-7.505 0-9.377.505A3.017 3.017 0 0 0 .502 6.186C0 8.07 0 12 0 12s0 3.93.502 5.814a3.016 3.016 0 0 0 2.122 2.136c1.871.505 9.376.505 9.376.505s7.505 0 9.377-.505a3.015 3.015 0 0 0 2.122-2.136C24 15.93 24 12 24 12s0-3.93-.502-5.814zM9.545 15.568V8.432L15.818 12l-6.273 3.568z"/></svg>
          </a>
          <a v-if="settings.instagramUrl" :href="settings.instagramUrl" target="_blank" class="text-yellow-100/50 hover:text-yellow-400 transition-colors">
            <svg class="h-6 w-6" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2.163c3.204 0 3.584.012 4.85.07 3.252.148 4.771 1.691 4.919 4.919.058 1.265.069 1.645.069 4.849 0 3.205-.012 3.584-.069 4.849-.149 3.225-1.664 4.771-4.919 4.919-1.266.058-1.644.07-4.85.07-3.204 0-3.584-.012-4.849-.07-3.26-.149-4.771-1.699-4.919-4.92-.058-1.265-.07-1.644-.07-4.849 0-3.204.013-3.583.07-4.849.149-3.227 1.664-4.771 4.919-4.919 1.266-.057 1.645-.069 4.849-.069zm0-2.163c-3.259 0-3.667.014-4.947.072-4.358.2-6.78 2.618-6.98 6.98-.059 1.281-.073 1.689-.073 4.948 0 3.259.014 3.668.072 4.948.2 4.358 2.618 6.78 6.98 6.98 1.281.058 1.689.072 4.948.072 3.259 0 3.668-.014 4.948-.072 4.354-.2 6.782-2.618 6.979-6.98.059-1.28.073-1.689.073-4.948 0-3.259-.014-3.667-.072-4.947-.196-4.354-2.617-6.78-6.979-6.98-1.281-.059-1.69-.073-4.949-.073zm0 5.838c-3.403 0-6.162 2.759-6.162 6.162s2.759 6.163 6.162 6.163 6.162-2.759 6.162-6.163c0-3.403-2.759-6.162-6.162-6.162zm0 10.162c-2.209 0-4-1.79-4-4 0-2.209 1.791-4 4-4s4 1.791 4 4c0 2.21-1.791 4-4 4zm6.406-11.845c-.796 0-1.441.645-1.441 1.44s.645 1.44 1.441 1.44c.795 0 1.439-.645 1.439-1.44s-.644-1.44-1.439-1.44z"/></svg>
          </a>
        </div>

        <div class="text-yellow-100/70 text-sm space-y-3">
          <p>{{ $t('chunwan.footer.contact', { email: settings.contactEmail }) }}</p>
          <p class="pt-4 border-t border-red-800/30 max-w-xs mx-auto">
            {{ $t('chunwan.footer.organizer', { year: settings.eventYear || '2026' }) }}
          </p>
        </div>
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
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import HeroBanner from './components/HeroBanner.vue'
import EventInfo from './components/EventInfo.vue'
import TicketCard from './components/TicketCard.vue'
import HistoryCard from './components/HistoryCard.vue'
import SponsorSection from './components/SponsorSection.vue'
import OrganizerSection from './components/OrganizerSection.vue'
import { getSettings, getTickets, getHistory, getSponsors, getOrganizers, getAssetUrl } from '@/cms'

export default {
  name: 'ChunwanHome',
  components: {
    HeroBanner,
    EventInfo,
    TicketCard,
    HistoryCard,
    SponsorSection,
    OrganizerSection
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
    const sponsors = ref([])
    const organizers = ref([])

    // 从 Supabase 获取数据
    const fetchData = async () => {
      loading.value = true
      error.value = null
      try {
        const [settingsData, ticketsData, historyData, sponsorsData, organizersData] = await Promise.all([
          getSettings(),
          getTickets(),
          getHistory(),
          getSponsors(),
          getOrganizers()
        ])

        const isEn = lang.value === 'en'

        // 设置数据
        if (settingsData) {
          settings.value = {
            siteTitle: isEn ? (settingsData.site_title_en || settingsData.site_title) : settingsData.site_title,
            eventYear: settingsData.event_year,
            eventTheme: isEn ? (settingsData.event_theme_en || settingsData.event_theme) : settingsData.event_theme,
            eventDate: isEn ? (settingsData.event_date_en || settingsData.event_date) : settingsData.event_date,
            eventLocation: isEn ? (settingsData.event_location_en || settingsData.event_location) : settingsData.event_location,
            eventAddress: isEn ? (settingsData.event_address_en || settingsData.event_address) : settingsData.event_address,
            bannerTitle: isEn ? (settingsData.banner_title_en || settingsData.banner_title) : settingsData.banner_title,
            bannerSubtitle: isEn ? (settingsData.banner_subtitle_en || settingsData.banner_subtitle) : settingsData.banner_subtitle,
            aboutContent: isEn ? (settingsData.about_content_en || settingsData.about_content) : settingsData.about_content,
            showProgramsLink: settingsData.show_programs_link || false,
            bannerImage: getAssetUrl(settingsData.banner_image),
            contactEmail: settingsData.contact_email || 'saskatoonsfc@gmail.com',
            facebookUrl: settingsData.facebook_url,
            twitterUrl: settingsData.twitter_url,
            youtubeUrl: settingsData.youtube_url,
            instagramUrl: settingsData.instagram_url
          }
        }

        // 票价数据
        if (ticketsData) {
          tickets.value = ticketsData.map(ticket => ({
            ...ticket,
            name: isEn ? (ticket.name_en || ticket.name) : ticket.name,
            description: isEn ? (ticket.description_en || ticket.description) : ticket.description
          }))
        }

        // 往期回顾数据
        if (historyData) {
          history.value = historyData.map(item => ({
            ...item,
            title: isEn ? (item.title_en || item.title) : item.title,
            thumbnail: getAssetUrl(item.thumbnail)
          }))
        }

        // 赞助商数据
        if (sponsorsData) {
          sponsors.value = sponsorsData.map(sponsor => ({
            ...sponsor,
            name: isEn ? (sponsor.name_en || sponsor.name) : sponsor.name
          }))
        }

        // 主办单位数据
        if (organizersData) {
          organizers.value = organizersData.map(org => ({
            ...org,
            name: isEn ? (org.name_en || org.name) : org.name,
            description: isEn ? (org.description_en || org.description) : org.description
          }))
        }
      } catch (err) {
        error.value = err.message
      } finally {
        loading.value = false
      }
    }

    // 监听语言或标题变化，更新网页标题
    watch([() => locale.value, () => settings.value.siteTitle], () => {
      const zhTitle = "2026年RBC新春之夜萨斯卡通春晚"
      const enTitle = "2026 RBC New Year Night - Saskatoon Spring Festival Gala"
      document.title = `${zhTitle} | ${enTitle}`
    }, { immediate: true })

    onMounted(() => {
      fetchData()
    })

    // 监听语言变化，重新获取数据以应用正确的字段映射
    watch(lang, () => {
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
      sponsors,
      organizers,
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
