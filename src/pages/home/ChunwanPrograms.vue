<template>
  <div class="chunwan-programs min-h-screen bg-gradient-to-b from-red-900 via-red-800 to-red-900">
    <!-- 导航栏 -->
    <nav class="sticky top-0 z-50 bg-red-900/95 backdrop-blur-sm border-b border-red-700/50">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex items-center justify-between h-16">
          <router-link :to="`/${lang}`" class="flex items-center space-x-2">
            <span class="text-2xl">🏮</span>
            <span class="text-xl font-bold text-yellow-400">{{ $t('chunwan.nav.title') }}</span>
          </router-link>
          <router-link
            :to="`/${lang}`"
            class="text-yellow-100 hover:text-yellow-400 transition-colors flex items-center space-x-1"
          >
            <span>←</span>
            <span>{{ $t('common.back') }}</span>
          </router-link>
        </div>
      </div>
    </nav>

    <!-- 页面标题 -->
    <header class="py-12 px-4 text-center">
      <div class="inline-block mb-4">
        <span class="bg-yellow-500 text-red-900 px-4 py-1 rounded-full text-sm font-bold">
          {{ settings.eventYear }} {{ $t('chunwan.programs.liveNow') }}
        </span>
      </div>
      <h1 class="text-3xl md:text-4xl lg:text-5xl font-bold text-yellow-400 mb-4">
        {{ $t('chunwan.programs.title') }}
      </h1>
      <p class="text-yellow-100/80 text-lg">
        {{ $t('chunwan.programs.subtitle') }}
      </p>
    </header>

    <!-- 节目类型筛选 -->
    <section class="px-4 mb-8">
      <div class="max-w-4xl mx-auto flex flex-wrap justify-center gap-3">
        <button
          v-for="type in programTypes"
          :key="type.value"
          @click="activeType = type.value"
          :class="[
            'px-4 py-2 rounded-full text-sm font-medium transition-all',
            activeType === type.value
              ? 'bg-yellow-500 text-red-900'
              : 'bg-red-800/50 text-yellow-100 hover:bg-red-700/50'
          ]"
        >
          {{ type.label }}
        </button>
      </div>
    </section>

    <!-- 节目列表 -->
    <section class="px-4 pb-12">
      <div class="max-w-4xl mx-auto space-y-4">
        <ProgramCard
          v-for="(program, index) in filteredPrograms"
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
import { useI18n } from 'vue-i18n'
import ProgramCard from './components/ProgramCard.vue'
import { getPrograms, getSettings, getAssetUrl } from '@/cms'

export default {
  name: 'ChunwanPrograms',
  components: {
    ProgramCard
  },
  setup() {
    const route = useRoute()
    const { t } = useI18n()

    const lang = computed(() => route.params.lang || 'zh')
    const loading = ref(true)
    const error = ref(null)

    const settings = ref({})
    const programs = ref([])
    const activeType = ref('all')

    const programTypes = computed(() => [
      { value: 'all', label: t('chunwan.programs.types.all') },
      { value: 'song', label: t('chunwan.programs.types.song') },
      { value: 'dance', label: t('chunwan.programs.types.dance') },
      { value: 'skit', label: t('chunwan.programs.types.skit') },
      { value: 'opera', label: t('chunwan.programs.types.opera') },
      { value: 'acrobatics', label: t('chunwan.programs.types.acrobatics') }
    ])

    // 从 Supabase 获取数据
    const fetchData = async () => {
      loading.value = true
      error.value = null
      try {
        const [programsData, settingsData] = await Promise.all([
          getPrograms(),
          getSettings()
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
            eventYear: settingsData.event_year
          }
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

    // 监听语言变化，重新获取数据以应用正确的字段映射
    watch(lang, () => {
      fetchData()
    })

    const filteredPrograms = computed(() => {
      if (activeType.value === 'all') {
        return programs.value
      }
      return programs.value.filter(p => p.type === activeType.value)
    })

    return {
      lang,
      loading,
      error,
      settings,
      activeType,
      programTypes,
      filteredPrograms
    }
  }
}
</script>
