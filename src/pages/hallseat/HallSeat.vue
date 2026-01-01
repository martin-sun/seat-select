/*
  @author zenghao0219
  @description 座位页面父级组件,控制点击选座,数据加载处理
  @updateDate 最后更新时间为:2019-04-29
*/
<template>
  <div class="wapper">
    <!--头部 开始-->
    <header-view
      :titleText="$t('header.seatSelection')"
      :showZoomControls="true"
      @backHandleClick="back"
      @zoomIn="handleZoomIn"
      @zoomOut="handleZoomOut"
    ></header-view>
    <!--头部 结束-->
    <seat-area :propThumbnailAreaWidth="thumbnailBoxWidth" :propThumbnailAreaHeight="thumbnailBoxHeight"
    :propYMax="yMax - yMin" :propSeatScale="seatScale" :propSeatHeight="positionDistin" :propSeatToolArr="seatToolArr"
    :propSeatAreaWidthPx="seatAreaWidthPx"
    :propSeatBoxHeight="seatBoxHeight" :propMiddleLine="middleLine" :propHorizontalLine="horizontalLine" ref="seatArea">
      <!--以下为缩略座位图具名插槽 开始-->
      <template #thumbnail-seat-solt>
            <div v-for="seatItem in seatList" :key="'thumbnail'+seatItem.id" class="thumbnailSeatClass" :style="{height:thumbnailHeight +'px',
            width:(thumbnailWidth * (seatItem.width || 1)) +'px',background: thumbnailBackgroud(seatItem),
            top:(yMax - seatItem.gRow) * thumbnailPositionDistin +'px',left:(seatItem.gCol - xMin) * thumbnailPositionDistin +'px'}">
            </div>
      </template>
      <!--以上为缩略座位图具名插槽 结束-->
      <!--以下为座位图具名插槽 开始-->
      <template #seat-area-solt>
        <div class="seatBox" :style="{transform: 'scale('+seatScale+')',height:(seatBoxHeight + stageHeight) +'px',
        width:seatBoxWidth +'px',marginLeft:seatBoxCenterMargin+'px'}">
         <!--中轴线-->
          <div v-show="seatList.length>0" class="middle-line" :style="{height:(seatBoxHeight + stageHeight) +'px',left: middleLine +'px'}"></div>
            <div v-for="(seatItem,index) in seatList" :key="seatItem.id" class="seatClass" @click.prevent="clickSeat(index)" :style="{height:height +'px',width: (width * (seatItem.width || 1)) +'px',
            top:(yMax - seatItem.gRow) * positionDistin +'px',left:(seatItem.gCol - xMin) * positionDistin +'px'}"
            >
              <img class="seatImgClass" :seatId="seatItem.id" :seatIndex="index" :src="seatItem.nowIcon" :title="getSeatTooltip(seatItem)"/>
            </div>
          <!--Entrance and Exit 标记 - 位于中间空白区域（Q排附近）-->
          <div class="entrance-exit-label" :style="{top: '0px', left: middleLine + 'px'}">
            <span>{{ $t('seatArea.entrance') }}</span>
            <span>{{ $t('seatArea.andExit') }}</span>
          </div>
          <!--Stage 在座位下方，跟随座位移动-->
          <div class="stage" :style="{top: (seatBoxHeight + 30) + 'px', left: middleLine + 'px'}">
            <div class="stage-text">{{ $t('seatArea.stage') }}</div>
          </div>
        </div>
      </template>
      <!--以上为座位图具名插槽 结束-->
    </seat-area>
    <!-- 已选座位展示 -->
    <selected-tab
      v-if="selectedSeatList.length > 0"
      :propSelectedSeat="selectedSeatList"
      @cancelSelect="processSelected"
    ></selected-tab>
    <confirm-lock
    :propSelectedSeat="selectedSeatList"
    :propSeatList="seatList"
    @loading="loading"
    @showBookingForm="handleShowBookingForm"
    ></confirm-lock>
    <loading :load="load"></loading>
    <!-- 预订表单弹窗 -->
    <booking-form
      :visible="showBookingModal"
      :selectedSeats="selectedSeatList"
      :eventId="eventId"
      :totalPrice="bookingTotalPrice"
      @close="showBookingModal = false"
      @success="handleBookingSuccess"
    ></booking-form>
  </div>
</template>
<script>
import SeatArea from './component/SeatArea'
import SelectedTab from './component/SelectedTab'
import ConfirmLock from './component/ConfirmLock'
import BookingForm from './component/BookingForm'
import HeaderView from '@/components/Header'
import Loading from '@/components/loading'
import { supabase, subscribeToSeats } from '@/supabase'

export default {
  name: 'HallSeat',
  data () {
    return {
      seatList: [], // 座位对象list
      zoneConfig: [], // 分区配置
      zonePrices: {}, // 分区价格
      eventId: '', // 活动ID
      seatSubscription: null, // 实时订阅
      // 座位尺寸配置（px）
      positionDistin: 32, // 每个座位偏移距离
      width: 28, // 每个座位的宽
      height: 28, // 每个座位的高
      thumbnailWidth: 6, // 缩略图每个座位的宽
      thumbnailHeight: 6, // 缩略图每个座位的高
      thumbnailPositionDistin: 10, // 缩略图每个座位偏移距离
      stageHeight: 150, // Stage 区域高度
      selectedSeatList: [], // 已选择座位
      maxSelect: 4, // 最大选择座位数量 改动可改变最大选择座位数
      load: false, // 加载dom的控制
      showBookingModal: false, // 预订表单弹窗显示状态
      bookingTotalPrice: 0 // 预订总价
    }
  },
  components: {
    SeatArea,
    HeaderView,
    SelectedTab,
    ConfirmLock,
    BookingForm,
    Loading
  },
  mounted () {
    this.getSeatList()
  },
  beforeUnmount () {
    // 清理实时订阅
    if (this.seatSubscription) {
      this.seatSubscription.unsubscribe()
    }
  },
  methods: {
    // 根据分区获取配置
    getZoneConfig: function (zone) {
      return this.zoneConfig.find(c => c.zone === zone) || {}
    },
    // 获取座位悬停提示
    getSeatTooltip: function (seatItem) {
      const row = seatItem.row
      const col = seatItem.col
      const baseInfo = `Row ${row}, Seat ${col}`

      if (seatItem.status === 'reserved' && seatItem.locked_until) {
        const lockedUntil = new Date(seatItem.locked_until)
        const now = new Date()
        if (lockedUntil > now) {
          const minutes = Math.ceil((lockedUntil - now) / 60000)
          return `${baseInfo}\nReserved - Locked for ${minutes} min`
        }
      }

      if (seatItem.status === 'sold') {
        return `${baseInfo}\nSold`
      }

      if (seatItem.status === 'available') {
        const config = this.getZoneConfig(seatItem.zone)
        const price = this.zonePrices[seatItem.zone] || 0
        return `${baseInfo}\n${config.name || seatItem.zone} - $${price}`
      }

      return baseInfo
    },
    // 根据分区和状态获取图标
    getIcon: function (zone, status) {
      const config = this.getZoneConfig(zone)
      // 将未定义图标的状态映射到已有图标：
      // - reserved（已预定未付款）-> locked
      // - paid（已付款）-> sold
      let iconStatus = status
      if (status === 'reserved') {
        iconStatus = 'locked'
      } else if (status === 'paid') {
        iconStatus = 'sold'
      }
      return config.icons ? config.icons[iconStatus] : ''
    },
    // 请求座位数据
    async getSeatList () {
      this.loading(true)
      try {
        // 获取 event ID（从路由参数或查询参数）
        const eventIdFromRoute = this.$route.params.eventId || this.$route.query.eventId

        let event
        if (eventIdFromRoute) {
          // 使用路由中的 event ID
          const { data, error } = await supabase
            .from('events')
            .select('*')
            .eq('id', eventIdFromRoute)
            .single()
          if (error) throw error
          event = data
        } else {
          // 获取第一个活动的事件
          const { data, error } = await supabase
            .from('events')
            .select('*')
            .eq('is_active', true)
            .limit(1)
            .single()
          if (error) throw error
          event = data
        }

        if (!event) {
          console.error('No active event found')
          return
        }

        // 保存配置
        this.eventId = event.id
        this.zonePrices = event.zone_prices || {}
        this.zoneConfig = event.zone_config || []
        this.maxSelect = event.max_seats_per_booking || 4

        // 获取座位数据
        const { data: seats, error: seatsError } = await supabase
          .from('seats')
          .select('*')
          .eq('event_id', event.id)
          .order('g_row', { ascending: true })
          .order('g_col', { ascending: true })

        if (seatsError) throw seatsError

        // 座位处理（转换 snake_case 到 camelCase 并添加图标）
        const processedSeats = seats.map(seat => {
          const zone = seat.zone
          const status = seat.status

          return {
            ...seat,
            // 转换字段名
            gRow: seat.g_row,
            gCol: seat.g_col,
            // 设置图标
            defautIcon: this.getIcon(zone, status === 'available' ? 'available' : status),
            nowIcon: this.getIcon(zone, status === 'available' ? 'available' : status),
            selectedIcon: this.getIcon(zone, 'selected'),
            soldedIcon: this.getIcon(zone, 'sold'),
            lockedIcon: this.getIcon(zone, 'locked'),
            // 判断座位是否可以点击（只有 available 状态可点击）
            canClick: (status === 'available'),
            // 获取座位价格
            price: this.zonePrices[zone] || 0
          }
        })

        this.seatList = processedSeats
        console.log('座位数据加载完成，共', processedSeats.length, '个座位')

        // 订阅座位实时更新
        this.seatSubscription = subscribeToSeats(event.id, (payload) => {
          console.log('座位状态变化:', payload)
          this.handleSeatChange(payload)
        })
      } catch (err) {
        console.error('加载座位数据失败:', err)
      } finally {
        this.loading(false)
      }
    },
    // 处理座位实时更新
    handleSeatChange (payload) {
      const { eventType, new: newSeat } = payload

      if (eventType === 'UPDATE') {
        const index = this.seatList.findIndex(s => s.id === newSeat.id)
        if (index !== -1) {
          const zone = newSeat.zone
          const status = newSeat.status

          // 更新座位数据
          this.seatList[index] = {
            ...this.seatList[index],
            ...newSeat,
            gRow: newSeat.g_row,
            gCol: newSeat.g_col,
            defautIcon: this.getIcon(zone, status === 'available' ? 'available' : status),
            nowIcon: this.getIcon(zone, status === 'available' ? 'available' : status),
            canClick: (status === 'available'),
            price: this.zonePrices[zone] || 0
          }

          // 如果座位被其他人预订，从已选列表中移除
          if (status !== 'available') {
            const selectedIndex = this.selectedSeatList.findIndex(s => s.id === newSeat.id)
            if (selectedIndex !== -1) {
              this.selectedSeatList.splice(selectedIndex, 1)
            }
          }
        }
      }
    },
    // 点击每个座位触发的函数
    clickSeat: function (index) {
      if (this.seatList[index].canClick) {
        if (this.seatList[index].nowIcon === this.seatList[index].selectedIcon) {
          this.processSelected(index)
        } else {
          this.processUnSelected(index)
        }
      }
    },
    // 处理已选的座位（取消选择）
    processSelected: function (index) {
      // 改变座位图标为初始图标
      this.seatList[index].nowIcon = this.seatList[index].defautIcon
      // 从已选列表中移除
      const seatId = this.seatList[index].id
      const idx = this.selectedSeatList.findIndex(s => s.id === seatId)
      if (idx !== -1) {
        this.selectedSeatList.splice(idx, 1)
      }
    },
    // 处理未选择的座位（选择座位）
    processUnSelected: function (index) {
      // 改变座位图标为已选择图标
      this.seatList[index].nowIcon = this.seatList[index].selectedIcon
      // 记录 orgIndex属性 是原seatList数组中的下标值
      this.seatList[index].orgIndex = index
      // 把选择的座位放入到已选座位数组中
      this.selectedSeatList.push(this.seatList[index])
    },
    back: function () {
      this.$router.go(-1)
    },
    // 放大座位图
    handleZoomIn: function () {
      if (this.$refs.seatArea) {
        this.$refs.seatArea.pinchout()
      }
    },
    // 缩小座位图
    handleZoomOut: function () {
      if (this.$refs.seatArea) {
        this.$refs.seatArea.pinchin()
      }
    },
    loading: function (value) {
      this.load = value
    },
    thumbnailBackgroud: function (seatItem) {
      // 已选状态 - 显示绿色
      if (seatItem.nowIcon === seatItem.selectedIcon) {
        return '#22C55E'
      }
      // 已售、已预定、已付款或锁定状态 - 显示灰色
      if (seatItem.status === 'sold' || seatItem.status === 'locked' || seatItem.status === 'reserved' || seatItem.status === 'paid') {
        return '#9CA3AF'
      }
      // 可选状态 - 显示分区颜色
      const config = this.getZoneConfig(seatItem.zone)
      return config.color || '#FFFFFF'
    },
    // 显示预订表单
    handleShowBookingForm (data) {
      this.bookingTotalPrice = data.totalPrice
      this.showBookingModal = true
    },
    // 预订成功处理
    handleBookingSuccess (reservation) {
      console.log('预订成功:', reservation)
      // 清空已选座位
      this.selectedSeatList = []
      this.showBookingModal = false
    }
  },
  computed: {
    // 座位区域宽度（根据窗口宽度动态计算）
    seatAreaWidthPx: function () {
      const windowWidth = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth
      // 移动端最大 375px，桌面端可以更大
      return windowWidth < 768 ? windowWidth : Math.min(windowWidth, 800)
    },
    // 座位区域高度（使用 vh 单位，通过 CSS 类控制）
    // 移除 seatAreaHeightRem 计算，改用 CSS calc(100vh - X)
    // 取最小横坐标
    xMin: function () {
      if (this.seatList.length === 0) return 0
      let min = Infinity
      for (let index in this.seatList) {
        if (this.seatList[index].gCol < min) {
          min = this.seatList[index].gCol
        }
      }
      return min
    },
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
    // 取最小纵坐标
    yMin: function () {
      if (this.seatList.length === 0) return 0
      let min = Infinity
      for (let index in this.seatList) {
        if (this.seatList[index].gRow < min) {
          min = this.seatList[index].gRow
        }
      }
      return min
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
    // 竖中轴线（px）- 基于实际座位范围计算
    middleLine: function () {
      const colRange = this.xMax - this.xMin
      return ((colRange / 2) + 1) * this.positionDistin
    },
    // 横中轴线（px）- 基于实际座位范围计算
    horizontalLine: function () {
      const rowRange = this.yMax - this.yMin
      return ((rowRange / 2) + 1) * this.positionDistin
    },
    // 根据影厅的大小缩放比例
    // 设置最小缩放值，保持座位大小不变，超出部分通过拖动查看
    seatScale: function () {
      const minScale = 1.0 // 最小缩放比例，保持原始大小不缩小

      // 使用窗口高度计算缩放比例
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      // 座位区域可用高度：窗口高度减去头部和底部确认按钮
      const otherHeight = 100 // 预留其他区域的高度
      const availableHeight = windowHeight - otherHeight

      const seatScaleX = this.seatAreaWidthPx / this.seatBoxWidth
      const seatScaleY = availableHeight / this.seatBoxHeight
      const calculatedScale = seatScaleX < seatScaleY ? seatScaleX : seatScaleY

      // 返回计算值和最小值中的较大者
      return Math.max(calculatedScale, minScale)
    },
    // 让影厅居中展示的偏移值
    seatBoxCenterMargin: function () {
      return -(this.seatBoxWidth * this.seatScale) / 2
    },
    // class 为 seatBox 的高度值（px）- 基于实际座位范围
    seatBoxHeight: function () {
      const rowRange = this.yMax - this.yMin
      return (rowRange + 1) * this.positionDistin + this.height
    },
    // class 为 seatBox 的宽度值（px）- 基于实际座位范围
    seatBoxWidth: function () {
      const colRange = this.xMax - this.xMin
      return (colRange + 1) * this.positionDistin + this.width
    },
    // 缩略图宽（px）- 基于实际座位范围
    thumbnailBoxWidth: function () {
      const colRange = this.xMax - this.xMin
      return ((colRange + 1) * this.thumbnailPositionDistin + this.thumbnailWidth)
    },
    // 缩略图高（px）- 基于实际座位范围
    thumbnailBoxHeight: function () {
      const rowRange = this.yMax - this.yMin
      return ((rowRange + 1) * this.thumbnailPositionDistin + this.thumbnailHeight)
    },
    // 座位左边栏的数组 - 基于实际座位范围（反转顺序，A在底部靠近Stage）
    seatToolArr: function () {
      let seatToolArr = []
      // 从 yMax 到 yMin 反向遍历，使行标签与翻转后的座位匹配
      for (let i = this.yMax; i >= this.yMin; i--) {
        let el = this.seatList.find((item) => (
          item.gRow === i
        ))
        if (el) {
          seatToolArr.push(el.row)
        } else {
          seatToolArr.push('')
        }
      }
      return seatToolArr
    }
  }
}
</script>
<style scoped>
/* Main wrapper */
.wapper {
  @apply w-full bg-bg-gray min-h-screen;
}

/* Seat type legend items */
.seat-detail-item {
  @apply flex items-center gap-1;
}

.seatTypeClass {
  @apply block h-6 md:h-8 leading-6 md:leading-8 whitespace-nowrap text-xs md:text-sm;
}

/* Thumbnail seat markers */
.thumbnailSeatClass {
  @apply absolute;
}

/* Seat box container */
.seatBox {
  @apply absolute left-1/2;
  transform-origin: 0 0 0;
}

/* Center line */
.middle-line {
  @apply absolute;
  border-right: 1px rgba(0,0,0,0.2) dashed;
}

/* Individual seats */
.seatClass {
  @apply absolute cursor-pointer;
}

.seatImgClass {
  @apply absolute left-0 top-0 h-full w-full object-contain;
}

/* Stage element - positioned relative to seats */
.stage {
  @apply absolute;
  width: 700px;
  max-width: 90%;
  height: 100px;
  transform: translateX(-50%);
  margin-top: 40px;
}

.stage::before {
  content: '';
  display: block;
  width: 100%;
  height: 100%;
  background: linear-gradient(135deg, #8B5CF6 0%, #6366F1 50%, #8B5CF6 100%);
  clip-path: polygon(10% 0%, 90% 0%, 100% 100%, 0% 100%);
  border-radius: 4px;
}

.stage-text {
  @apply absolute inset-0 flex items-center justify-center text-white font-bold text-lg tracking-wider;
}

/* Entrance and Exit label - positioned in the middle gap area */
.entrance-exit-label {
  @apply absolute flex flex-col items-center justify-center text-gray-500 font-semibold;
  transform: translateX(-80%);
  font-size: 14px;
  line-height: 1.4;
  height: 140px;
  text-align: center;
}

.entrance-exit-label span {
  display: block;
}
</style>
