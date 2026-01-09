<template>
  <div v-if="visible" class="booking-overlay" @click.self="close">
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
            {{ $t('bookingForm.etransferNotice') }}
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
    </div>
  </div>

  <!-- 确认对话框 -->
  <div v-if="showConfirmDialog" class="confirm-dialog-overlay" @click.self="cancelConfirm">
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
          <input type="checkbox" v-model="confirmChecked" />
          <span>{{ $t('bookingForm.confirmCheckbox') }}</span>
        </label>
        <p class="memo-notice">{{ $t('bookingForm.memoNotice') }}</p>
      </div>

      <div class="confirm-actions">
        <button @click="cancelConfirm" class="cancel-btn">
          {{ $t('common.cancel') }}
        </button>
        <button
          @click="finalSubmit"
          :disabled="!confirmChecked || submitting"
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
import { toast } from '@/utils/toast'
import { formatSeat } from '@/composables/useSeatFormat'

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
      hasPendingOrder: false
    }
  },
  computed: {
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
  methods: {
    formatSeat,
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

        if (data && data.length > 0) {
          this.hasPendingOrder = true
          toast.warning(
            this.$t('alerts.existingPendingOrder'),
            6000
          )
        } else {
          this.hasPendingOrder = false
        }
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
    },

    async finalSubmit () {
      this.submitting = true
      this.error = null

      try {
        const seatIds = this.selectedSeats.map(s => s.id)

        const reservation = await createReservation({
          eventId: this.eventId,
          customerName: this.sanitizeInput(this.form.name),
          customerPhone: this.sanitizeInput(this.form.phone),
          customerEmail: this.form.email.trim().toLowerCase(),
          seatIds,
          totalAmount: this.totalPrice
        })

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
      } finally {
        this.submitting = false
      }
    }
  },
  watch: {
    visible (val) {
      if (val) {
        // Reset form
        this.form = { name: '', phone: '', email: '', emailConfirm: '' }
        this.error = null
        this.showConfirmDialog = false
        this.confirmChecked = false
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
</style>
