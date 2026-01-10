import { ref, computed, onUnmounted } from 'vue'

const DEFAULT_UNLOCK_DATE = '2026-02-14T18:30:00'

export function useCountdown(initialUnlockDate = null) {
  const countdown = ref(null)
  const countdownInterval = ref(null)
  const targetUnlockDate = ref(initialUnlockDate || DEFAULT_UNLOCK_DATE)

  const isLocked = computed(() => {
    if (countdown.value === null) return false
    return countdown.value > 0
  })

  const updateCountdown = () => {
    const now = new Date()

    // 解析目标时间（假设是数据库时区的时间）
    const targetDate = new Date(targetUnlockDate.value)

    const remaining = Math.floor((targetDate - now) / 1000)
    countdown.value = remaining > 0 ? remaining : 0
  }

  const setUnlockDate = (date) => {
    targetUnlockDate.value = date
    // 如果倒计时正在运行，立即更新
    if (countdownInterval.value) {
      updateCountdown()
    }
  }

  const startCountdown = () => {
    updateCountdown()
    countdownInterval.value = setInterval(updateCountdown, 1000)
  }

  const stopCountdown = () => {
    if (countdownInterval.value) {
      clearInterval(countdownInterval.value)
      countdownInterval.value = null
    }
  }

  onUnmounted(() => {
    stopCountdown()
  })

  return {
    countdown,
    isLocked,
    startCountdown,
    stopCountdown,
    setUnlockDate
  }
}
