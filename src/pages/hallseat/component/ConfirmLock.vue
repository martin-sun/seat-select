/*
  @author zenghao0219
  @description 用于选定座位后的检测空位逻辑,和下单逻辑
  @updateDate 最后更新时间为:2019-02-29
*/
<template>
<div class='fixed bottom-0 left-0 right-0 z-10 h-12 md:h-14 bg-gradient-to-r from-primary to-primary-light text-white text-base md:text-lg cursor-pointer flex items-center justify-center gap-4' @click="lockSeat()">
  <span v-if="chPrice > 0" class="font-bold">${{ chPrice }}</span>
  <span>{{ $t('confirmLock.confirmSeat') }}</span>
</div>
</template>

<script>
// 这里可以导入其他文件（比如：组件，工具js，第三方插件js，json文件，图片文件等等）
// 例如：import 《组件名称》 from '《组件路径》';
export default {
  name: 'ConfirmLock',
  components: {},
  props: {
    propSelectedSeat: Array,
    propSeatList: Array
  },
  emits: ['loading', 'showBookingForm'],
  data () {
    // 这里存放数据
    return {
      selectedSeat: this.propSelectedSeat,
      seatList: this.propSeatList,
      isProcessing: false // 防止重复点击
    }
  },
  // 监听属性 类似于data概念
  computed: {
    chPrice () {
      let totalPrice = 0
      let selectedSeat = this.selectedSeat
      for (const iterator of selectedSeat) {
        totalPrice += parseInt(iterator.price)
      }
      return totalPrice
    },
    seatIdList () {
      let seatIdList = []
      let selectedSeat = this.selectedSeat
      for (const iterator of selectedSeat) {
        seatIdList.push(iterator.id)
      }
      return seatIdList
    }
  },
  watch: {
    propSelectedSeat: function () {
      this.selectedSeat = this.propSelectedSeat
    },
    propSeatList: function () {
      this.seatList = this.propSeatList
    }
  },
  // 方法集合
  methods: {
    lockSeat: function () {
      // 防止连点
      if (this.isProcessing) {
        return
      }
      this.isProcessing = true
      // 300ms 后重置，防止长时间锁定
      setTimeout(() => {
        this.isProcessing = false
      }, 300)

      if (this.selectedSeat.length === 0) {
        alert(this.$t('alerts.selectAtLeast'))
        return
      }
      if (this.chPrice === 0) {
        alert(this.$t('alerts.lockFailed'))
        return
      }
      // 允许锁座
      this.createOrder()
    },
    createOrder () {
      // 触发显示预订表单
      this.$emit('showBookingForm', {
        selectedSeats: this.selectedSeat,
        totalPrice: this.chPrice
      })
    }
  },
  // 生命周期 - 创建完成（可以访问当前this实例）
  created () {

  },
  // 生命周期 - 挂载完成（可以访问DOM元素）
  mounted () {

  },
  beforeCreate () {}, // 生命周期 - 创建之前
  beforeMount () {}, // 生命周期 - 挂载之前
  beforeUpdate () {}, // 生命周期 - 更新之前
  // 生命周期 - 更新之后
  updated () {},
  beforeUnmount () {}, // 生命周期 - 销毁之前
  unmounted () {}, // 生命周期 - 销毁完成
  activated () {} // 如果页面有keep-alive缓存功能，这个函数会触发
}
</script>
<style scoped>
/* Styles handled by Tailwind classes */
</style>
