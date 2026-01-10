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

      <!-- Step 2: 输入验证码 -->
      <div v-if="step === 'otp-input'" class="step-container">
        <div class="step-card">
          <div class="step-icon success-icon">
            <svg class="w-12 h-12 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
          </div>
          <h2>{{ $t('myOrders.enterOtp') }}</h2>
          <p class="hint">{{ $t('myOrders.otpSentTo') }} <span class="email-display">{{ email }}</span></p>
          <p class="hint check-inbox">{{ $t('myOrders.checkInbox') }}</p>
          <input
            v-model="otpCode"
            type="text"
            maxlength="6"
            :placeholder="$t('myOrders.otpPlaceholder')"
            class="otp-input"
            @keyup.enter="verifyOtp"
            inputmode="numeric"
            pattern="[0-9]*"
          />
          <button
            @click="verifyOtp"
            :disabled="verifying || otpCode.length !== 6"
            class="submit-btn"
          >
            {{ verifying ? $t('myOrders.verifying') : $t('myOrders.verify') }}
          </button>
          <button
            @click="resendOtp"
            :disabled="resendCooldown > 0 || sending"
            class="link-btn resend-btn"
          >
            <template v-if="sending">{{ $t('myOrders.sending') }}</template>
            <template v-else-if="resendCooldown > 0">{{ $t('myOrders.resendCooldown', { time: formattedCooldown }) }}</template>
            <template v-else>{{ $t('myOrders.resend') }}</template>
          </button>
          <button @click="backToEmail" class="link-btn">{{ $t('common.back') }}</button>
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
          >
            <div class="order-header">
              <span class="order-id">#{{ reservation.id.substring(0, 8).toUpperCase() }}</span>
            </div>
            <div class="order-divider"></div>
            <div class="order-status-row">
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
                  {{ formatSeat(rs.seats) }}
                </span>
              </div>
              <!-- 待支付订单显示锁定截止时间 -->
              <div v-if="reservation.status === 'pending' && reservation.expires_at" class="order-expires">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                </svg>
                <span>{{ $t('myOrders.seatLockUntil', { time: formatExpiry(reservation.expires_at) }) }}</span>
              </div>
            </div>
            <div class="order-divider"></div>
            <div class="order-footer-actions">
              <div class="order-info">
                <span class="order-amount">${{ reservation.total_amount }}</span>
                <span class="order-date">{{ formatDate(reservation.created_at) }}</span>
              </div>
              <div class="order-buttons">
                <!-- 取消选座按钮 - 仅待支付状态显示 -->
                <button
                  v-if="reservation.status === 'pending'"
                  @click="showCancelDialog(reservation.id, $event)"
                  class="action-btn cancel-btn"
                >
                  {{ $t('myOrders.cancelSeat') }}
                </button>
                <!-- 查看详情按钮 - 所有状态显示 -->
                <button
                  @click="viewOrder(reservation.id)"
                  class="action-btn detail-btn"
                >
                  {{ $t('myOrders.viewDetails') }}
                </button>
              </div>
            </div>
          </div>
        </div>

        <!-- 订单列表页的返回按钮 -->
        <div v-if="step === 'orders' && !loading && reservations.length > 0" class="bottom-back-btn">
          <button @click="goBack" class="back-action-btn">
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
            </svg>
            {{ $t('common.back') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 取消选座确认对话框 -->
    <ConfirmModal
      :show="cancelDialogVisible"
      type="danger"
      :title="$t('myOrders.cancelConfirm')"
      :message="$t('myOrders.cancelConfirmMessage')"
      :confirm-text="$t('common.confirm')"
      :cancel-text="$t('common.cancel')"
      @confirm="confirmCancel"
      @cancel="closeCancelDialog"
    />
  </div>
</template>

<script>
import { sendAuthOtp, verifyAuthOtp, getReservationsByEmail, signOut, getSession, supabase, cancelReservation } from '@/supabase'
import { formatSeat } from '@/composables/useSeatFormat'
import ConfirmModal from '@/components/ConfirmModal.vue'
import toast from '@/utils/toast'

export default {
  name: 'MyOrders',
  components: {
    ConfirmModal
  },
  data () {
    return {
      step: 'email', // 'email' | 'otp-input' | 'orders'
      email: '',
      otpCode: '',
      reservations: [],
      sending: false,
      verifying: false,
      loading: false,
      error: null,
      resendCooldown: 0, // 倒计时秒数
      cooldownTimer: null, // 定时器引用
      cancelDialogVisible: false,
      cancellingOrderId: null
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
    formatSeat,
    async sendOtp () {
      if (!this.isValidEmail) return

      this.sending = true
      this.error = null
      try {
        const currentLocale = localStorage.getItem('locale') || 'en-US'
        await sendAuthOtp(this.email.trim().toLowerCase(), currentLocale)
        this.step = 'otp-input'
        this.otpCode = ''
        this.startCooldown()
      } catch (err) {
        this.error = err.message || this.$t('alerts.sendLinkFailed')
      } finally {
        this.sending = false
      }
    },
    backToEmail () {
      this.step = 'email'
      this.otpCode = ''
      this.error = null
    },
    async verifyOtp () {
      if (this.otpCode.length !== 6) return

      this.verifying = true
      this.error = null
      try {
        const currentLocale = localStorage.getItem('locale') || 'en-US'
        const result = await verifyAuthOtp(this.email.trim().toLowerCase(), this.otpCode, currentLocale)

        // Sign in with the temporary password
        const { error: signInError } = await supabase.auth.signInWithPassword({
          email: result.email,
          password: result.tempPassword
        })

        if (signInError) {
          throw new Error('Failed to create session: ' + signInError.message)
        }

        await this.loadOrders()
        this.step = 'orders'
      } catch (err) {
        this.error = err.message || this.$t('alerts.verifyOtpFailed')
      } finally {
        this.verifying = false
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
      this.otpCode = ''
      this.reservations = []
      this.resendCooldown = 0
      this.error = null
    },
    viewOrder (id) {
      const lang = this.$route.params.lang || 'zh'
      this.$router.push({ name: 'ReservationStatus', params: { lang, id } })
    },
    goBack () {
      this.$router.back()
    },
    async resendOtp () {
      if (this.resendCooldown > 0 || this.sending) return

      this.sending = true
      this.error = null
      try {
        const currentLocale = localStorage.getItem('locale') || 'en-US'
        await sendAuthOtp(this.email.trim().toLowerCase(), currentLocale)
        this.otpCode = ''
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
    },
    showCancelDialog (reservationId, event) {
      event.stopPropagation()
      this.cancellingOrderId = reservationId
      this.cancelDialogVisible = true
    },
    async confirmCancel () {
      if (!this.cancellingOrderId) return

      try {
        await cancelReservation(this.cancellingOrderId, this.email)
        await this.loadOrders()
        toast.success(this.$t('myOrders.cancelSuccess'))
      } catch (err) {
        console.error('取消选座失败:', err)
        toast.error(this.$t('myOrders.cancelFailed'))
      } finally {
        this.cancelDialogVisible = false
        this.cancellingOrderId = null
      }
    },
    closeCancelDialog () {
      this.cancelDialogVisible = false
      this.cancellingOrderId = null
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

.otp-input {
  @apply w-full p-3 border border-gray-300 rounded-lg text-center text-2xl tracking-widest font-mono mb-4;
}

.otp-input:focus {
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

.email-display {
  @apply font-medium text-primary break-all;
}

.check-inbox {
  @apply text-orange-500;
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
  @apply bg-white rounded-lg p-4 shadow;
}

.order-header {
  @apply flex justify-between items-center;
}

.order-divider {
  @apply border-t border-gray-100 my-3;
}

.order-id {
  @apply text-xs text-gray-500 font-mono;
}

.order-status-row {
  @apply flex items-center;
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
  @apply my-3;
}

.order-event {
  @apply font-medium text-gray-800 mb-2;
}

.order-seats {
  @apply flex flex-wrap gap-1 mb-2;
}

.seat-tag {
  @apply bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded text-xs;
}

.order-expires {
  @apply flex items-center gap-1 text-xs text-yellow-600 bg-yellow-50 px-2 py-1 rounded;
}

.order-footer-actions {
  @apply flex justify-between items-center;
}

.order-info {
  @apply flex flex-col;
}

.order-amount {
  @apply text-primary font-bold text-base;
}

.order-date {
  @apply text-gray-400 text-xs mt-0.5;
}

.order-buttons {
  @apply flex gap-2;
}

.action-btn {
  @apply px-3 py-1.5 rounded-lg text-sm font-medium transition-colors;
}

.cancel-btn {
  @apply border border-red-500 text-red-500 bg-white hover:bg-red-50;
}

.detail-btn {
  @apply bg-primary text-white hover:opacity-90;
}

.bottom-back-btn {
  @apply py-4;
}

.back-action-btn {
  @apply w-full py-3 bg-gray-100 text-gray-700 rounded-lg font-medium flex items-center justify-center gap-2;
}

.back-action-btn:active {
  @apply bg-gray-200;
}
</style>
