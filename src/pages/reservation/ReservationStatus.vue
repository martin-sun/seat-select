<template>
  <div class="reservation-page">
    <!-- 头部 -->
    <header class="header">
      <h1>{{ $t('reservation.title') }}</h1>
    </header>

    <!-- 加载中 -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>{{ $t('common.loading') }}</p>
    </div>

    <!-- 错误状态 -->
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <button @click="loadReservation" class="retry-btn">{{ $t('common.retry') }}</button>
    </div>

    <!-- 预订详情 -->
    <div v-else-if="reservation" class="reservation-content">
      <!-- 状态卡片 -->
      <div :class="['status-card', statusClass]">
        <div class="status-icon">{{ statusIcon }}</div>
        <div class="status-text">{{ statusText }}</div>
        <div v-if="reservation.status === 'pending'" class="countdown">
          <span>{{ $t('reservation.remainingTime') }}</span>
          <span class="countdown-time">{{ countdownText }}</span>
        </div>
      </div>

      <!-- 座位信息 -->
      <div class="info-card">
        <h3>{{ $t('reservation.seatInfo') }}</h3>
        <div class="seats-list">
          <span v-for="seat in seats" :key="seat.id" class="seat-tag">
            {{ formatSeat(seat) }}
          </span>
        </div>
        <div class="total-amount">
          {{ $t('reservation.totalAmount') }}<span class="amount">${{ reservation.total_amount }}</span>
        </div>
      </div>

      <!-- 支付说明 (仅待支付状态显示) -->
      <div v-if="reservation.status === 'pending'" class="payment-card">
        <h3>{{ $t('reservation.paymentInstructions') }}</h3>
        <div class="payment-steps">
          <div class="step">
            <div class="step-num">1</div>
            <div class="step-content">
              <p>{{ $t('reservation.step1') }}</p>
            </div>
          </div>
          <div class="step">
            <div class="step-num">2</div>
            <div class="step-content">
              <p>{{ $t('reservation.step2') }}</p>
            </div>
          </div>
          <div class="step">
            <div class="step-num">3</div>
            <div class="step-content">
              <p>{{ $t('reservation.step3') }}</p>
              <div class="email-box">
                <span class="email">{{ etransferEmail }}</span>
                <button @click="copyEmail" class="copy-btn">{{ $t('common.copy') }}</button>
              </div>
            </div>
          </div>
          <div class="step">
            <div class="step-num">4</div>
            <div class="step-content">
              <p>{{ $t('reservation.step4Amount') }}<strong>${{ reservation.total_amount }}</strong></p>
            </div>
          </div>
          <div class="step">
            <div class="step-num">5</div>
            <div class="step-content">
              <p>{{ $t('reservation.step5Note') }}<strong>{{ reservation.customer_phone }}</strong></p>
            </div>
          </div>
        </div>
        <div class="payment-notice">
          <p>{{ $t('reservation.paymentWaiting') }}</p>
          <p>{{ $t('reservation.contactSupport') }}</p>
        </div>
      </div>

      <!-- 客户信息 -->
      <div class="info-card">
        <h3>{{ $t('reservation.reservationInfo') }}</h3>
        <div class="info-row">
          <span class="label">{{ $t('reservation.bookingId') }}</span>
          <span class="value">{{ reservation.id.substring(0, 8).toUpperCase() }}</span>
        </div>
        <div class="info-row">
          <span class="label">{{ $t('reservation.customerName') }}</span>
          <span class="value">{{ reservation.customer_name }}</span>
        </div>
        <div class="info-row">
          <span class="label">{{ $t('reservation.customerPhone') }}</span>
          <span class="value">{{ reservation.customer_phone }}</span>
        </div>
        <div class="info-row">
          <span class="label">{{ $t('reservation.customerEmail') }}</span>
          <span class="value">{{ reservation.customer_email }}</span>
        </div>
        <div class="info-row">
          <span class="label">{{ $t('reservation.bookingTime') }}</span>
          <span class="value">{{ formatDate(reservation.created_at) }}</span>
        </div>
      </div>

      <!-- 返回按钮 -->
      <div class="actions">
        <button @click="goBack" class="back-btn">{{ $t('reservation.backToSelect') }}</button>
      </div>
    </div>
  </div>
</template>

<script>
import { supabase, getReservation } from '@/supabase'
import { formatSeat } from '@/composables/useSeatFormat'

export default {
  name: 'ReservationStatus',
  data () {
    return {
      reservation: null,
      seats: [],
      loading: true,
      error: null,
      countdown: null,
      countdownInterval: null,
      subscription: null,
      etransferEmail: process.env.VUE_APP_ETRANSFER_EMAIL || 'payment@example.com'
    }
  },
  computed: {
    statusClass () {
      if (!this.reservation) return ''
      const statusMap = {
        pending: 'status-pending',
        paid: 'status-paid',
        expired: 'status-expired',
        cancelled: 'status-cancelled'
      }
      return statusMap[this.reservation.status] || ''
    },
    statusIcon () {
      if (!this.reservation) return ''
      const iconMap = {
        pending: '⏳',
        paid: '✅',
        expired: '⌛',
        cancelled: '❌'
      }
      return iconMap[this.reservation.status] || '❓'
    },
    statusText () {
      if (!this.reservation) return ''
      return this.$t(`status.${this.reservation.status}`) || this.$t('status.unknown')
    },
    countdownText () {
      if (!this.countdown || this.countdown <= 0) return '00:00:00'
      const hours = Math.floor(this.countdown / 3600)
      const minutes = Math.floor((this.countdown % 3600) / 60)
      const seconds = this.countdown % 60
      return `${hours.toString().padStart(2, '0')}:${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
    }
  },
  mounted () {
    this.loadReservation()
  },
  beforeUnmount () {
    if (this.countdownInterval) {
      clearInterval(this.countdownInterval)
    }
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  },
  methods: {
    formatSeat,
    async loadReservation () {
      this.loading = true
      this.error = null

      try {
        const reservationId = this.$route.params.id
        if (!reservationId) {
          throw new Error(this.$t('alerts.reservationNotFound'))
        }

        const reservation = await getReservation(reservationId)
        this.reservation = reservation

        // 提取座位信息
        if (reservation.reservation_seats) {
          this.seats = reservation.reservation_seats.map(rs => rs.seats)
        }

        // 如果是待支付状态，启动倒计时
        if (reservation.status === 'pending') {
          this.startCountdown()
          this.subscribeToUpdates()
        }
      } catch (err) {
        console.error('加载预订失败:', err)
        this.error = err.message || this.$t('alerts.loadFailed')
      } finally {
        this.loading = false
      }
    },
    startCountdown () {
      const expiresAt = new Date(this.reservation.expires_at).getTime()
      const updateCountdown = () => {
        const now = Date.now()
        const remaining = Math.floor((expiresAt - now) / 1000)
        this.countdown = remaining > 0 ? remaining : 0

        if (remaining <= 0) {
          clearInterval(this.countdownInterval)
          // 刷新预订状态
          this.loadReservation()
        }
      }

      updateCountdown()
      this.countdownInterval = setInterval(updateCountdown, 1000)
    },
    subscribeToUpdates () {
      this.subscription = supabase
        .channel(`reservation:${this.reservation.id}`)
        .on(
          'postgres_changes',
          {
            event: 'UPDATE',
            schema: 'public',
            table: 'reservations',
            filter: `id=eq.${this.reservation.id}`
          },
          (payload) => {
            this.reservation = { ...this.reservation, ...payload.new }

            // 如果支付成功，停止倒计时
            if (payload.new.status === 'paid') {
              clearInterval(this.countdownInterval)
            }
          }
        )
        .subscribe()
    },
    formatDate (dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      // Use locale based on current i18n setting
      const locale = this.$i18n.locale === 'zh-CN' ? 'zh-CN' : 'en-US'
      return date.toLocaleString(locale, {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    copyEmail () {
      navigator.clipboard.writeText(this.etransferEmail).then(() => {
        alert(this.$t('alerts.emailCopied'))
      }).catch(() => {
        alert(this.$t('alerts.copyFailed'))
      })
    },
    goBack () {
      const lang = this.$route.params.lang || 'zh'
      this.$router.push(`/${lang}`)
    }
  }
}
</script>

<style scoped>
.reservation-page {
  @apply min-h-screen bg-gray-100;
}

.header {
  @apply bg-gradient-to-r from-primary to-primary-light text-white p-4 text-center;
}

.header h1 {
  @apply text-lg font-bold;
}

.loading-state,
.error-state {
  @apply flex flex-col items-center justify-center p-8 text-gray-500;
}

.spinner {
  @apply w-8 h-8 border-4 border-gray-300 border-t-primary rounded-full animate-spin mb-4;
}

.retry-btn {
  @apply mt-4 px-4 py-2 bg-primary text-white rounded;
}

.reservation-content {
  @apply p-4 space-y-4 max-w-lg mx-auto;
}

.status-card {
  @apply rounded-lg p-6 text-center text-white;
}

.status-pending {
  @apply bg-yellow-500;
}

.status-paid {
  @apply bg-green-500;
}

.status-expired {
  @apply bg-gray-500;
}

.status-cancelled {
  @apply bg-red-500;
}

.status-icon {
  @apply text-4xl mb-2;
}

.status-text {
  @apply text-xl font-bold;
}

.countdown {
  @apply mt-3 text-sm opacity-90;
}

.countdown-time {
  @apply font-mono text-lg font-bold;
}

.info-card,
.payment-card {
  @apply bg-white rounded-lg p-4 shadow;
}

.info-card h3,
.payment-card h3 {
  @apply text-base font-bold mb-3 pb-2 border-b;
}

.seats-list {
  @apply flex flex-wrap gap-2 mb-3;
}

.seat-tag {
  @apply bg-primary text-white px-2 py-1 rounded text-sm;
}

.total-amount {
  @apply text-right pt-2 border-t;
}

.amount {
  @apply text-primary font-bold text-xl;
}

.payment-steps {
  @apply space-y-4;
}

.step {
  @apply flex gap-3;
}

.step-num {
  @apply w-6 h-6 bg-primary text-white rounded-full flex items-center justify-center text-sm flex-shrink-0;
}

.step-content {
  @apply flex-1;
}

.step-content p {
  @apply text-sm text-gray-700;
}

.email-box {
  @apply flex items-center gap-2 mt-1 bg-gray-100 p-2 rounded;
}

.email {
  @apply text-primary font-medium flex-1 break-all;
}

.copy-btn {
  @apply px-2 py-1 bg-primary text-white text-xs rounded;
}

.payment-notice {
  @apply mt-4 p-3 bg-yellow-50 text-yellow-800 text-sm rounded;
}

.payment-notice p {
  @apply mb-1 last:mb-0;
}

.info-row {
  @apply flex justify-between py-2 border-b last:border-0;
}

.label {
  @apply text-gray-500 text-sm;
}

.value {
  @apply text-gray-800 text-sm;
}

.actions {
  @apply pt-4;
}

.back-btn {
  @apply w-full py-3 bg-gray-200 text-gray-700 rounded-lg font-medium;
}
</style>
