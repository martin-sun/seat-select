<template>
  <transition name="fade">
    <div v-show="load" class="loading-overlay">
      <div class="loading-content">
        <div class="premium-spinner"></div>
        <div class="loading-text">{{ loadingWord || $t('common.loading') }}</div>
      </div>
    </div>
  </transition>
</template>

<script>
export default {
  name: 'LoadingArea',
  props: {
    loadingWord: String,
    load: Boolean
  }
}
</script>

<style scoped>
.loading-overlay {
  @apply fixed inset-0 z-[9999] flex flex-col items-center justify-center;
  background: #121212; /* Start with solid background */
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
}

/* Once loaded, we can fade it out */
.loading-overlay[v-show="true"] {
  background: rgba(18, 18, 18, 0.9);
}

.loading-content {
  @apply flex flex-col items-center gap-4;
}

.premium-spinner {
  width: 48px;
  height: 48px;
  border: 3px solid rgba(255, 255, 255, 0.1);
  border-top: 3px solid #ab78ff;
  border-radius: 50%;
  animation: spin 1s cubic-bezier(0.42, 0, 0.58, 1) infinite;
}

.loading-text {
  @apply text-white/90 text-sm font-medium tracking-wider uppercase;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.fade-enter-active, .fade-leave-active {
  transition: opacity 0.4s ease;
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}
</style>
