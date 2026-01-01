import { createI18n } from 'vue-i18n'
import zhCN from './locales/zh-CN.json'
import enUS from './locales/en-US.json'

// 获取存储的语言偏好或使用浏览器语言
function getDefaultLocale () {
  const stored = localStorage.getItem('locale')
  if (stored) return stored

  const browserLang = navigator.language || navigator.userLanguage
  return browserLang.startsWith('zh') ? 'zh-CN' : 'en-US'
}

const i18n = createI18n({
  legacy: true, // 使用 Options API 模式
  globalInjection: true, // 全局注入 $t
  locale: getDefaultLocale(),
  fallbackLocale: 'en-US',
  messages: {
    'zh-CN': zhCN,
    'en-US': enUS
  }
})

export default i18n

// 导出切换语言的辅助函数
export function setLocale (locale) {
  i18n.global.locale = locale
  localStorage.setItem('locale', locale)
  document.documentElement.setAttribute('lang', locale)
}

export function getCurrentLocale () {
  return i18n.global.locale
}
