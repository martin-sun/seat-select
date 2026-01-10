<template>
  <div class="countdown-container">
    <div class="countdown-card">
      <!-- 装饰图标 -->
      <div class="countdown-icon">🏮</div>

      <!-- 标题 -->
      <h2 class="countdown-title">{{ $t('chunwan.countdown.title') }}</h2>

      <!-- 解锁时间 -->
      <p class="unlock-date">{{ formattedUnlockDate }}</p>

      <!-- 倒计时数字 -->
      <div class="countdown-display">
        <div class="countdown-unit">
          <span class="countdown-number">{{ formattedCountdown.days }}</span>
          <span class="countdown-label">{{ $t('chunwan.countdown.days') }}</span>
        </div>
        <span class="countdown-separator">:</span>
        <div class="countdown-unit">
          <span class="countdown-number">{{ formattedCountdown.hours }}</span>
          <span class="countdown-label">{{ $t('chunwan.countdown.hours') }}</span>
        </div>
        <span class="countdown-separator">:</span>
        <div class="countdown-unit">
          <span class="countdown-number">{{ formattedCountdown.minutes }}</span>
          <span class="countdown-label">{{ $t('chunwan.countdown.minutes') }}</span>
        </div>
        <span class="countdown-separator">:</span>
        <div class="countdown-unit">
          <span class="countdown-number">{{ formattedCountdown.seconds }}</span>
          <span class="countdown-label">{{ $t('chunwan.countdown.seconds') }}</span>
        </div>
      </div>

      <!-- 底部装饰 -->
      <div class="countdown-footer">
        <span>🧧</span>
        <span>🐎</span>
        <span>🏮</span>
      </div>
    </div>
  </div>
</template>

<script>
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'

export default {
  name: 'ProgramCountdown',
  props: {
    countdown: {
      type: Number,
      required: true
    },
    unlockDate: {
      type: String,
      default: null
    }
  },
  setup(props) {
    const { locale } = useI18n()

    const formattedCountdown = computed(() => {
      const totalSeconds = props.countdown

      const days = Math.floor(totalSeconds / 86400)
      const hours = Math.floor((totalSeconds % 86400) / 3600)
      const minutes = Math.floor((totalSeconds % 3600) / 60)
      const seconds = totalSeconds % 60

      return {
        days: days.toString().padStart(2, '0'),
        hours: hours.toString().padStart(2, '0'),
        minutes: minutes.toString().padStart(2, '0'),
        seconds: seconds.toString().padStart(2, '0')
      }
    })

    const formattedUnlockDate = computed(() => {
      if (!props.unlockDate) {
        return locale.value.startsWith('zh')
          ? '解锁时间：2026年2月14日 18:30'
          : 'Unlock Time: February 14, 2026 at 6:30 PM'
      }

      const date = new Date(props.unlockDate)
      const localeStr = locale.value.startsWith('zh') ? 'zh-CN' : 'en-US'

      return locale.value.startsWith('zh')
        ? `解锁时间：${date.toLocaleString(localeStr, { year: 'numeric', month: 'long', day: 'numeric', hour: '2-digit', minute: '2-digit' })}`
        : `Unlock Time: ${date.toLocaleString(localeStr, { year: 'numeric', month: 'long', day: 'numeric', hour: 'numeric', minute: '2-digit' })}`
    })

    return {
      formattedCountdown,
      formattedUnlockDate
    }
  }
}
</script>

<style scoped>
.countdown-container {
  min-height: calc(100vh - 4rem);
  background: linear-gradient(to bottom, #7f1d1d, #991b1b, #7f1d1d);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.countdown-card {
  max-width: 600px;
  width: 100%;
  padding: 3rem 2rem;
  border-radius: 1.5rem;
  border: 2px solid #f59e0b;
  background: linear-gradient(to bottom right, #b91c1c, #7f1d1d);
  box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5);
  text-align: center;
  animation: fadeIn 0.8s ease-out;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: scale(0.95);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.countdown-icon {
  font-size: 4rem;
  margin-bottom: 1rem;
  animation: swing 3s ease-in-out infinite;
}

@keyframes swing {
  0%, 100% {
    transform: rotate(-5deg);
  }
  50% {
    transform: rotate(5deg);
  }
}

.countdown-title {
  font-size: 1.5rem;
  font-weight: 700;
  color: #fbbf24;
  margin-bottom: 1rem;
}

.unlock-date {
  font-size: 1.125rem;
  color: rgba(253, 230, 138, 0.9);
  margin-bottom: 2rem;
}

.countdown-display {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  margin-bottom: 2rem;
}

.countdown-unit {
  display: flex;
  flex-direction: column;
  align-items: center;
  min-width: 80px;
}

.countdown-number {
  font-family: 'Courier New', monospace;
  font-size: 3rem;
  font-weight: 700;
  color: #fbbf24;
  text-shadow: 0 0 20px rgba(245, 158, 11, 0.5);
  line-height: 1;
}

.countdown-label {
  font-size: 0.875rem;
  color: #fcd34d;
  margin-top: 0.5rem;
}

.countdown-separator {
  font-size: 2rem;
  font-weight: 700;
  color: #f59e0b;
  margin: 0 0.5rem;
}

.countdown-footer {
  display: flex;
  justify-content: center;
  gap: 1rem;
  font-size: 2rem;
}

/* 移动端适配 */
@media (max-width: 640px) {
  .countdown-card {
    padding: 2rem 1.5rem;
  }

  .countdown-number {
    font-size: 2rem;
  }

  .countdown-unit {
    min-width: 60px;
  }

  .countdown-separator {
    font-size: 1.5rem;
    margin: 0 0.25rem;
  }
}
</style>
