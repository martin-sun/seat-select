<template>
  <div v-if="visible" class="booking-overlay">
    <div class="booking-modal">
      <!-- 头部 -->
      <div class="modal-header">
        <h2 class="text-lg font-bold">{{ $t('bookingForm.title') }}</h2>
        <button @click="close" class="close-btn">&times;</button>
      </div>

      <!-- 座位信息 -->
      <div class="seat-summary">
        <div class="text-sm text-gray-600 mb-2">{{ $t('bookingForm.selectedSeats') }}</div>
        <div class="flex flex-wrap gap-2">
          <span v-for="seat in selectedSeats" :key="seat.id" class="seat-tag">
            {{ formatSeat(seat) }}
          </span>
        </div>
        <div class="total-price">
          {{ $t('bookingForm.totalAmount') }}<span class="text-primary font-bold text-xl">${{ totalPrice }}</span>
        </div>
      </div>

      <!-- 未支付订单警告卡片 -->
      <div v-if="hasPendingOrder" class="pending-order-alert">
        <div class="alert-icon">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
        </div>
        <div class="alert-content">
          <h4 class="alert-title">{{ $t('alerts.existingPendingOrderTitle') }}</h4>
          <p class="alert-message">{{ $t('alerts.existingPendingOrderHint') }}</p>
        </div>
        <button @click="goToMyOrders" class="alert-action">
          {{ $t('alerts.viewMyOrders') }}
        </button>
      </div>

      <!-- 表单 -->
      <form @submit.prevent="submitBooking" class="booking-form">
        <div class="form-group">
          <label for="name">{{ $t('bookingForm.name') }} <span class="text-red-500">{{ $t('bookingForm.required') }}</span></label>
          <input
            id="name"
            v-model="form.name"
            type="text"
            :placeholder="$t('bookingForm.namePlaceholder')"
            required
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="phone">{{ $t('bookingForm.phone') }} <span class="text-red-500">{{ $t('bookingForm.required') }}</span></label>
          <input
            id="phone"
            v-model="form.phone"
            type="tel"
            :placeholder="$t('bookingForm.phonePlaceholder')"
            required
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="email">{{ $t('bookingForm.email') }} <span class="text-red-500">{{ $t('bookingForm.required') }}</span></label>
          <input
            id="email"
            v-model="form.email"
            @blur="onEmailBlur"
            type="email"
            :placeholder="$t('bookingForm.emailPlaceholder')"
            required
            class="form-input"
          />
          <p class="text-xs text-gray-500 mt-1">{{ $t('bookingForm.emailHint') }}</p>
        </div>

        <div class="form-group">
          <label for="emailConfirm">
            {{ $t('bookingForm.emailConfirm') }}
            <span class="text-red-500">{{ $t('bookingForm.required') }}</span>
          </label>
          <input
            id="emailConfirm"
            v-model="form.emailConfirm"
            type="email"
            :placeholder="$t('bookingForm.emailConfirmPlaceholder')"
            :class="{ 'border-red-500': form.emailConfirm && !emailsMatch }"
            required
            class="form-input"
          />
          <p v-if="form.emailConfirm && !emailsMatch"
             class="text-xs text-red-500 mt-1">
            {{ $t('alerts.emailsNotMatch') }}
          </p>
          <p class="text-xs text-orange-600 mt-2 bg-orange-50 p-2 rounded">
            {{ $t('bookingForm.etransferNotice') }}: {{ form.phone || '__________' }}
          </p>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <!-- 提交按钮 -->
        <button
          type="submit"
          :disabled="submitting || hasPendingOrder"
          class="submit-btn"
        >
          <span v-if="submitting">{{ $t('bookingForm.submitting') }}</span>
          <span v-else>{{ $t('bookingForm.confirmBooking') }}</span>
        </button>
      </form>

      <!-- 提示信息 -->
      <div class="notice">
        <p><strong>{{ $t('bookingForm.paymentNotice1') }}</strong></p>
        <p>{{ $t('bookingForm.paymentNotice2') }}</p>
        <p>{{ $t('bookingForm.paymentNotice3') }}</p>
      </div>

      <!-- 客服联系方式 -->
      <div class="support-contact">
        <p class="support-title">{{ $t('support.contactUs') }}</p>
        <a :href="'tel:' + supportPhone" class="support-phone">
          <svg xmlns="http://www.w3.org/2000/svg" class="h-4 w-4 inline mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
          </svg>
          {{ supportPhone }}
        </a>
        <p class="support-hours">{{ $t('support.hours') }}</p>
      </div>
    </div>
  </div>

  <!-- 确认对话框 -->
  <div v-if="showConfirmDialog" class="confirm-dialog-overlay">
    <div class="confirm-dialog">
      <h3 class="confirm-title">{{ $t('bookingForm.confirmTitle') }}</h3>

      <div class="confirm-info">
        <div class="info-item">
          <span class="info-label">{{ $t('bookingForm.name') }}:</span>
          <span class="info-value">{{ form.name }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">{{ $t('bookingForm.phone') }}:</span>
          <span class="info-value">{{ form.phone }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">{{ $t('bookingForm.email') }}:</span>
          <span class="info-value">{{ form.email }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">{{ $t('bookingForm.totalAmount') }}:</span>
          <span class="info-value">${{ totalPrice }}</span>
        </div>
        <div class="info-item">
          <span class="info-label">{{ $t('bookingForm.selectedSeats') }}:</span>
          <span class="info-value">{{ selectedSeats.map(s => formatSeat(s)).join(', ') }}</span>
        </div>
      </div>

      <div class="confirm-checkbox">
        <label class="checkbox-label">
          <input type="checkbox" v-model="confirmChecked" class="w-4 h-4" style="width: 13px; height: 16px;" />
          <span class="font-semibold text-orange-600">{{ $t('bookingForm.confirmCheckbox') }}</span>
        </label>
      </div>

      <div class="confirm-checkbox">
        <label class="checkbox-label">
          <input type="checkbox" v-model="memoChecked" class="w-4 h-4" style="width: 13px; height: 16px;" />
          <span class="font-semibold text-orange-600">{{ $t('bookingForm.memoNotice') }}: {{ form.phone }}</span>
        </label>
      </div>

      <div class="confirm-actions">
        <button @click="cancelConfirm" class="cancel-btn">
          {{ $t('common.cancel') }}
        </button>
        <button
          @click="finalSubmit"
          :disabled="!confirmChecked || !memoChecked || submitting"
          class="confirm-btn"
        >
          {{ submitting ? $t('bookingForm.submitting') : $t('common.confirm') }}
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { createReservation, sendPaymentInstructions, supabase } from '@/supabase'
import { formatSeat } from '@/composables/useSeatFormat'

// localStorage key for saving form data
const BOOKING_FORM_STORAGE_KEY = 'seatselect_booking_form'

export default {
  name: 'BookingForm',
  props: {
    visible: {
      type: Boolean,
      default: false
    },
    selectedSeats: {
      type: Array,
      default: () => []
    },
    eventId: {
      type: String,
      required: true
    },
    totalPrice: {
      type: Number,
      default: 0
    }
  },
  emits: ['close', 'success'],
  data () {
    return {
      form: {
        name: '',
        phone: '',
        email: '',
        emailConfirm: ''
      },
      submitting: false,
      error: null,
      showConfirmDialog: false,
      confirmChecked: false,
      memoChecked: false,
      hasPendingOrder: false
    }
  },
  computed: {
    // Support phone from environment variable
    supportPhone () {
      return process.env.VUE_APP_SUPPORT_PHONE || '+1-306-XXX-XXXX'
    },
    // Email validation regex
    isValidEmail () {
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
      return emailRegex.test(this.form.email.trim())
    },
    // Phone validation - accepts common formats
    isValidPhone () {
      // Supports: +1234567890, 123-456-7890, (123) 456-7890, 1234567890
      const phoneRegex = /^[\d\s\-+()]{7,20}$/
      return phoneRegex.test(this.form.phone.trim())
    },
    // Check if emails match
    emailsMatch () {
      if (!this.form.email || !this.form.emailConfirm) return true
      return this.form.email.toLowerCase() === this.form.emailConfirm.toLowerCase()
    }
  },
  mounted () {
    // Load saved form data from localStorage (excluding email fields for security)
    this.loadFormData()
  },
  methods: {
    formatSeat,
    // Load form data from localStorage (excluding email fields for security)
    loadFormData () {
      try {
        const saved = localStorage.getItem(BOOKING_FORM_STORAGE_KEY)
        if (saved) {
          const data = JSON.parse(saved)
          if (data.name) this.form.name = data.name
          if (data.phone) this.form.phone = data.phone
          // Intentionally NOT loading email fields for security reasons
        }
      } catch (e) {
        console.error('Failed to load saved form data:', e)
      }
    },
    // Save form data to localStorage (excluding email fields for security)
    saveFormData () {
      try {
        const dataToSave = {
          name: this.form.name,
          phone: this.form.phone
          // Intentionally NOT saving email fields for security reasons
        }
        localStorage.setItem(BOOKING_FORM_STORAGE_KEY, JSON.stringify(dataToSave))
      } catch (e) {
        console.error('Failed to save form data:', e)
      }
    },
    // Clear saved form data from localStorage
    clearSavedFormData () {
      try {
        localStorage.removeItem(BOOKING_FORM_STORAGE_KEY)
      } catch (e) {
        console.error('Failed to clear saved form data:', e)
      }
    },
    goToMyOrders () {
      const lang = this.$route.params.lang || 'en'
      this.$router.push({ name: 'MyOrders', params: { lang } })
    },
    close () {
      this.error = null
      this.$emit('close')
    },
    // Sanitize input to prevent XSS
    sanitizeInput (str) {
      return str
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#x27;')
        .trim()
    },
    // Validate name - letters, spaces, hyphens, apostrophes only
    isValidName (name) {
      const trimmed = name.trim()
      // Allow letters (including unicode), spaces, hyphens, apostrophes, 2-50 chars
      const nameRegex = /^[\p{L}\s\-']{2,50}$/u
      return nameRegex.test(trimmed)
    },
    async checkPendingOrders (email) {
      if (!this.isValidEmail || !email) {
        this.hasPendingOrder = false
        return
      }

      try {
        const { data, error } = await supabase
          .from('reservations')
          .select('id')
          .eq('customer_email', email.trim().toLowerCase())
          .eq('event_id', this.eventId)
          .eq('status', 'pending')
          .gt('expires_at', new Date().toISOString())

        if (error) throw error

        // 只设置状态，不再显示 toast
        this.hasPendingOrder = !!(data && data.length > 0)
      } catch (err) {
        console.error('检查未付款订单失败:', err)
        this.hasPendingOrder = false
      }
    },
    async onEmailBlur () {
      if (this.isValidEmail && this.form.email) {
        await this.checkPendingOrders(this.form.email)
      }
    },
    async submitBooking () {
      // Validate name
      if (!this.form.name.trim()) {
        this.error = this.$t('alerts.enterName')
        return
      }
      if (!this.isValidName(this.form.name)) {
        this.error = this.$t('alerts.invalidName')
        return
      }

      // Validate phone
      if (!this.form.phone.trim()) {
        this.error = this.$t('alerts.enterPhone')
        return
      }
      if (!this.isValidPhone) {
        this.error = this.$t('alerts.invalidPhone')
        return
      }

      // Validate email
      if (!this.form.email.trim()) {
        this.error = this.$t('alerts.enterEmail')
        return
      }
      if (!this.isValidEmail) {
        this.error = this.$t('alerts.invalidEmail')
        return
      }

      // Validate confirmation email
      if (!this.form.emailConfirm.trim()) {
        this.error = this.$t('alerts.enterEmailConfirm')
        return
      }
      if (!this.emailsMatch) {
        this.error = this.$t('alerts.emailsNotMatch')
        return
      }

      // Show confirmation dialog instead of submitting directly
      this.showConfirmDialog = true
    },

    cancelConfirm () {
      this.showConfirmDialog = false
      this.confirmChecked = false
      this.memoChecked = false
    },

    async finalSubmit () {
      this.submitting = true
      this.error = null

      try {
        const seatIds = this.selectedSeats.map(s => s.id)

        // Get current UI language from i18n
        const preferredLanguage = this.$i18n?.locale || 'zh-CN'

        const reservation = await createReservation({
          eventId: this.eventId,
          customerName: this.sanitizeInput(this.form.name),
          customerPhone: this.sanitizeInput(this.form.phone),
          customerEmail: this.form.email.trim().toLowerCase(),
          seatIds,
          totalAmount: this.totalPrice,
          preferredLanguage
        })

        // Clear saved form data after successful booking
        this.clearSavedFormData()

        // Send payment instructions via Edge Function (fire and forget)
        const currentLocale = localStorage.getItem('locale') || 'en-US'
        sendPaymentInstructions(reservation.id, currentLocale).catch(err => {
          console.error('Failed to send payment instructions:', err)
        })

        // Navigate to reservation status page
        const lang = this.$route.params.lang || 'zh'
        this.$router.push({
          name: 'ReservationStatus',
          params: { lang, id: reservation.id }
        })

        this.$emit('success', reservation)
      } catch (err) {
        this.error = err.message || this.$t('alerts.bookingFailed')
        this.showConfirmDialog = false
        this.confirmChecked = false
        this.memoChecked = false
      } finally {
        this.submitting = false
      }
    }
  },
  watch: {
    // Save form data to localStorage when name or phone changes (excluding emails for security)
    'form.name' () {
      this.saveFormData()
    },
    'form.phone' () {
      this.saveFormData()
    },
    visible (val) {
      if (val) {
        // Reset only email fields for security, keep name/phone from localStorage
        this.form.email = ''
        this.form.emailConfirm = ''
        this.error = null
        this.showConfirmDialog = false
        this.confirmChecked = false
        this.memoChecked = false
        this.hasPendingOrder = false
      }
    }
  }
}
</script>

<style scoped>
.booking-overlay {
  @apply fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4;
}

.booking-modal {
  @apply bg-white rounded-lg w-full max-w-md max-h-[90vh] overflow-y-auto;
}

.modal-header {
  @apply flex justify-between items-center p-4 border-b;
}

.close-btn {
  @apply text-2xl text-gray-500 hover:text-gray-700 w-8 h-8 flex items-center justify-center;
}

.seat-summary {
  @apply p-4 bg-gray-50 border-b;
}

.seat-tag {
  @apply bg-primary text-white px-2 py-1 rounded text-sm;
}

.total-price {
  @apply mt-3 text-right;
}

.booking-form {
  @apply p-4 space-y-4;
}

.form-group {
  @apply space-y-1;
}

.form-group label {
  @apply block text-sm font-medium text-gray-700;
}

.form-input {
  @apply w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent;
}

.error-message {
  @apply bg-red-50 text-red-600 p-3 rounded-md text-sm;
}

.submit-btn {
  @apply w-full py-3 bg-gradient-to-r from-primary to-primary-light text-white rounded-md font-medium;
  @apply disabled:opacity-50 disabled:cursor-not-allowed;
  @apply hover:opacity-90 transition-opacity;
}

.notice {
  @apply p-4 bg-yellow-50 text-yellow-800 text-sm border-t;
}

.notice p {
  @apply mb-1 last:mb-0;
}

.support-contact {
  @apply p-4 bg-blue-50 text-blue-900 text-sm border-t;
}

.support-title {
  @apply font-semibold mb-2;
}

.support-phone {
  @apply flex items-center text-primary font-bold text-base hover:underline;
}

.support-hours {
  @apply mt-2 text-xs text-blue-700;
}

.confirm-dialog-overlay {
  @apply fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-[60] p-4;
}

.confirm-dialog {
  @apply bg-white rounded-lg w-full max-w-md p-6;
}

.confirm-title {
  @apply text-lg font-bold mb-4 text-center;
}

.confirm-info {
  @apply bg-gray-50 rounded p-4 mb-4 space-y-2;
}

.info-item {
  @apply flex justify-between;
}

.info-label {
  @apply text-gray-600 text-sm;
}

.info-value {
  @apply font-medium text-sm;
}

.confirm-checkbox {
  @apply mb-4;
}

.checkbox-label {
  @apply flex items-start gap-2 text-sm cursor-pointer;
}

.checkbox-label input[type="checkbox"] {
  @apply mt-1 w-4 h-4 border border-gray-300 rounded text-primary focus:ring-primary;
}

.memo-notice {
  @apply text-xs text-orange-600 mt-2 bg-orange-50 p-2 rounded;
}

.confirm-actions {
  @apply flex gap-3;
}

.cancel-btn {
  @apply flex-1 py-2 border border-gray-300 rounded hover:bg-gray-50;
}

.confirm-btn {
  @apply flex-1 py-2 bg-primary text-white rounded hover:opacity-90 disabled:opacity-50 disabled:cursor-not-allowed;
}

/* 未支付订单警告卡片 */
.pending-order-alert {
  @apply mx-4 mt-4 p-4 bg-amber-50 border-l-4 border-amber-500 rounded-r-lg;
  @apply flex items-start gap-3;
}

.alert-icon {
  @apply flex-shrink-0 text-amber-500 mt-0.5;
}

.alert-content {
  @apply flex-1 min-w-0;
}

.alert-title {
  @apply text-amber-800 font-semibold text-sm mb-1;
}

.alert-message {
  @apply text-amber-700 text-sm;
}

.alert-action {
  @apply flex-shrink-0 px-4 py-2 bg-amber-500 text-white text-sm font-medium rounded;
  @apply hover:bg-amber-600 transition-colors whitespace-nowrap;
}
</style>
