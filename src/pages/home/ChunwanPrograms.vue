<template>
  <!-- 密码验证对话框 -->
  <div v-if="showPasswordModal" class="password-modal-overlay">
    <div class="password-modal">
      <h2 class="password-title">{{ $t('chunwan.debug.passwordTitle') }}</h2>
      <p class="password-subtitle">{{ $t('chunwan.debug.passwordSubtitle') }}</p>
      <input
        v-model="passwordInput"
        type="password"
        class="password-input"
        :placeholder="$t('chunwan.debug.passwordPlaceholder')"
        @keyup.enter="verifyPassword"
      />
      <p v-if="passwordError" class="password-error">{{ passwordError }}</p>
      <div class="password-buttons">
        <button @click="verifyPassword" class="password-btn password-btn-confirm">
          {{ $t('common.confirm') }}
        </button>
        <button @click="cancelPassword" class="password-btn password-btn-cancel">
          {{ $t('common.cancel') }}
        </button>
      </div>
    </div>
  </div>

  <!-- 加载状态 -->
  <div v-else-if="loading" class="min-h-screen bg-gradient-to-b from-red-900 via-red-800 to-red-900 flex items-center justify-center">
    <div class="text-center">
      <div class="inline-block animate-spin rounded-full h-12 w-12 border-4 border-yellow-400 border-t-transparent mb-4"></div>
      <p class="text-yellow-100 text-lg">{{ $t('common.loading') }}</p>
    </div>
  </div>

  <!-- 倒计时 -->
  <div v-else-if="!isMobile && countdown !== null && isLocked && !debugUnlocked" class="countdown-page">
    <!-- 导航栏 -->
    <nav class="sticky top-0 z-50 bg-red-900/95 backdrop-blur-sm border-b border-red-700/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <router-link :to="`/${lang}`" class="flex items-center space-x-2">
            <span class="text-2xl">🏮</span>
            <span class="text-xl font-bold text-yellow-400">{{ $t('chunwan.nav.title') }}</span>
          </router-link>
          <div class="flex items-center space-x-4">
            <language-switcher />
            <router-link
              :to="`/${lang}`"
              class="text-yellow-100 hover:text-yellow-400 transition-colors flex items-center space-x-1"
            >
              <span>←</span>
              <span>{{ $t('common.back') }}</span>
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <ProgramCountdown :countdown="countdown" :unlock-date="unlockDate" />
  </div>

  <!-- 移动端全屏滚动视图 -->
  <MobilePrograms
    v-else-if="isMobile && programs && programs.length > 0"
    :lang="lang"
    :programs="programs"
    :settings="settings"
    :is-locked="isLocked && !debugUnlocked"
    :countdown="countdown"
    :unlock-date="unlockDate"
  />

  <!-- 桌面端卡片列表视图 -->
  <div v-else class="chunwan-programs min-h-screen bg-gradient-to-b from-red-900 via-red-800 to-red-900">
    <!-- 导航栏 -->
    <nav class="sticky top-0 z-50 bg-red-900/95 backdrop-blur-sm border-b border-red-700/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <router-link :to="`/${lang}`" class="flex items-center space-x-2">
            <span class="text-2xl">🏮</span>
            <span class="text-xl font-bold text-yellow-400">{{ $t('chunwan.nav.title') }}</span>
          </router-link>
          <div class="flex items-center space-x-4">
            <language-switcher />
            <router-link
              :to="`/${lang}`"
              class="text-yellow-100 hover:text-yellow-400 transition-colors flex items-center space-x-1"
            >
              <span>←</span>
              <span>{{ $t('common.back') }}</span>
            </router-link>
          </div>
        </div>
      </div>
    </nav>

    <!-- 页面标题 -->
    <header class="py-16 px-4 text-center">
      <div class="inline-block mb-6">
        <span class="year-badge">
          {{ settings.eventYear }}
        </span>
      </div>
      <h1 class="text-4xl md:text-5xl lg:text-6xl font-bold text-yellow-400 mb-4 brush-font">
        {{ settings.eventTheme }}
      </h1>
      <p class="text-yellow-100/90 text-xl">
        {{ settings.siteTitle }}
      </p>
    </header>

    <!-- 工作人员 -->
    <section class="px-4 pb-12">
      <div class="max-w-4xl mx-auto">
        <div class="staff-card">
          <h2 class="staff-title">{{ $t('chunwan.mobile.staff.title') }}</h2>

          <div class="staff-list">
            <div v-for="(member, index) in $tm('chunwan.mobile.staff.members')" :key="index" class="staff-item">
              <span class="staff-role">{{ member.role }}</span>
              <span class="staff-name">{{ member.names }}</span>
            </div>
          </div>

          <div class="art-directors">
            <h3 class="art-directors-title">{{ $t('chunwan.mobile.staff.artDirection') }}</h3>
            <div class="art-directors-list">
              <div v-for="(director, index) in $tm('chunwan.mobile.staff.artDirectors')" :key="index" class="director-item">
                <span class="director-name">{{ director.name }}</span>
                <span class="director-org"> · {{ director.org }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- 节目列表 -->
    <section class="px-4 pb-12">
      <div class="max-w-4xl mx-auto space-y-4">
        <ProgramCard
          v-for="(program, index) in programs"
          :key="program.id"
          :program="program"
          :index="index + 1"
        />
      </div>
    </section>

    <!-- 返回首页 -->
    <section class="pb-12 text-center">
      <router-link
        :to="`/${lang}`"
        class="inline-flex items-center space-x-2 text-yellow-400 hover:text-yellow-300 transition-colors"
      >
        <span>←</span>
        <span>{{ $t('chunwan.programs.backToHome') }}</span>
      </router-link>
    </section>
  </div>
</template>

<script>
import { ref, computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import ProgramCard from './components/ProgramCard.vue'
import MobilePrograms from './components/MobilePrograms.vue'
import ProgramCountdown from './components/ProgramCountdown.vue'
import LanguageSwitcher from '@/components/LanguageSwitcher.vue'
import { useDevice } from '@/composables/useDevice'
import { useCountdown } from '@/composables/useCountdown'
import { getPrograms, getSettings, getEvent, getAssetUrl } from '@/cms'

export default {
  name: 'ChunwanPrograms',
  components: {
    ProgramCard,
    MobilePrograms,
    ProgramCountdown,
    LanguageSwitcher
  },
  setup() {
    const route = useRoute()
    const { isMobile } = useDevice()
    const { countdown, isLocked, startCountdown, setUnlockDate } = useCountdown()

    const lang = computed(() => route.params.lang || 'zh')
    const loading = ref(true)
    const error = ref(null)

    const settings = ref({})
    const programs = ref([])
    const unlockDate = ref(null)

    // Debug mode
    const DEBUG_PASSWORD = 'chunwan2026'
    const showPasswordModal = ref(false)
    const passwordInput = ref('')
    const passwordError = ref('')
    const debugUnlocked = ref(false)

    // Check if debug mode is requested
    const checkDebugMode = () => {
      const debugParam = route.query.debug
      if (debugParam === 'yes' && !debugUnlocked.value) {
        showPasswordModal.value = true
      }
    }

    const verifyPassword = () => {
      if (passwordInput.value === DEBUG_PASSWORD) {
        debugUnlocked.value = true
        showPasswordModal.value = false
        passwordInput.value = ''
        passwordError.value = ''
      } else {
        passwordError.value = lang.value === 'zh' ? '密码错误' : 'Incorrect password'
        passwordInput.value = ''
      }
    }

    const cancelPassword = () => {
      showPasswordModal.value = false
      passwordInput.value = ''
      passwordError.value = ''
    }

    // 从 Supabase 获取数据
    const fetchData = async () => {
      loading.value = true
      error.value = null
      try {
        const [programsData, settingsData, eventData] = await Promise.all([
          getPrograms(),
          getSettings(),
          getEvent()
        ])

        const isEn = lang.value === 'en'

        if (programsData) {
          programs.value = programsData.map(p => ({
            ...p,
            title: isEn ? (p.title_en || p.title) : p.title,
            performers: isEn ? (p.performers_en || p.performers) : p.performers,
            description: isEn ? (p.description_en || p.description) : p.description,
            thumbnail: getAssetUrl(p.thumbnail)
          }))
        }

        if (settingsData) {
          settings.value = {
            eventYear: settingsData.event_year,
            eventTheme: isEn ? (settingsData.event_theme_en || settingsData.event_theme) : settingsData.event_theme,
            siteTitle: isEn ? (settingsData.site_title_en || settingsData.site_title) : settingsData.site_title
          }
        }

        // 设置倒计时解锁时间为演出时间
        if (eventData?.show_time) {
          unlockDate.value = eventData.show_time
          setUnlockDate(eventData.show_time)
        }
      } catch (err) {
        error.value = err.message
      } finally {
        loading.value = false
      }
    }

    onMounted(() => {
      checkDebugMode()
      startCountdown()
      fetchData()
    })

    // 监听语言变化，重新获取数据以应用正确的字段映射
    watch(lang, () => {
      fetchData()
    })

    return {
      lang,
      loading,
      error,
      settings,
      programs,
      isMobile,
      countdown,
      isLocked,
      unlockDate,
      showPasswordModal,
      passwordInput,
      passwordError,
      debugUnlocked,
      verifyPassword,
      cancelPassword
    }
  }
}
</script>

<style scoped>
/* 毛笔字体 */
.brush-font {
  font-family: 'Ma Shan Zheng', cursive;
}

/* 密码验证对话框 */
.password-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 1rem;
}

.password-modal {
  background: linear-gradient(to bottom right, #b91c1c, #7f1d1d);
  border: 2px solid #f59e0b;
  border-radius: 1rem;
  padding: 2rem;
  max-width: 400px;
  width: 100%;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
}

.password-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fbbf24;
  text-align: center;
  margin-bottom: 0.5rem;
}

.password-subtitle {
  color: rgba(253, 230, 138, 0.9);
  text-align: center;
  margin-bottom: 1.5rem;
  font-size: 0.875rem;
}

.password-input {
  width: 100%;
  padding: 0.75rem 1rem;
  border: 2px solid #f59e0b;
  border-radius: 0.5rem;
  background: rgba(127, 29, 29, 0.5);
  color: #fef3c7;
  font-size: 1rem;
  outline: none;
  transition: border-color 0.2s;
}

.password-input:focus {
  border-color: #fbbf24;
}

.password-input::placeholder {
  color: rgba(253, 230, 138, 0.5);
}

.password-error {
  color: #fecaca;
  text-align: center;
  margin-top: 0.75rem;
  font-size: 0.875rem;
}

.password-buttons {
  display: flex;
  gap: 0.75rem;
  margin-top: 1.5rem;
}

.password-btn {
  flex: 1;
  padding: 0.75rem 1rem;
  border: none;
  border-radius: 0.5rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
}

.password-btn-confirm {
  background: #f59e0b;
  color: #7f1d1d;
}

.password-btn-confirm:hover {
  background: #fbbf24;
}

.password-btn-cancel {
  background: transparent;
  border: 2px solid #f59e0b;
  color: #fbbf24;
}

.password-btn-cancel:hover {
  background: rgba(245, 158, 11, 0.2);
}

/* 年份徽章 */
.year-badge {
  display: inline-block;
  padding: 0.5rem 1.5rem;
  border: 2px solid #f59e0b;
  border-radius: 9999px;
  background-color: rgba(127, 29, 29, 0.8);
  font-size: 1.25rem;
  font-weight: 700;
  color: #fbbf24;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

/* 工作人员卡片 */
.staff-card {
  padding: 2rem;
  border-radius: 1rem;
  border: 2px solid #f59e0b;
  background: linear-gradient(to bottom right, #b91c1c, #7f1d1d);
  box-shadow: 0 10px 25px -5px rgba(0, 0, 0, 0.3);
}

.staff-title {
  margin-bottom: 1.5rem;
  font-size: 2rem;
  font-weight: 700;
  color: #fbbf24;
  text-align: center;
}

.staff-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.staff-item {
  display: flex;
  align-items: baseline;
  gap: 0.5rem;
}

.staff-role {
  flex-shrink: 0;
  font-weight: 600;
  color: #f59e0b;
}

.staff-name {
  color: rgba(254, 243, 199, 0.9);
}

.art-directors {
  padding-top: 1.5rem;
  border-top: 1px solid rgba(245, 158, 11, 0.3);
}

.art-directors-title {
  margin-bottom: 1rem;
  font-size: 1.25rem;
  font-weight: 600;
  color: #fbbf24;
}

.art-directors-list {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 0.75rem;
}

.director-item {
  display: flex;
  align-items: baseline;
}

.director-name {
  font-weight: 500;
  color: #fef3c7;
}

.director-org {
  color: rgba(245, 158, 11, 0.7);
}
</style>
