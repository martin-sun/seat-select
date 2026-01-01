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
            {{ $t('seatArea.row') }} {{ seat.row }} {{ $t('seatArea.seat') }} {{ seat.col }}
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
            type="email"
            :placeholder="$t('bookingForm.emailPlaceholder')"
            required
            class="form-input"
          />
          <p class="text-xs text-gray-500 mt-1">{{ $t('bookingForm.emailHint') }}</p>
        </div>

        <!-- 错误提示 -->
        <div v-if="error" class="error-message">
          {{ error }}
        </div>

        <!-- 提交按钮 -->
        <button
          type="submit"
          :disabled="submitting"
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
      </div>
    </div>
  </div>
</template>

<script>
import { createReservation } from '@/supabase'

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
        email: ''
      },
      submitting: false,
      error: null
    }
  },
  methods: {
    close () {
      this.error = null
      this.$emit('close')
    },
    async submitBooking () {
      // 验证表单
      if (!this.form.name.trim()) {
        this.error = this.$t('alerts.enterName')
        return
      }
      if (!this.form.phone.trim()) {
        this.error = this.$t('alerts.enterPhone')
        return
      }
      if (!this.form.email.trim()) {
        this.error = this.$t('alerts.enterEmail')
        return
      }

      this.submitting = true
      this.error = null

      try {
        const seatIds = this.selectedSeats.map(s => s.id)

        const reservation = await createReservation({
          eventId: this.eventId,
          customerName: this.form.name.trim(),
          customerPhone: this.form.phone.trim(),
          customerEmail: this.form.email.trim(),
          seatIds,
          totalAmount: this.totalPrice
        })

        console.log('预订成功:', reservation)

        // 跳转到预订状态页面
        const lang = this.$route.params.lang || 'zh'
        this.$router.push({
          name: 'ReservationStatus',
          params: { lang, id: reservation.id }
        })

        this.$emit('success', reservation)
      } catch (err) {
        console.error('预订失败:', err)
        this.error = err.message || this.$t('alerts.bookingFailed')
      } finally {
        this.submitting = false
      }
    }
  },
  watch: {
    visible (val) {
      if (val) {
        // 重置表单
        this.form = { name: '', phone: '', email: '' }
        this.error = null
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
</style>
