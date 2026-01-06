<template>
  <Transition name="fade">
    <div v-if="show" class="image-modal-overlay" @click.self="$emit('close')">
      <div class="image-modal-container" @click.self="$emit('close')">
        <div class="image-wrapper relative group">
          <!-- 关闭按钮 -->
          <button 
            class="absolute -top-12 right-0 md:-right-12 text-white hover:text-yellow-400 transition-colors z-50 p-2 focus:outline-none"
            @click="$emit('close')"
          >
            <svg class="w-8 h-8 font-bold" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" />
            </svg>
          </button>

          <!-- 图片本体 -->
          <div class="relative rounded-xl overflow-hidden shadow-2xl bg-black/80 border border-white/10">
            <img 
              :src="imageUrl" 
              alt="Seating Plan"
              class="max-w-full max-h-[85vh] object-contain block mx-auto transition-transform duration-500 hover:scale-[1.02]"
              @click.stop
            />
          </div>
          
          <!-- 底部提示 -->
          <div class="mt-4 text-center">
            <p class="text-yellow-100/60 text-sm font-medium">{{ $t('common.back') }}</p>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script>
export default {
  name: 'ImageModal',
  props: {
    show: {
      type: Boolean,
      required: true
    },
    imageUrl: {
      type: String,
      required: true
    }
  },
  emits: ['close']
}
</script>

<style scoped>
.image-modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.9);
  backdrop-filter: blur(10px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  padding: 20px;
}

.image-modal-container {
  width: 100%;
  max-width: 1100px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}

.image-wrapper {
  max-width: 100%;
}

/* Animations */
.fade-enter-active, .fade-leave-active {
  transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}
.fade-enter-from, .fade-leave-to {
  opacity: 0;
}

.fade-enter-active .image-wrapper {
  animation: zoom-in 0.4s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes zoom-in {
  from { transform: scale(0.9); opacity: 0; }
  to { transform: scale(1); opacity: 1; }
}
</style>
