<template>
  <div class="header-wrapper bg-gradient-to-r from-primary to-primary-light text-white">
    <div class="flex items-center justify-between px-4 h-11 md:h-14">
      <!-- 左侧返回按钮 -->
      <div class="w-20">
        <button
          v-if="showLeft !== 0"
          @click="$emit('backHandleClick')"
          class="flex items-center text-white"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
          </svg>
        </button>
      </div>

      <!-- 中间标题 -->
      <div class="flex-1 text-center">
        <h1 class="text-base md:text-lg font-bold leading-11 md:leading-14">{{ titleText }}</h1>
      </div>

      <!-- 右侧：语言切换 + 缩放按钮 + 查询订单 -->
      <div class="flex items-center gap-2">
        <!-- 语言切换 -->
        <language-switcher></language-switcher>
        <!-- 缩放按钮 -->
        <div v-if="showZoomControls" class="flex items-center gap-1">
          <button
            @click="$emit('resetView')"
            class="zoom-btn"
            :title="$t('header.resetView')"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 8V4m0 0h4M4 4l5 5m11-1V4m0 0h-4m4 0l-5 5M4 16v4m0 0h4m-4 0l5-5m11 5l-5-5m5 5v-4m0 4h-4"></path>
            </svg>
          </button>
          <button
            @click="$emit('zoomOut')"
            class="zoom-btn"
            :title="$t('header.zoomOut')"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M20 12H4"></path>
            </svg>
          </button>
          <button
            @click="$emit('zoomIn')"
            class="zoom-btn"
            :title="$t('header.zoomIn')"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
            </svg>
          </button>
        </div>
        <!-- 查询订单链接 -->
        <router-link
          :to="`/${$route.params.lang || 'zh'}/my-orders`"
          class="text-sm text-white opacity-90 hover:opacity-100 whitespace-nowrap"
        >
          {{ $t('header.myOrders') }}
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
import LanguageSwitcher from '@/components/LanguageSwitcher.vue'

export default {
  name: 'HeaderView',
  components: {
    LanguageSwitcher
  },
  props: {
    showLeft: {
      type: Number,
      default: 1
    },
    titleText: {
      type: String,
      required: true
    },
    rightText: {
      type: String,
      default: ''
    },
    showZoomControls: {
      type: Boolean,
      default: false
    }
  },
  emits: ['backHandleClick', 'zoomIn', 'zoomOut', 'resetView']
}
</script>

<style scoped>
/* Custom line-height utilities for header */
.leading-11 {
  line-height: 2.75rem;
}
.leading-14 {
  line-height: 3.5rem;
}
@media (min-width: 768px) {
  .md\:leading-11 {
    line-height: 2.75rem;
  }
  .md\:leading-14 {
    line-height: 3.5rem;
  }
}

/* Zoom control buttons */
.zoom-btn {
  @apply flex items-center justify-center w-8 h-8 rounded-full bg-white/20 hover:bg-white/30 active:bg-white/40 transition-colors;
}
</style>
