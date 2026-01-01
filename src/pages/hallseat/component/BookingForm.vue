<template>
  <div v-if="visible" class="booking-overlay" @click.self="close">
    <div class="booking-modal">
      <!-- 头部 -->
      <div class="modal-header">
        <h2 class="text-lg font-bold">确认预订</h2>
        <button @click="close" class="close-btn">&times;</button>
      </div>

      <!-- 座位信息 -->
      <div class="seat-summary">
        <div class="text-sm text-gray-600 mb-2">已选座位：</div>
        <div class="flex flex-wrap gap-2">
          <span v-for="seat in selectedSeats" :key="seat.id" class="seat-tag">
            {{ seat.row }}排{{ seat.col }}座
          </span>
        </div>
        <div class="total-price">
          总计：<span class="text-primary font-bold text-xl">¥{{ totalPrice }}</span>
        </div>
      </div>

      <!-- 表单 -->
      <form @submit.prevent="submitBooking" class="booking-form">
        <div class="form-group">
          <label for="name">称呼 <span class="text-red-500">*</span></label>
          <input
            id="name"
            v-model="form.name"
            type="text"
            placeholder="请输入您的称呼"
            required
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="phone">手机号 <span class="text-red-500">*</span></label>
          <input
            id="phone"
            v-model="form.phone"
            type="tel"
            placeholder="请输入手机号"
            required
            class="form-input"
          />
        </div>

        <div class="form-group">
          <label for="email">E-transfer 邮箱 <span class="text-red-500">*</span></label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            placeholder="用于接收付款确认的邮箱"
            required
            class="form-input"
          />
          <p class="text-xs text-gray-500 mt-1">请确保此邮箱与您发送 E-transfer 的邮箱一致</p>
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
          <span v-if="submitting">提交中...</span>
          <span v-else>确认预订</span>
        </button>
      </form>

      <!-- 提示信息 -->
      <div class="notice">
        <p>预订后请在 <strong>24小时内</strong> 完成 E-transfer 付款</p>
        <p>超时未付款，座位将自动释放</p>
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
        this.error = '请输入您的称呼'
        return
      }
      if (!this.form.phone.trim()) {
        this.error = '请输入手机号'
        return
      }
      if (!this.form.email.trim()) {
        this.error = '请输入邮箱'
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
        this.$router.push({
          name: 'ReservationStatus',
          params: { id: reservation.id }
        })

        this.$emit('success', reservation)
      } catch (err) {
        console.error('预订失败:', err)
        this.error = err.message || '预订失败，请稍后重试'
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
