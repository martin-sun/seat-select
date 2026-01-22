<template>
  <div class="program-card bg-red-900/50 backdrop-blur-sm rounded-xl border border-red-700/30 overflow-hidden transition-all duration-300 hover:bg-red-800/50 hover:shadow-xl">
    <div class="flex flex-col sm:flex-row">
      <!-- 序号 -->
      <div v-if="program.type !== 'prize'" class="hidden sm:flex items-center justify-center w-16 bg-yellow-500/10 text-yellow-400 text-2xl font-bold">
        {{ String(index).padStart(2, '0') }}
      </div>

      <!-- 内容 -->
      <div class="flex-1 p-4" :class="{ 'flex items-center justify-center': program.type === 'prize' }">
        <div class="flex items-start justify-between" :class="{ 'w-full text-center': program.type === 'prize' }">
          <div :class="{ 'w-full': program.type === 'prize' }">
            <!-- 奖品图标 -->
            <div v-if="program.type === 'prize'" class="text-center text-3xl mb-2">🎁</div>

            <!-- 移动端序号 -->
            <span v-if="program.type !== 'prize'" class="sm:hidden text-yellow-500 text-sm font-bold mr-2">
              #{{ index }}
            </span>

            <!-- 标题 -->
            <h3 class="text-yellow-100 font-bold text-lg" :class="{ 'text-center text-xl sm:text-2xl': program.type === 'prize', 'mt-2': program.type !== 'prize' }">
              {{ program.title }}
            </h3>

            <!-- 表演者 -->
            <p class="text-yellow-400/80 text-sm mt-1" :class="{ 'text-center': program.type === 'prize' }">
              {{ program.performers }}
            </p>

            <!-- 描述 -->
            <p class="text-yellow-100/60 text-sm mt-2 line-clamp-2" :class="{ 'text-center': program.type === 'prize' }">
              {{ program.description }}
            </p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ProgramCard',
  props: {
    program: {
      type: Object,
      required: true
    },
    index: {
      type: Number,
      required: true
    }
  },
  setup() {
    return {}
  }
}
</script>

<style scoped>
.line-clamp-2 {
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}
</style>
