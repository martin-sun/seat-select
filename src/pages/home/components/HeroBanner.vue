<template>
  <section class="hero-banner relative overflow-hidden">
    <!-- 背景装饰 -->
    <div class="absolute inset-0 bg-gradient-to-b from-red-800 to-red-900">
      <!-- 传统纹样装饰 -->
      <div class="absolute inset-0 opacity-10">
        <div class="absolute top-0 left-0 w-32 h-32 border-4 border-yellow-400 rounded-full -translate-x-1/2 -translate-y-1/2"></div>
        <div class="absolute top-1/4 right-0 w-48 h-48 border-4 border-yellow-400 rounded-full translate-x-1/2"></div>
        <div class="absolute bottom-0 left-1/4 w-24 h-24 border-4 border-yellow-400 rounded-full translate-y-1/2"></div>
      </div>
      <!-- 灯笼装饰 -->
      <div class="absolute top-4 left-8 text-4xl animate-bounce" style="animation-duration: 3s;">🏮</div>
      <div class="absolute top-8 right-12 text-3xl animate-bounce" style="animation-duration: 2.5s; animation-delay: 0.5s;">🏮</div>
      <div class="absolute top-6 left-1/3 text-2xl animate-bounce" style="animation-duration: 2.8s; animation-delay: 0.3s;">🏮</div>
    </div>

    <div class="relative z-10 max-w-4xl mx-auto px-4 py-16 md:py-24 lg:py-32 text-center">
      <!-- 年份标签 -->
      <div class="inline-block mb-6">
        <span class="bg-yellow-500 text-red-900 px-4 py-1 rounded-full text-sm font-bold tracking-wider">
          {{ year }} {{ $t('chunwan.banner.yearLabel') }}
        </span>
      </div>

      <!-- 主标题 -->
      <h1 class="text-3xl md:text-5xl lg:text-6xl font-bold text-yellow-400 mb-4 leading-tight">
        {{ title }}
      </h1>

      <!-- 副标题 -->
      <p class="text-lg md:text-2xl text-yellow-100/90 mb-8">
        {{ subtitle }}
      </p>

      <!-- 装饰分隔线 -->
      <div class="flex items-center justify-center space-x-4 mb-8">
        <span class="w-16 h-0.5 bg-yellow-500/50"></span>
        <span class="text-yellow-500 text-2xl">🐍</span>
        <span class="w-16 h-0.5 bg-yellow-500/50"></span>
      </div>

      <!-- CTA 按钮 -->
      <router-link
        :to="`/${$route.params.lang || 'zh'}/tickets`"
        class="inline-block bg-gradient-to-r from-yellow-500 to-yellow-600 text-red-900 px-10 py-4 rounded-full text-xl font-bold hover:from-yellow-400 hover:to-yellow-500 transition-all shadow-lg hover:shadow-xl transform hover:-translate-y-1"
      >
        {{ $t('chunwan.buyTicket') }}
      </router-link>
    </div>
  </section>
</template>

<script>
export default {
  name: 'HeroBanner',
  props: {
    title: {
      type: String,
      default: ''
    },
    subtitle: {
      type: String,
      default: ''
    },
    year: {
      type: String,
      default: '2025'
    }
  }
}
</script>

<style scoped>
.hero-banner {
  min-height: 60vh;
  display: flex;
  align-items: center;
  justify-content: center;
}

@media (min-width: 768px) {
  .hero-banner {
    min-height: 70vh;
  }
}
</style>
