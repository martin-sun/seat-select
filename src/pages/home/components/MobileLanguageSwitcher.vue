<template>
  <div class="mobile-language-switcher">
    <button
      @click="switchLanguage"
      class="lang-btn"
      :class="{ active: isMenuOpen }"
    >
      {{ currentLangLabel }}
    </button>
  </div>
</template>

<script>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { setLocale } from '@/i18n'

export default {
  name: 'MobileLanguageSwitcher',
  setup() {
    const route = useRoute()
    const router = useRouter()
    const isMenuOpen = ref(false)

    const currentLang = computed(() => route.params.lang || 'zh')

    const currentLangLabel = computed(() => {
      return currentLang.value === 'zh' ? 'EN' : '中'
    })

    const switchLanguage = () => {
      const newLang = currentLang.value === 'zh' ? 'en' : 'zh'
      const newLocale = newLang === 'zh' ? 'zh-CN' : 'en-US'

      // 设置新的语言
      setLocale(newLocale)

      // 更新路由
      const pathWithoutLang = route.fullPath.replace(`/${currentLang.value}`, '')
      router.push(`/${newLang}${pathWithoutLang}`)
    }

    return {
      isMenuOpen,
      currentLangLabel,
      switchLanguage
    }
  }
}
</script>

<style scoped>
.mobile-language-switcher {
  position: fixed;
  top: max(1rem, env(safe-area-inset-top));
  right: 1.5rem;
  z-index: 100;
}

.lang-btn {
  padding: 0.5rem 1rem;
  background-color: rgba(127, 29, 29, 0.9);
  border: 1px solid #f59e0b;
  border-radius: 9999px;
  color: #fbbf24;
  font-size: 0.875rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  backdrop-filter: blur(8px);
}

.lang-btn:hover {
  background-color: #b91c1c;
  box-shadow: 0 0 15px rgba(245, 158, 11, 0.3);
}

.lang-btn:active {
  transform: scale(0.95);
}
</style>
