import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import i18n from './i18n'
import './assets/css/tailwind.css'
import './assets/css/custom.css'
import { post, get, patch, put } from './http'
import Vconsole from 'vconsole'

if (process.env.NODE_ENV === 'development') {
  // eslint-disable-next-line no-unused-vars
  let vConsole = new Vconsole()
}

const app = createApp(App)

// 定义全局变量
app.config.globalProperties.$post = post
app.config.globalProperties.$get = get
app.config.globalProperties.$patch = patch
app.config.globalProperties.$put = put

app.use(router)
app.use(i18n)
app.mount('#app')
