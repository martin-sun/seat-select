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
export default {
  name: 'LanguageSwitcher',
  computed: {
    currentLocale () {
      // Reactive: automatically updates when i18n locale changes
      return this.$i18n.locale
    }
  },
  methods: {
    toggleLang () {
      const newLang = this.currentLocale === 'zh-CN' ? 'en' : 'zh'
      const currentPath = this.$route.fullPath
      // Replace language prefix in URL
      const newPath = currentPath.replace(/^\/(zh|en)/, `/${newLang}`)
      this.$router.push(newPath)
      // Locale will be updated by route guard automatically
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
