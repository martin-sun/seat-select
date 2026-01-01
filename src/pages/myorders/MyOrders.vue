<template>
  <div class="myorders-page">
    <!-- 头部 -->
    <header class="header">
      <button @click="goBack" class="back-btn">
        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"></path>
        </svg>
      </button>
      <h1>查询订单</h1>
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
          <h2>输入您的邮箱</h2>
          <p class="hint">请输入预订时使用的 E-transfer 邮箱</p>
          <input
            v-model="email"
            type="email"
            placeholder="your@email.com"
            class="input-field"
            @keyup.enter="sendOtp"
          />
          <button
            @click="sendOtp"
            :disabled="sending || !isValidEmail"
            class="submit-btn"
          >
            {{ sending ? '发送中...' : '获取验证码' }}
          </button>
          <p v-if="error" class="error-msg">{{ error }}</p>
        </div>
      </div>

      <!-- Step 2: OTP 验证 -->
      <div v-if="step === 'otp'" class="step-container">
        <div class="step-card">
          <div class="step-icon">
            <svg class="w-12 h-12 text-primary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
            </svg>
          </div>
          <h2>输入验证码</h2>
          <p class="hint">验证码已发送至 {{ email }}</p>
          <input
            v-model="otpCode"
            type="text"
            maxlength="6"
            placeholder="000000"
            class="input-field otp-input"
            @keyup.enter="verifyCode"
          />
          <button
            @click="verifyCode"
            :disabled="verifying || otpCode.length !== 6"
            class="submit-btn"
          >
            {{ verifying ? '验证中...' : '验证' }}
          </button>
          <button @click="resendOtp" class="link-btn">
            重新发送验证码
          </button>
          <p v-if="error" class="error-msg">{{ error }}</p>
        </div>
      </div>

      <!-- Step 3: 订单列表 -->
      <div v-if="step === 'orders'" class="orders-container">
        <div class="user-info">
          <span>{{ email }}</span>
          <button @click="logout" class="logout-btn">退出</button>
        </div>

        <div v-if="loading" class="loading-state">
          <div class="spinner"></div>
          <p>加载中...</p>
        </div>

        <div v-else-if="reservations.length === 0" class="empty-state">
          <svg class="w-16 h-16 text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
          </svg>
          <p>暂无订单记录</p>
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
                {{ reservation.events?.name || '活动' }}
              </div>
              <div class="order-seats">
                <span v-for="rs in reservation.reservation_seats" :key="rs.seat_id" class="seat-tag">
                  {{ rs.seats?.row }}排{{ rs.seats?.col }}座
                </span>
              </div>
              <div class="order-footer">
                <span class="order-amount">¥{{ reservation.total_amount }}</span>
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
import { sendOtpToEmail, verifyOtp, getReservationsByEmail, signOut, getSession } from '@/supabase'

export default {
  name: 'MyOrders',
  data () {
    return {
      step: 'email', // 'email' | 'otp' | 'orders'
      email: '',
      otpCode: '',
      reservations: [],
      sending: false,
      verifying: false,
      loading: false,
      error: null
    }
  },
  computed: {
    isValidEmail () {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      return emailRegex.test(this.email)
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
        this.step = 'otp'
      } catch (err) {
        this.error = err.message || '发送验证码失败，请稍后重试'
      } finally {
        this.sending = false
      }
    },
    async verifyCode () {
      if (this.otpCode.length !== 6) return

      this.verifying = true
      this.error = null
      try {
        await verifyOtp(this.email, this.otpCode)
        await this.loadOrders()
        this.step = 'orders'
      } catch (err) {
        this.error = '验证码错误或已过期'
      } finally {
        this.verifying = false
      }
    },
    async loadOrders () {
      this.loading = true
      try {
        this.reservations = await getReservationsByEmail(this.email)
      } catch (err) {
        console.error('加载订单失败:', err)
        this.error = '加载订单失败'
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
      this.step = 'email'
      this.email = ''
      this.otpCode = ''
      this.reservations = []
      this.error = null
    },
    viewOrder (id) {
      this.$router.push({ name: 'ReservationStatus', params: { id } })
    },
    goBack () {
      this.$router.push('/')
    },
    resendOtp () {
      this.step = 'email'
      this.otpCode = ''
      this.error = null
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
      const textMap = {
        pending: '待支付',
        paid: '已支付',
        expired: '已过期',
        cancelled: '已取消'
      }
      return textMap[status] || '未知'
    },
    formatDate (dateStr) {
      if (!dateStr) return ''
      const date = new Date(dateStr)
      return date.toLocaleDateString('zh-CN', {
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
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
  @apply font-mono tracking-widest text-2xl;
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
