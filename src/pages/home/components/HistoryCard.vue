<template>
  <div class="history-card group relative overflow-hidden rounded-2xl bg-red-900/50 border border-red-700/30 transition-all duration-300 hover:scale-105 hover:shadow-2xl">
    <!-- 缩略图 -->
    <div class="relative aspect-video overflow-hidden">
      <img
        :src="item.thumbnail"
        :alt="item.title"
        class="w-full h-full object-cover transition-transform duration-300 group-hover:scale-110"
      />
      <!-- 播放按钮遮罩 -->
      <div class="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
        <div class="w-16 h-16 bg-yellow-500/90 rounded-full flex items-center justify-center">
          <span class="text-red-900 text-2xl ml-1">▶</span>
        </div>
      </div>
      <!-- 年份标签 -->
      <div class="absolute top-3 left-3 bg-yellow-500 text-red-900 px-3 py-1 rounded-full text-sm font-bold">
        {{ item.year }}
      </div>
    </div>

    <!-- 信息 -->
    <div class="p-4">
      <h3 class="text-yellow-100 font-semibold text-lg mb-2">
        {{ item.title }}
      </h3>
      <p class="text-yellow-100/60 text-sm">
        {{ $t('chunwan.historyCard.clickToWatch') }}
      </p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'HistoryCard',
  props: {
    item: {
      type: Object,
      required: true
    }
  }
}
</script>

<style scoped>
.history-card {
  box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
}
</style>
