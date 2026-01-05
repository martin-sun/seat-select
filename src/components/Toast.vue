<template>
  <div class="toast-container" :class="{ 'has-toasts': toasts.length > 0 }">
    <TransitionGroup name="toast">
      <div 
        v-for="toast in toasts" 
        :key="toast.id" 
        class="toast-item" 
        :class="toast.type"
        @click="removeToast(toast.id)"
      >
        <div class="toast-icon">
          <svg v-if="toast.type === 'success'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <svg v-else-if="toast.type === 'error'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
          <svg v-else-if="toast.type === 'warning'" viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <svg v-else viewBox="0 0 24 24" fill="none" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
          </svg>
        </div>
        <div class="toast-message">{{ toast.message }}</div>
      </div>
    </TransitionGroup>
  </div>
</template>

<script>
import { toast } from '@/utils/toast'

export default {
  name: 'Toast',
  computed: {
    toasts() {
      return toast.state.toasts
    }
  },
  methods: {
    removeToast(id) {
      toast.remove(id)
    }
  }
}
</script>

<style scoped>
.toast-container {
  position: fixed;
  top: 24px;
  right: 24px;
  z-index: 9999;
  display: flex;
  flex-direction: column;
  gap: 12px;
  pointer-events: none;
}

.toast-container.has-toasts {
  pointer-events: auto;
}

.toast-item {
  min-width: 280px;
  max-width: 450px;
  padding: 12px 20px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
  cursor: pointer;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
  transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.toast-item.success {
  background: rgba(16, 185, 129, 0.9);
  color: white;
}

.toast-item.error {
  background: rgba(239, 68, 68, 0.9);
  color: white;
}

.toast-item.warning {
  background: rgba(245, 158, 11, 0.9);
  color: white;
}

.toast-item.info {
  background: rgba(59, 130, 246, 0.9);
  color: white;
}

.toast-icon {
  width: 20px;
  height: 20px;
  flex-shrink: 0;
}

.toast-message {
  font-size: 14px;
  font-weight: 500;
  line-height: 1.4;
}

/* Animations */
.toast-enter-active {
  animation: toast-in 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
}

.toast-leave-active {
  animation: toast-out 0.3s ease forwards;
}

@keyframes toast-in {
  from {
    transform: translateX(100%) scale(0.9);
    opacity: 0;
  }
  to {
    transform: translateX(0) scale(1);
    opacity: 1;
  }
}

@keyframes toast-out {
  from {
    transform: translateX(0) scale(1);
    opacity: 1;
  }
  to {
    transform: translateX(100%) scale(0.9);
    opacity: 0;
  }
}
</style>
