<template>
  <Transition name="modal">
    <div v-if="show" class="video-modal-overlay" @click.self="$emit('close')">
      <div class="video-modal-container">
        <!-- Close Button -->
        <button class="close-btn" @click="$emit('close')">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>

        <div class="video-wrapper">
          <iframe
            v-if="embedUrl"
            :src="embedUrl"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen
          ></iframe>
          <div v-else class="error-state">
            <p>视频链接格式不正确</p>
          </div>
        </div>
      </div>
    </div>
  </Transition>
</template>

<script>
import { computed } from 'vue'

export default {
  name: 'VideoModal',
  props: {
    show: {
      type: Boolean,
      required: true
    },
    url: {
      type: String,
      default: ''
    }
  },
  emits: ['close'],
  setup(props) {
    const embedUrl = computed(() => {
      if (!props.url) return ''
      
      // YouTube
      let videoId = ''
      if (props.url.includes('youtube.com/watch?v=')) {
        videoId = props.url.split('v=')[1].split('&')[0]
      } else if (props.url.includes('youtu.be/')) {
        videoId = props.url.split('youtu.be/')[1].split('?')[0]
      } else if (props.url.includes('youtube.com/embed/')) {
        videoId = props.url.split('embed/')[1].split('?')[0]
      }

      if (videoId) {
        return `https://www.youtube.com/embed/${videoId}?autoplay=1`
      }

      // If already an embed URL from other sources, return as is if it looks safe
      if (props.url.includes('/embed/')) {
        return props.url
      }

      return '' // Fallback or direct link treatment could be added
    })

    return {
      embedUrl
    }
  }
}
</script>

<style scoped>
.video-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.9);
  backdrop-filter: blur(8px);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.video-modal-container {
  position: relative;
  width: 100%;
  max-width: 1000px;
  background: #000;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.video-wrapper {
  position: relative;
  padding-bottom: 56.25%; /* 16:9 Aspect Ratio */
  height: 0;
}

.video-wrapper iframe {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
}

.close-btn {
  position: absolute;
  top: -48px;
  right: 0;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  border: none;
  background: rgba(255, 255, 255, 0.1);
  color: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: all 0.3s ease;
  z-index: 1010;
}

@media (max-width: 768px) {
  .close-btn {
    top: 12px;
    right: 12px;
    background: rgba(0, 0, 0, 0.5);
  }
}

.close-btn:hover {
  background: #e94560;
  transform: rotate(90deg);
}

.close-btn svg {
  width: 24px;
  height: 24px;
}

.error-state {
  position: absolute;
  inset: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(255, 255, 255, 0.5);
}

/* Modal Transition */
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .video-modal-container {
  transition: transform 0.3s ease-out;
}

.modal-enter-from .video-modal-container {
  transform: scale(0.95);
}
</style>
