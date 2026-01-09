/*
  @author zenghao0219
  @description 用于座位图左侧浮动展示已选座位
  @updateDate 最后更新时间为:2019-02-20
*/
<template>
  <div class='fixed z-20 left-4 top-20 bg-white/95 shadow-lg rounded-xl p-4 w-[180px] md:w-[220px]'>
    <div class="text-sm font-bold text-gray-600 mb-2 border-b pb-2">{{ $t('selectedTab.selected', { count: selectedSeat.length }) }}</div>
    <ul class="max-h-[300px] overflow-y-auto">
      <li
        v-for="item in selectedSeat"
        :key="'select'+item.id"
        @click="cancelSelect(item)"
        class="text-sm py-2 px-3 my-1.5 text-gray-700 bg-gray-50 border border-gray-100 rounded-lg cursor-pointer hover:bg-red-50 hover:text-red-600 hover:border-red-100 transition-all flex justify-between items-center group"
      >
        <span class="font-medium">{{ formatSeat(item) }}</span>
        <span class="text-gray-400 group-hover:text-red-500 transition-colors ml-2 text-lg">×</span>
      </li>
    </ul>
    <div class="text-base font-bold text-primary mt-2 pt-2 border-t flex justify-between items-center">
      <span>{{ $t('common.total') }}:</span>
      <span>${{totalPrice}}</span>
    </div>
  </div>
</template>

<script>
import { formatSeat } from '@/composables/useSeatFormat'

export default {
  components: {},
  props: {
    propSelectedSeat: Array
  },
  data () {
    return {
      selectedSeat: this.propSelectedSeat
    }
  },
  computed: {
    totalPrice () {
      return this.selectedSeat.reduce((sum, item) => sum + parseInt(item.price), 0)
    }
  },
  watch: {
    propSelectedSeat: function () {
      this.selectedSeat = this.propSelectedSeat
    }
  },
  methods: {
    formatSeat,
    cancelSelect: function (item) {
      this.$emit('cancelSelect', item.orgIndex)
    }
  }
}
</script>
<style scoped>
/* Styles handled by Tailwind classes */
</style>
