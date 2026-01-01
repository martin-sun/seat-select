<template>
<div class='fixed bottom-0 left-0 right-0 z-10 h-12 md:h-14 bg-gradient-to-r from-primary to-primary-light text-white text-base md:text-lg cursor-pointer flex items-center justify-center gap-4' @click="lockSeat()">
  <span v-if="chPrice > 0" class="font-bold">${{ chPrice }}</span>
  <span>{{ $t('confirmLock.confirmSeat') }}</span>
</div>
</template>

<script>
export default {
  name: 'ConfirmLock',
  props: {
    propSelectedSeat: {
      type: Array,
      required: true
    },
    propSeatList: {
      type: Array,
      default: () => []
    }
  },
  emits: ['loading', 'showBookingForm'],
  data () {
    return {
      selectedSeat: this.propSelectedSeat,
      seatList: this.propSeatList,
      isProcessing: false,
      processingTimer: null
    }
  },
  computed: {
    chPrice () {
      return this.selectedSeat.reduce((total, seat) => total + parseInt(seat.price || 0), 0)
    },
    seatIdList () {
      return this.selectedSeat.map(seat => seat.id)
    }
  },
  watch: {
    propSelectedSeat (value) {
      this.selectedSeat = value
    },
    propSeatList (value) {
      this.seatList = value
    }
  },
  methods: {
    lockSeat () {
      // Prevent double-click
      if (this.isProcessing) {
        return
      }
      this.isProcessing = true
      // Clear any existing timer
      if (this.processingTimer) {
        clearTimeout(this.processingTimer)
      }
      // Reset after 300ms
      this.processingTimer = setTimeout(() => {
        this.isProcessing = false
        this.processingTimer = null
      }, 300)

      if (this.selectedSeat.length === 0) {
        alert(this.$t('alerts.selectAtLeast'))
        return
      }
      if (this.chPrice === 0) {
        alert(this.$t('alerts.lockFailed'))
        return
      }
      this.createOrder()
    },
    createOrder () {
      this.$emit('showBookingForm', {
        selectedSeats: this.selectedSeat,
        totalPrice: this.chPrice
      })
    }
  },
  beforeUnmount () {
    if (this.processingTimer) {
      clearTimeout(this.processingTimer)
      this.processingTimer = null
    }
  }
}
</script>
<style scoped>
/* Styles handled by Tailwind classes */
</style>
