<template>
  <button
    @click="toggleLang"
    class="lang-btn"
    :title="currentLocale === 'zh-CN' ? 'Switch to English' : '切换中文'"
  >
    <span v-if="currentLocale === 'zh-CN'">EN</span>
    <span v-else>中</span>
  </button>
</template>

<script>
import { getCurrentLocale } from '@/i18n'

export default {
  name: 'LanguageSwitcher',
  data () {
    return {
      currentLocale: getCurrentLocale()
    }
  },
  methods: {
    toggleLang () {
      const newLang = this.currentLocale === 'zh-CN' ? 'en' : 'zh'
      const currentPath = this.$route.fullPath
      // 替换 URL 中的语言前缀
      const newPath = currentPath.replace(/^\/(zh|en)/, `/${newLang}`)
      this.$router.push(newPath)
      // locale 会由路由守卫自动更新
      this.currentLocale = newLang === 'zh' ? 'zh-CN' : 'en-US'
    }
  }
}
</script>

<style scoped>
.lang-btn {
  @apply w-8 h-8 rounded-full bg-white/20 hover:bg-white/30
         text-white text-sm font-medium flex items-center justify-center
         transition-colors;
}
</style>
