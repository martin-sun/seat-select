<template>
  <div class="page-indicator">
    <div class="indicator-dots">
      <button
        v-for="(_, index) in total"
        :key="index"
        @click="$emit('navigate', index)"
        class="dot"
        :class="{ active: index === current }"
        :aria-label="`Go to page ${index + 1}`"
      />
    </div>
  </div>
</template>

<script>
export default {
  name: 'PageIndicator',
  props: {
    total: {
      type: Number,
      required: true
    },
    current: {
      type: Number,
      required: true
    }
  },
  emits: ['navigate']
}
</script>

<style scoped>
.page-indicator {
  position: fixed;
  right: 0.5rem;
  top: 50%;
  transform: translateY(-50%);
  z-index: 50;
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.indicator-dots {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  padding: 0.5rem 0.375rem;
  background-color: rgba(127, 29, 29, 0.6);
  border-radius: 9999px;
  border: 1px solid rgba(245, 158, 11, 0.3);
  backdrop-filter: blur(4px);
}

.dot {
  width: 0.375rem;
  height: 0.375rem;
  border-radius: 9999px;
  border: none;
  background-color: rgba(245, 158, 11, 0.3);
  cursor: pointer;
  transition: all 0.3s ease;
  padding: 0;
}

.dot:hover {
  background-color: rgba(245, 158, 11, 0.6);
}

.dot.active {
  background-color: #fbbf24;
  box-shadow: 0 0 8px rgba(245, 158, 11, 0.6);
  transform: scale(1.2);
}

@media (max-width: 375px) {
  .page-indicator {
    right: 0.25rem;
    gap: 0.25rem;
  }

  .indicator-dots {
    padding: 0.375rem 0.25rem;
    gap: 0.25rem;
  }

  .dot {
    width: 0.3125rem;
    height: 0.3125rem;
  }
}
</style>
