<template>
  <div class="myorders-page">
    <!-- 头部 -->
    <header class="header">
      <button @click="goBack" class="back-btn">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
        </svg>
      </button>
      <h1>{{ $t('myOrders.title') }}</h1>
      <div class="spacer"></div>
    </header>

    <div class="content">
      <!-- Step 1: 邮箱输入 -->
      <div v-if="step === 'email'" class="step-container">
        <div class="step-card">
          <div class="step-icon">
            <svg class="w-12 h-12 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"></path>
            </svg>
          </div>
          <h2>{{ $t('myOrders.enterEmail') }}</h2>
          <p class="hint">{{ $t('myOrders.emailHint') }}</p>
          <input
            v-model="email"
            type="email"
            :placeholder="$t('myOrders.emailPlaceholder')"
            class="input-field"
            @keyup.enter="sendOtp"
          />
          <button
            @click="sendOtp"
            :disabled="sending || !isValidEmail"
            class="submit-btn"
          >
            {{ sending ? $t('myOrders.sending') : $t('myOrders.sendLink') }}
          </button>
          <p v-if="error" class="error-msg">{{ error }}</p>
        </div>
      </div>

      <!-- Step 2: 邮件已发送提示 -->
      <div v-if="step === 'email-sent'" class="step-container">
        <div class="step-card">
          <div class="step-icon success-icon">
            <svg class="w-12 h-12 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <h2>{{ $t('myOrders.linkSent') }}</h2>
          <p class="hint">{{ $t('myOrders.emailSentTo', { email: email }) }}</p>
          <div class="email-notice">
            <svg class="w-5 h-5 text-yellow-500 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"></path>
            </svg>
            <span>{{ $t('myOrders.checkInbox') }}</span>
          </div>
          <button
            @click="resendOtp"
            :disabled="resendCooldown > 0 || sending"
            class="submit-btn resend-btn"
          >
            <template v-if="sending">{{ $t('myOrders.sending') }}</template>
            <template v-else-if="resendCooldown > 0">{{ $t('myOrders.resendCooldown', { time: formattedCooldown }) }}</template>
            <template v-else>{{ $t('myOrders.resend') }}</template>
          </button>
          <p v-if="error" class="error-msg">{{ error }}</p>
        </div>
      </div>

      <!-- Step 3: 订单列表 -->
      <div v-if="step === 'orders'" class="orders-container">
        <div class="user-info">
          <span>{{ email }}</span>
          <button @click="logout" class="logout-btn">{{ $t('common.logout') }}</button>
        </div>

        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>{{ $t('common.loading') }}</p>
        </div>

        <div v-else-if="reservations.length === 0" class="empty-state">
          <svg class="w-16 h-16 text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
          </svg>
          <p>{{ $t('myOrders.noOrders') }}</p>
        </div>

        <div v-else class="orders-list">
          <div
            v-for="reservation in reservations"
            :key="reservation.id"
            class="order-card"
            @click="viewOrder(reservation.id)"
          >
            <div class="order-header">
              <span class="order-id">#{{ reservation.id.substring(0, 8).toUpperCase() }}</span>
              <span :class="['order-status', getStatusClass(reservation.status)]">
                {{ getStatusText(reservation.status) }}
              </span>
            </div>
            <div class="order-body">
              <div class="order-event">
                {{ reservation.events?.name || $t('myOrders.event') }}
              </div>
              <div class="order-seats">
                <span v-for="rs in reservation.reservation_seats" :key="rs.seat_id" class="seat-tag">
                  {{ rs.seats?.zone }} - {{ $t('seatArea.row') }} {{ rs.seats?.row }} {{ $t('seatArea.seat') }} {{ rs.seats?.col }}
                </span>
              </div>
              <!-- 待支付订单显示锁定截止时间 -->
              <div v-if="reservation.status === 'pending' && reservation.expires_at" class="order-expires">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>{{ $t('myOrders.seatLockUntil', { time: formatExpiry(reservation.expires_at) }) }}</span>
              </div>
              <div class="order-footer">
                <span class="order-amount">${{ reservation.total_amount }}</span>
                <span class="order-date">{{ formatDate(reservation.created_at) }}</span>
              </div>
            </div>
            <div class="order-arrow">
              <svg class="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"></path>
              </svg>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { sendOtpToEmail, getReservationsByEmail, signOut, getSession } from '@/supabase'

export default {
  name: 'MyOrders',
  data () {
    return {
      step: 'email', // 'email' | 'email-sent' | 'orders'
      email: '',
      reservations: [],
      sending: false,
      loading: false,
      error: null,
      resendCooldown: 0, // 倒计时秒数
      cooldownTimer: null // 定时器引用
    }
  },
  computed: {
    isValidEmail () {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      return emailRegex.test(this.email)
    },
    formattedCooldown () {
      const minutes = Math.floor(this.resendCooldown / 60)
      const seconds = this.resendCooldown % 60
      return `${minutes}:${seconds.toString().padStart(2, '0')}`
    }
  },
  beforeUnmount () {
    if (this.cooldownTimer) {
      clearInterval(this.cooldownTimer)
    }
  },
  async mounted () {
    // 检查是否已登录
    try {
      const session = await getSession()
      if (session?.user?.email) {
        this.email = session.user.email
        await this.loadOrders()
        this.step = 'orders'
      }
    } catch (err) {
      console.error('检查登录状态失败:', err)
    }
  },
  methods: {
    async sendOtp () {
      if (!this.isValidEmail) return

      this.sending = true
      this.error = null
      try {
        await sendOtpToEmail(this.email)
        this.step = 'email-sent'
        this.startCooldown()
      } catch (err) {
        this.error = err.message || this.$t('alerts.sendLinkFailed')
      } finally {
        this.sending = false
      }
    },
    startCooldown () {
      this.resendCooldown = 300 // 5分钟 = 300秒
      if (this.cooldownTimer) {
        clearInterval(this.cooldownTimer)
      }
      this.cooldownTimer = setInterval(() => {
        if (this.resendCooldown > 0) {
          this.resendCooldown--
        } else {
          clearInterval(this.cooldownTimer)
          this.cooldownTimer = null
        }
      }, 1000)
    },
    async loadOrders () {
      this.loading = true
      try {
        this.reservations = await getReservationsByEmail(this.email)
      } catch (err) {
        console.error('加载订单失败:', err)
        this.error = this.$t('alerts.loadOrdersFailed')
      } finally {
        this.loading = false
      }
    },
    async logout () {
      try {
        await signOut()
      } catch (err) {
        console.error('退出失败:', err)
      }
      if (this.cooldownTimer) {
        clearInterval(this.cooldownTimer)
        this.cooldownTimer = null
      }
      this.step = 'email'
      this.email = ''
      this.reservations = []
      this.resendCooldown = 0
      this.error = null
    },
    viewOrder (id) {
      const lang = this.$route.params.lang || 'zh'
      this.$router.push({ name: 'ReservationStatus', params: { lang, id } })
    },
    goBack () {
      const lang = this.$route.params.lang || 'zh'
      this.$router.push(`/${lang}`)
    },
    async resendOtp () {
      if (this.resendCooldown > 0 || this.sending) return

      this.sending = true
      this.error = null
      try {
        await sendOtpToEmail(this.email)
        this.startCooldown()
      } catch (err) {
        this.error = err.message || this.$t('alerts.sendLinkFailed')
      } finally {
        this.sending = false
      }
    },
    getStatusClass (status) {
      const classMap = {
        pending: 'status-pending',
        paid: 'status-paid',
        expired: 'status-expired',
        cancelled: 'status-cancelled'
      }
      return classMap[status] || ''
    },
    getStatusText (status) {
      return this.$t(`status.${status}`) || this.$t('status.unknown')
    },
    formatDate (dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      // Use locale based on current i18n setting
      const locale = this.$i18n.locale === 'zh-CN' ? 'zh-CN' : 'en-US'
      return date.toLocaleDateString(locale, {
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    },
    formatExpiry (dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      const now = new Date()
      const diff = date - now

      // 如果已过期
      if (diff <= 0) {
        return this.$t('time.expired')
      }

      // 计算剩余时间
      const hours = Math.floor(diff / (1000 * 60 * 60))
      const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60))

      if (hours > 0) {
        return this.$t('time.hoursMinutesLater', { hours, minutes })
      }
      return this.$t('time.minutesLater', { minutes })
    }
  }
}
</script>

<style scoped>
.myorders-page {
  @apply min-h-screen bg-gray-100;
}

.header {
  @apply bg-gradient-to-r from-primary to-primary-light text-white p-4 flex items-center;
}

.header h1 {
  @apply text-lg font-bold flex-1 text-center;
}

.header .back-btn {
  @apply p-1;
}

.header .spacer {
  @apply w-7;
}

.content {
  @apply p-4 max-w-lg mx-auto;
}

/* Step Card */
.step-container {
  @apply flex items-center justify-center min-h-[60vh];
}

.step-card {
  @apply bg-white rounded-lg p-6 shadow w-full text-center;
}

.step-icon {
  @apply flex justify-center mb-4;
}

.step-card h2 {
  @apply text-xl font-bold mb-2;
}

.step-card .hint {
  @apply text-gray-500 text-sm mb-4;
}

.input-field {
  @apply w-full p-3 border border-gray-300 rounded-lg text-center text-lg mb-4;
}

.input-field:focus {
  @apply outline-none border-primary ring-2 ring-primary ring-opacity-20;
}

.submit-btn {
  @apply w-full py-3 bg-primary text-white rounded-lg font-medium;
}

.submit-btn:disabled {
  @apply bg-gray-300 cursor-not-allowed;
}

.link-btn {
  @apply mt-3 text-primary text-sm;
}

.error-msg {
  @apply mt-3 text-red-500 text-sm;
}

/* Email Sent Notice */
.email-notice {
  @apply flex items-start gap-2 bg-yellow-50 border border-yellow-200 rounded-lg p-3 mb-4 text-sm text-yellow-700 text-left;
}

.resend-btn {
  @apply mt-2;
}

/* Orders List */
.orders-container {
  @apply space-y-4;
}

.user-info {
  @apply bg-white rounded-lg p-4 flex justify-between items-center shadow;
}

.user-info span {
  @apply text-gray-700 font-medium;
}

.logout-btn {
  @apply px-3 py-1 text-sm text-gray-500 border border-gray-300 rounded;
}

.loading-state,
.empty-state {
  @apply flex flex-col items-center justify-center py-16 text-gray-400;
}

.spinner {
  @apply w-8 h-8 border-4 border-gray-300 border-t-primary rounded-full animate-spin mb-4;
}

.orders-list {
  @apply space-y-3;
}

.order-card {
  @apply bg-white rounded-lg p-4 shadow flex items-center cursor-pointer;
}

.order-card:active {
  @apply bg-gray-50;
}

.order-header {
  @apply flex justify-between items-center mb-2;
}

.order-id {
  @apply text-xs text-gray-500 font-mono;
}

.order-status {
  @apply text-xs px-2 py-0.5 rounded;
}

.status-pending {
  @apply bg-yellow-100 text-yellow-700;
}

.status-paid {
  @apply bg-green-100 text-green-700;
}

.status-expired {
  @apply bg-gray-100 text-gray-500;
}

.status-cancelled {
  @apply bg-red-100 text-red-700;
}

.order-body {
  @apply flex-1;
}

.order-event {
  @apply font-medium text-gray-800 mb-1;
}

.order-seats {
  @apply flex flex-wrap gap-1 mb-2;
}

.seat-tag {
  @apply bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded text-xs;
}

.order-expires {
  @apply flex items-center gap-1 text-xs text-yellow-600 bg-yellow-50 px-2 py-1 rounded mb-2;
}

.order-footer {
  @apply flex justify-between items-center text-sm;
}

.order-amount {
  @apply text-primary font-bold;
}

.order-date {
  @apply text-gray-400 text-xs;
}

.order-arrow {
  @apply ml-2;
}
</style>
