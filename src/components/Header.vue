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

      <!-- 右侧查询订单链接 -->
      <div class="w-20 text-right">
        <router-link
          to="/my-orders"
          class="text-sm text-white opacity-90 hover:opacity-100"
        >
          查询订单
        </router-link>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HeaderView',
  props: {
    showLeft: Number,
    titleText: String,
    rightText: String
  },
  data () {
    return {

    }
  },
  methods: {
  }
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
</style>
