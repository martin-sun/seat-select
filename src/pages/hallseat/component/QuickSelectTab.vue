/*
  @author zenghao0219
  @description 用于快速选座逻辑实现
  @updateDate 最后更新时间为:2019-07-22
*/
<template>
  <div class='fixed z-10 bottom-12 md:bottom-14 left-0 right-0 bg-white py-3 md:py-4 pl-3 md:pl-4 h-auto overflow-hidden'>
    <div class="text-sm md:text-base font-normal mb-2">{{ $t('quickSelect.title') }}</div>
    <div class="scroll relative h-16 md:h-20 w-full overflow-hidden" ref="scroll">
      <ul class="scroll-ul flex">
        <li class="scroll-item flex-none ml-3 md:ml-4 h-8 md:h-10 leading-8 md:leading-10 text-center text-xs md:text-sm px-3 md:px-4 text-text-gray border border-text-gray rounded-lg cursor-pointer hover:bg-gray-100" @click="quickSeat(1)">{{ $t('quickSelect.singleSeat') }}</li>
        <li class="scroll-item flex-none ml-3 md:ml-4 h-8 md:h-10 leading-8 md:leading-10 text-center text-xs md:text-sm px-3 md:px-4 text-text-gray border border-text-gray rounded-lg cursor-pointer hover:bg-gray-100" @click="quickSeat(2)">{{ $t('quickSelect.doubleSeat') }}</li>
        <li class="scroll-item flex-none ml-3 md:ml-4 h-8 md:h-10 leading-8 md:leading-10 text-center text-xs md:text-sm px-3 md:px-4 text-text-gray border border-text-gray rounded-lg cursor-pointer hover:bg-gray-100" @click="quickSeat(3)">{{ $t('quickSelect.tripleSeat') }}</li>
        <li class="scroll-item flex-none ml-3 md:ml-4 h-8 md:h-10 leading-8 md:leading-10 text-center text-xs md:text-sm px-3 md:px-4 text-text-gray border border-text-gray rounded-lg cursor-pointer hover:bg-gray-100" @click="quickSeat(4)">{{ $t('quickSelect.quadSeat') }}</li>
      </ul>
    </div>
  </div>
</template>

<script>
// 这里可以导入其他文件（比如：组件，工具js，第三方插件js，json文件，图片文件等等）
// 例如：import 《组件名称》 from '《组件路径》';
import Bscroll from 'better-scroll'
export default {
// import引入的组件需要注入到对象中才能使用
  props: {
    propSeatList: Array
  },
  components: {

  },
  data () {
    // 这里存放数据
    return {
      seatList: this.propSeatList,
      seatMap: {}
    }
  },
  // 监听属性 类似于data概念
  computed: {
    // 取最大横坐标
    xMax: function () {
      let i = 0
      for (let index in this.seatList) {
        if (this.seatList[index].gCol > i) {
          i = this.seatList[index].gCol
        }
      }
      return i
    },
    // 取最大纵坐标
    yMax: function () {
      let i = 0
      for (let index in this.seatList) {
        if (this.seatList[index].gRow > i) {
          i = this.seatList[index].gRow
        }
      }
      return i
    },
    // 优先左侧
    bestX: function () {
      return parseInt(this.xMax / 2) + 1
    },
    // 四舍五入
    bestY: function () {
      // 0.618为黄金分割比例
      return Math.round(this.yMax * 0.618)
    }
  },
  // 监控data中的数据变化
  watch: {
    propSeatList: function () {
      this.seatList = this.propSeatList
      this.creatSeatMap()
    }
  },
  // 方法集合
  methods: {
    // 快速选择座位函数
    quickSeat: function (value) {
      let _self = this
      // 最优座位数组 里面包含了每排的最佳座位组
      let bestSeatList = []
      let bestRowSeat
      for (let i = _self.yMax; i > 0; i--) {
        // bestRowSeat为 gRow 为 i 的的所有座位对象
        bestRowSeat = _self.seatMap[i]
        if (bestRowSeat === undefined) {
          continue
        } else {
          // 找到每排的最佳座位
          let bestSeat = this.seachBestSeatByRow(bestRowSeat, value)
          if (bestSeat != null) {
            bestSeatList.push(bestSeat)
          }
        }
      }
      if (bestSeatList.length <= 0) {
        alert(this.$t('alerts.noSuitableSeat'))
        return
      }
      let bestSeatListIndex = 0
      // 递归每排的最优座位组 找出离中心点最近的最优座位组
      bestSeatList.reduce(function (prev, cur, index) {
        if (Array.isArray(prev)) {
          // 取中心点离 最好坐标 绝对值
          let n = Math.abs((prev[0].gCol + prev[value - 1].gCol) / 2 - _self.bestX)
          let m = Math.abs(prev[0].gRow - _self.bestY)
          // 勾股定理
          prev = Math.sqrt(Math.pow(n, 2) + Math.pow(m, 2))
        }
        // 取中心点离 最好坐标 绝对值
        let x = Math.abs((cur[0].gCol + cur[value - 1].gCol) / 2 - _self.bestX)
        let y = Math.abs(cur[0].gRow - _self.bestY)
        // 勾股定理
        let z = Math.sqrt(Math.pow(x, 2) + Math.pow(y, 2))
        if (z >= prev) {
          return prev
        } else {
          bestSeatListIndex = index
          return z
        }
      })
      // 发送选择事件
      for (const iterator of bestSeatList[bestSeatListIndex]) {
        this.$emit('quickSelect', iterator.orgIndex)
      }
    },
    // 找寻每排的最佳座位数组
    seachBestSeatByRow: function (rowSeatList, value) {
      let effectiveSeatLeft = []
      let effectiveSeatRight = []
      let effectiveSeatMiddle = []
      // 检查居中对齐包含最佳座位的
      effectiveSeatMiddle = this.checkSeatMiddle(rowSeatList, value)
      // 左边检查开始
      effectiveSeatLeft = this.checkSeatWithDirection(rowSeatList, value, '-')
      // 右边检查开始
      effectiveSeatRight = this.checkSeatWithDirection(rowSeatList, value, '+')
      // 如果这排中 包含最佳坐标有座位数满足 返回这批座位数组
      if (effectiveSeatMiddle.length === value) {
        return effectiveSeatMiddle
      }
      // 如果这排中 不包含最佳座位 但是左右两侧都有满足座位数 取离中心点近的方向座位数组
      if (effectiveSeatLeft.length === value && effectiveSeatRight.length === value) {
        return Math.abs(effectiveSeatLeft[0].gCol - this.bestX) > Math.abs(effectiveSeatRight[0].gCol - this.bestX) ? effectiveSeatRight : effectiveSeatLeft
      } else {
        // 否则 返回 左右两侧 某一侧满足的座位数组
        if (effectiveSeatLeft.length === value) {
          return effectiveSeatLeft
        }
        if (effectiveSeatRight.length === value) {
          return effectiveSeatRight
        }
        return null
      }
    },
    // 找到次排是否有快速选择座位数有效的数组 寻找的坐标为 最佳座位根据快速选择座位数 取左右两边正负座位数
    checkSeatMiddle: function (rowSeatList, value) {
      let effectiveSeat = []
      // 从负到整的值动态值
      let activeValue = value > 2 ? value - 2 : value - 1
      if (value === this.xMax) {
        activeValue = activeValue - 1
      } else if (value > this.xMax) {
        // 快速选择座位数 大于影厅横向左边值 直接返回没有有效座位
        return effectiveSeat
      }
      // 最佳座位根据快速选择座位数 取左右两边正负座位数
      for (let j = -activeValue; j <= activeValue; j++) {
        // 确认最佳座位状态
        let iter = rowSeatList.find((el) => (parseInt(el.gCol) === this.bestX + j))
        // 最佳座位
        if (iter === undefined) {
          break
        }
        if (iter.status === 'sold' || iter.status === 'locked') {
          effectiveSeat = []
          continue
        } else {
          let temp = { ...iter }
          // 标记此座位的选择规则是中心规则
          temp.findMethod = '*'
          effectiveSeat.push(temp)
        }
      }
      if (effectiveSeat.length > value) {
        // 最后找出居中座位数组后 由于会有已售和锁定和过道的影响 在数组中 先删除后面的位置值 再删除前面位置值 直到值为value(快速选择座位数)
        for (let i = 0; i < activeValue; i++) {
          effectiveSeat.pop()
          if (effectiveSeat.length === value) {
            break
          }
          effectiveSeat.shift()
          if (effectiveSeat.length === value) {
            break
          }
        }
        } else if (effectiveSeat.length < value) {
        return []
      }
      return effectiveSeat
    },
    // 找到次排是否有快速选择座位数有效的数组
    checkSeatWithDirection: function (rowSeatList, value, direction) {
      let activeValue = value
      // 最多允许过道等于3 由于某些影厅 居中的位置不是座位 存在大部分的过道 导致无法选择到最佳座位
      let roadDistance = 3
      let effectiveSeat = []
      for (let j = 0; j < activeValue; j++) {
        let iter
        if (direction === '-') {
          iter = rowSeatList.find((el) => (parseInt(el.gCol) === this.bestX - j))
        } else if (direction === '+') {
          iter = rowSeatList.find((el) => (parseInt(el.gCol) === this.bestX + j))
        }
        if (iter === undefined) {
          activeValue++
          roadDistance--
          if (roadDistance <= 0) {
            break
          } else {
            continue
          }
        }
        if (iter.status === 'sold' || iter.status === 'locked') {
          activeValue++
          effectiveSeat = []
          continue
        } else {
          let temp = { ...iter }
          temp.findMethod = direction
          effectiveSeat.push(temp)
        }
        }
      return effectiveSeat
    },
    // 根据seatList 生成一个类map的对象 key值为gRow坐标 value值为gRow为key值的数组
    creatSeatMap: function () {
      var obj = {}
      for (let index in this.seatList) {
        let seatRowList = this.seatList[index].gRow
        if (seatRowList in obj) {
          // 原本数组下标
          this.seatList[index].orgIndex = index
          obj[seatRowList].push(this.seatList[index])
        } else {
          let seatArr = []
          // 原本数组下标
          this.seatList[index].orgIndex = index
          seatArr.push(this.seatList[index])
          obj[seatRowList] = seatArr
        }
      }
      this.seatMap = obj
    }
  },
  // 生命周期 - 创建完成（可以访问当前this实例）
  created () {

  },
  // 生命周期 - 挂载完成（可以访问DOM元素）
  mounted () {
    this.$nextTick(() => {
      if (!this.scroll) {
        this.scroll = new Bscroll(this.$refs.scroll, {
          scrollX: true,
          // 忽略竖直方向的滚动
          scrollY: false,
          eventPassthrough: 'vertical'
        })
      } else {
        this.scroll.refresh()
      }
    })
  },
  beforeCreate () {}, // 生命周期 - 创建之前
  beforeMount () {}, // 生命周期 - 挂载之前
  beforeUpdate () {}, // 生命周期 - 更新之前
  updated () {}, // 生命周期 - 更新之后
  beforeUnmount () {}, // 生命周期 - 销毁之前
  unmounted () {}, // 生命周期 - 销毁完成
  activated () {} // 如果页面有keep-alive缓存功能，这个函数会触发
}
</script>
<style scoped>
/* Styles handled by Tailwind classes */
</style>
