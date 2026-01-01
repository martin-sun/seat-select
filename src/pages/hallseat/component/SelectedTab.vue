/*
  @author zenghao0219
  @description 用于座位图左侧浮动展示已选座位
  @updateDate 最后更新时间为:2019-02-20
*/
<template>
  <div class='fixed z-20 right-2 top-16 bg-white/95 shadow-lg rounded-lg p-2 max-w-[140px]'>
    <div class="text-xs font-medium text-gray-600 mb-1 border-b pb-1">已选 ({{selectedSeat.length}})</div>
    <ul class="max-h-[200px] overflow-y-auto">
      <li
        v-for="item in selectedSeat"
        :key="'select'+item.id"
        @click="cancelSelect(item)"
        class="text-xs py-1 px-2 my-1 text-gray-700 bg-gray-100 rounded cursor-pointer hover:bg-red-100 hover:text-red-600 transition-colors flex justify-between items-center"
      >
        <span>{{item.row}}排{{item.col}}座</span>
        <span class="text-gray-400 ml-1">×</span>
      </li>
    </ul>
    <div class="text-xs font-medium text-primary mt-1 pt-1 border-t">
      合计: ${{totalPrice}}
    </div>
  </div>
</template>

<script>
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
    cancelSelect: function (item) {
      this.$emit('cancelSelect', item.orgIndex)
    }
  }
}
</script>
<style scoped>
/* Styles handled by Tailwind classes */
</style>
