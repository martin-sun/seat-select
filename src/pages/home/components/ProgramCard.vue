<template>
  <div class="program-card bg-red-900/50 backdrop-blur-sm rounded-xl border border-red-700/30 overflow-hidden transition-all duration-300 hover:bg-red-800/50 hover:shadow-xl">
    <div class="flex flex-col sm:flex-row">
      <!-- 序号 -->
      <div class="hidden sm:flex items-center justify-center w-16 bg-yellow-500/10 text-yellow-400 text-2xl font-bold">
        {{ String(index).padStart(2, '0') }}
      </div>

      <!-- 内容 -->
      <div class="flex-1 p-4">
        <div class="flex items-start justify-between">
          <div>
            <!-- 移动端序号 -->
            <span class="sm:hidden text-yellow-500 text-sm font-bold mr-2">
              #{{ index }}
            </span>
          </div>
        </div>

        <!-- 标题 -->
        <h3 class="text-yellow-100 font-bold text-lg mt-2">
          {{ program.title }}
        </h3>

        <!-- 表演者 -->
        <p class="text-yellow-400/80 text-sm mt-1">
          {{ $t('chunwan.programs.performers') }}: {{ program.performers }}
        </p>

        <!-- 描述 -->
        <p class="text-yellow-100/60 text-sm mt-2 line-clamp-2">
          {{ program.description }}
        </p>
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
