<template>
  <div v-show="load" class="fixed inset-0 z-50 flex flex-col items-center justify-center bg-black/50 text-white">
      <img src="../assets/images/loading.gif" class="w-12 h-12 md:w-16 md:h-16">
  </div>
</template>

<script>
export default {
  // 显示加载的页面
  name: 'loading',
  data () {
    return {
    }
  },
  props: {
    loadingWord: String,
    load: Boolean
  }
}
</script>

<style scoped>
/* Loading styles handled by Tailwind classes */
</style>
