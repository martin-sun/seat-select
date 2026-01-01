/*
  @author zenghao0219
  @description 用于动态生成座位图,缩略图,座位左边栏
  @updateDate 最后更新时间为:2019-02-21
*/
<template>
    <div class="activity-area">
      <div class="screen">
        <div class="screen-text">屏幕方向</div>
      </div>
      <div class="thumbnail" v-show="thumbnailShow" :style="{ transform: 'scale('+seatScale+')',width:thumbnailWidthPx + 'px',height:thumbnailHeightPx + 'px'}">
        <!--红色外框开始-->
        <div class="thumbnail-border" :style="{transform: 'scale('+scalereciprocal+')',top:topthumbnail + 'px',left:leftthumbnail + 'px'}">
        </div>
        <!--红色外框结束-->
        <slot name="thumbnail-seat-solt">
          <!--这里是缩略图中的所有座位放入此插槽-->
        </slot>
      </div>
      <div class="box" ref="pinchAndPan"
      @touchstart="handleTouchStart" @touchmove="handleTouchMove" @touchend="handleTouchEnd"
      @mousedown="handleMouseDown" @mousemove="handleMouseMove" @mouseup="handleMouseUp" @mouseleave="handleMouseUp"
      :style="{transform: 'scale('+scale+')',transformOrigin: transformOrigin,top:top + 'px',left:left + 'px', cursor: 'grab'}"
      :class="{ 'cursor-grabbing': touchStatus }">
        <slot name="seat-area-solt">
          <!--所有可以点击座位的数据会放入此插槽,此插槽可以缩放,拖动-->
        </slot>
      </div>
        <!--座位左边栏-->
      <div class="seat-tool-parent">
        <div class="seat-tool" :style="{transform: 'scale('+seatScale+')',transformOrigin: transformOriginTool,marginTop:seatToolMargin+'px',
        fontSize:seatToolFontSize +'px'}">
            <div v-for="(item, index) in seatToolArr" :key="'seat-tool' + index" class="seat-tool-item"
            :style="{height:seatHeightWithScale+'px',width:seatToolWidthWithScale+'px',lineHeight:seatHeightWithScale+'px'}">
                {{item}}
            </div>
        </div>
      </div>
    </div>
</template>
<script>
export default {
  name: 'SeatArea',
  props: {
    propThumbnailAreaWidth: Number,
    propThumbnailAreaHeight: Number,
    propYMax: Number,
    propSeatScale: Number,
    propSeatHeight: Number,
    propSeatAreaWidthPx: Number,
    propMiddleLine: Number,
    propHorizontalLine: Number,
    propSeatBoxHeight: Number,
    propSeatToolArr: Array
  },
  data: function () {
    return {
      scale: 1, // 区域放大尺寸
      top: 0, // 单位px
      left: 0, // 单位px
      topthumbnail: 0, // 单位px
      leftthumbnail: 0, // 单位px
      startX: 0, // ---移动的起点X轴 单位px
      startY: 0, // ---移动的起点Y轴 单位px
      seatAreaWidthPx: this.propSeatAreaWidthPx, // 座位区域宽 px
      thumbnailWidthPx: this.propThumbnailAreaWidth, // 缩略图宽 px
      thumbnailHeightPx: this.propThumbnailAreaHeight, // 缩略图高 px
      seatToolWidth: 18, // 座位栏合适的初始宽度 px
      middleLine: this.propMiddleLine,
      horizontalLine: this.propHorizontalLine,
      // 最大排数
      yMax: this.propYMax,
      // 内部座位图缩放比例(为了一次可以显示全部座位)
      seatScale: this.propSeatScale,
      // 缩略图是否显示
      thumbnailShow: false,
      // 定时器对象
      timer: {},
      // 每个座位dom的高度
      seatHeight: this.propSeatHeight,
      // .seatBox的高度
      seatBoxHeight: this.propSeatBoxHeight,
      // 触摸状态
      touchStatus: false,
      // 座位左边栏的数组
      seatToolArr: this.propSeatToolArr,
      // 原生触摸事件相关
      touchStartX: 0,
      touchStartY: 0,
      initialPinchDistance: null
    }
  },
  methods: {
    // 触摸事件处理 - 替代 vue-touch
    handleTouchStart: function (ev) {
      if (ev.touches.length === 1) {
        // 单指触摸 - panstart
        this.panstart(ev)
      } else if (ev.touches.length === 2) {
        // 双指触摸 - 记录初始距离用于缩放
        this.initialPinchDistance = this.getPinchDistance(ev.touches)
      }
    },
    handleTouchMove: function (ev) {
      if (ev.touches.length === 1) {
        // 单指移动 - panmove
        const touch = ev.touches[0]
        this.panmove({
          deltaX: touch.clientX - this.touchStartX,
          deltaY: touch.clientY - this.touchStartY
        })
      } else if (ev.touches.length === 2) {
        // 双指移动 - pinch
        const currentDistance = this.getPinchDistance(ev.touches)
        if (this.initialPinchDistance) {
          if (currentDistance > this.initialPinchDistance + 10) {
            this.pinchout()
            this.initialPinchDistance = currentDistance
          } else if (currentDistance < this.initialPinchDistance - 10) {
            this.pinchin()
            this.initialPinchDistance = currentDistance
          }
        }
      }
    },
    handleTouchEnd: function (ev) {
      this.panend(ev)
      this.initialPinchDistance = null
    },
    // 鼠标事件处理
    handleMouseDown: function (ev) {
      ev.preventDefault()
      this.touchStatus = true
      this.thumbnailShow = true
      this.startY = this.top
      this.startX = this.left
      this.touchStartX = ev.clientX
      this.touchStartY = ev.clientY
      clearTimeout(this.timer)
    },
    handleMouseMove: function (ev) {
      if (!this.touchStatus) return
      ev.preventDefault()
      this.panmove({
        deltaX: ev.clientX - this.touchStartX,
        deltaY: ev.clientY - this.touchStartY
      })
    },
    handleMouseUp: function () {
      if (!this.touchStatus) return
      this.panend()
    },
    getPinchDistance: function (touches) {
      const dx = touches[0].clientX - touches[1].clientX
      const dy = touches[0].clientY - touches[1].clientY
      return Math.sqrt(dx * dx + dy * dy)
    },
    // 第一次点击座位改变放大比例
    changeScale: function () {
      if (this.maxscale === 1) {
        return
      }
      this.scale = this.maxscale
    },
    // 第一次点击座位改变偏移
    changePosition: function (top, left) {
      if (this.maxscale === 1) {
        return
      }
      let _this = this
      // 0.67是上方 屏幕方向dom 部分偏移的部分 也是 .box margin-top 的50px
      _this.top = top * (this.scale - 1) + 0.67
      _this.left = left * (this.scale - 1)
    },
    // 当缩放 放大的时候触发
    pinchout: function () {
      let _this = this
      if (_this.scale >= 0 && _this.scale < _this.maxscale) {
        _this.scale += 0.1
      }
    },
    // 当缩放 缩小的时候触发
    pinchin: function () {
      let _this = this
      if (_this.scale > 1) {
        _this.scale -= 0.1
      }
    },
    // 当手指拖动的过程中
    panmove: function (ev) {
      let _this = this
      if (_this.touchStatus) {
        // 本次座位图移动横纵坐标px的值
        _this.top = (ev.deltaY + _this.startY)
        _this.left = (ev.deltaX + _this.startX)
        // .seatBox的高和缩略图的高 换算比例
        let heightProportion = (_this.seatBoxHeight * _this.seatScale / _this.thumbnailHeightPx)
        // .seatBox的宽和缩略图的宽 换算比例
        let widthProportion = (_this.seatAreaWidthPx / _this.thumbnailWidthPx)
        // 本次缩略图移动横纵坐标px的值
        _this.topthumbnail = -_this.top / heightProportion * _this.scalereciprocal
        _this.leftthumbnail = -_this.left / widthProportion * _this.scalereciprocal
      }
    },
    // 当手指拖动开始的时候
    panstart: function (ev) {
      let _this = this
      // 优化触摸性能
      _this.touchStatus = true
      // 展示缩略图
      _this.thumbnailShow = true
      // 获取上次记录的xy坐标作为起点
      _this.startY = _this.top
      _this.startX = _this.left
      // 记录触摸起始位置（用于原生触摸事件）
      if (ev.touches && ev.touches.length > 0) {
        _this.touchStartX = ev.touches[0].clientX
        _this.touchStartY = ev.touches[0].clientY
      }
      clearTimeout(_this.timer)
    },
    // 当手指拖动结束的时候
    panend: function () {
      let _this = this
      // 优化触摸性能
      _this.touchStatus = false
      // 边界检查 - 允许在任何缩放比例下拖动
      const maxLeft = _this.scale === 1 ? _this.boundaryLeft : _this.crossleft
      const maxTop = _this.scale === 1 ? _this.boundaryTop : _this.crosstop
      // 如果宽度移动超过了边界值 把移动置为边界值
      if (_this.left > maxLeft) {
        _this.left = maxLeft
      } else if (_this.left < -maxLeft) {
        _this.left = -maxLeft
      }
      // 如果高度移动超过了边界值 把移动置为边界值
      if (_this.top > maxTop) {
        _this.top = maxTop
      } else if (_this.top < -maxTop) {
        _this.top = -maxTop
      }
      // 缩略图移动超过了边界值 把移动置为边界值
      if (_this.leftthumbnail > _this.thumbnailWidthPxProportion) {
        _this.leftthumbnail = _this.thumbnailWidthPxProportion
      } else if (_this.leftthumbnail < -_this.thumbnailWidthPxProportion) {
        _this.leftthumbnail = -_this.thumbnailWidthPxProportion
      }
      if (_this.topthumbnail > _this.thumbnailHeightPxProportion) {
        _this.topthumbnail = _this.thumbnailHeightPxProportion
      } else if (_this.topthumbnail < -_this.thumbnailHeightPxProportion) {
        _this.topthumbnail = -_this.thumbnailHeightPxProportion
      }
      _this.timer = setTimeout(() => {
        _this.thumbnailShow = false
      }, 2000)
    }
  },
  computed: {
    // 最大放大比例
    maxscale: function () {
      return 1 + 1 / this.seatScale
    },
    // scale === 1 时的左右边界值（允许拖动查看超出屏幕的座位）
    boundaryLeft: function () {
      // 座位区域实际宽度超出屏幕的部分
      const seatBoxActualWidth = this.seatBoxHeight * this.seatScale * 1.5 // 估算座位区域宽度
      const overflow = Math.max(0, seatBoxActualWidth - this.seatAreaWidthPx)
      return overflow / 2 + 100 // 额外留出100px的拖动空间
    },
    // scale === 1 时的上下边界值
    boundaryTop: function () {
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      const seatAreaHeightPx = windowHeight - 100 // 与 CSS 中的高度计算一致
      const seatBoxActualHeight = this.seatBoxHeight * this.seatScale
      const overflow = Math.max(0, seatBoxActualHeight - seatAreaHeightPx)
      return overflow / 2 + 150 // 额外留出拖动空间
    },
    // 左边触边吸附边界值px
    crossleft: function () {
      let _this = this
      return (_this.scale - 1) * _this.seatAreaWidthPx * _this.scaleXCross
    },
    // 上边触边吸附边界值px
    crosstop: function () {
      let _this = this
      // 获取窗口高度作为座位区域高度
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      const seatAreaHeightPx = windowHeight - 100 // 减去其他区域的高度
      return (_this.scale - 1) * seatAreaHeightPx * _this.scaleYCross
    },
    // scale的倒数
    scalereciprocal: function () {
      return 1 / this.scale
    },
    // 缩略图宽度触边吸附边界值
    thumbnailWidthPxProportion: function () {
      let _this = this
      return (1 - _this.scalereciprocal) * _this.thumbnailWidthPx / 2
    },
    // 缩略图高度触边吸附边界值
    thumbnailHeightPxProportion: function () {
      let _this = this
      return (1 - _this.scalereciprocal) * _this.thumbnailHeightPx / 2
    },
    // 每个座位放大后的高度
    seatHeightWithScale: function () {
      let _this = this
      return _this.seatHeight * _this.scale
    },
    // seat-tool 内的字体大小
    seatToolFontSize: function () {
      // 基础字体大小 12px，随缩放比例变化
      return 12 * this.scale
    },
    // seat-tool-item 的宽度
    seatToolWidthWithScale: function () {
      let _this = this
      return _this.seatToolWidth * _this.scale
    },
    // 座位侧边栏需要偏移的长度
    seatToolMargin: function () {
      let _this = this
      let height = (_this.seatHeightWithScale * _this.yMax) * _this.scaleYCross * (_this.seatScale - 1)
      return _this.top + _this.seatHeightWithScale * _this.seatScale - _this.crosstop + height
    },
    // css样式控制.box缩放中心点
    transformOrigin: function () {
       return 'center ' + this.scaleYCross * 100 + '%'
    },
    // css样式控制.seat-tool缩放中心点
    transformOriginTool: function () {
      return '0 ' + this.scaleYCross * 100 + '%'
    },
    // 缩放.box区域 x轴的中心点比例 用于缩放原点
    scaleXCross: function () {
      // .box的所有尺寸与内部.seatbox的换算比例都是seatScale
      return (this.middleLine / this.seatAreaWidthPx) * this.seatScale
    },
    // 缩放.box区域 y轴的中心点比例 用于缩放原点
    scaleYCross: function () {
      // 获取窗口高度作为座位区域高度
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      const seatAreaHeightPx = windowHeight - 100 // 减去其他区域的高度
      return (this.horizontalLine / seatAreaHeightPx) * this.seatScale
    }
  },
  watch: {
    propThumbnailAreaWidth: function (value) {
      this.thumbnailWidthPx = value
    },
    propThumbnailAreaHeight: function (value) {
      this.thumbnailHeightPx = value
    },
    propYMax: function (value) {
      this.yMax = value
    },
    propSeatScale: function (value) {
      this.seatScale = value
    },
    propMiddleLine: function (value) {
      this.middleLine = value
    },
    propHorizontalLine: function (value) {
      this.horizontalLine = value
    },
    propSeatBoxHeight: function (value) {
      this.seatBoxHeight = value
    },
    propSeatToolArr: function (value) {
      this.seatToolArr = value
    }
  },
  mounted: function () {
  }
}
</script>

<style scoped>
/* Activity area - main container */
.activity-area {
  @apply relative bg-bg-gray overflow-hidden w-full;
  /* 使用 calc 计算高度，减去头部和底部确认按钮 */
  height: calc(100vh - 100px);
  padding-bottom: 48px; /* 为底部确认按钮留出空间 */
}

@media (min-width: 768px) {
  .activity-area {
    height: calc(100vh - 110px);
    padding-bottom: 56px;
  }
}

/* Seat box container */
.box {
  @apply absolute z-0 w-full left-0;
  margin-top: 36px;
  /* 设置 width: 100% 和 left: 0 确保子元素 .seatBox 的 left: 50% 能正确居中 */
}

@media (min-width: 768px) {
  .box {
    margin-top: 48px;
  }
}

/* Thumbnail minimap */
.thumbnail {
  @apply absolute z-30 top-0 left-0 bg-black/40 overflow-hidden;
  transform-origin: 0 0;
}

.thumbnail-border {
  @apply absolute z-40 box-border w-full h-full;
  padding: 1px;
}

/* High-res border for thumbnail */
.thumbnail-border::after {
  content: "";
  pointer-events: none;
  display: block;
  position: absolute;
  left: 0;
  top: 0;
  transform-origin: 0 0;
  border: 2px solid red;
  border-radius: 0;
  box-sizing: border-box;
  width: 100%;
  height: 100%;
}

@media (min-resolution: 2dppx) {
  .thumbnail-border::after {
    width: 200%;
    height: 200%;
    border-radius: 0;
    transform: scale(0.5);
  }
}

@media (min-resolution: 3dppx) {
  .thumbnail-border::after {
    width: 300%;
    height: 300%;
    border-radius: 0;
    transform: scale(0.333);
  }
}

/* Screen direction indicator - trapezoid shape */
.screen {
  @apply absolute top-0 z-20 text-white;
  width: 80%;
  max-width: 400px;
  border-top: 28px solid #DFDFDF;
  border-right: 40px solid transparent;
  border-left: 40px solid transparent;
  left: 50%;
  transform: translateX(-50%);
}

@media (min-width: 768px) {
  .screen {
    max-width: 500px;
    border-top-width: 36px;
    border-right-width: 50px;
    border-left-width: 50px;
  }
}

.screen-text {
  @apply text-center whitespace-nowrap text-lg md:text-xl font-semibold;
  margin-top: -24px;
}

@media (min-width: 768px) {
  .screen-text {
    margin-top: -32px;
  }
}

/* Seat tool (row numbers) */
.seat-tool-parent {
  @apply overflow-hidden;
  margin-top: 36px;
}

@media (min-width: 768px) {
  .seat-tool-parent {
    margin-top: 48px;
  }
}

.seat-tool {
  @apply flex flex-col absolute z-10 bg-black/30 text-center text-white font-bold rounded-full;
  left: 0.25rem;
}

.seat-tool-item {
  @apply px-0.5;
}

/* Grabbing cursor when dragging */
.cursor-grabbing {
  cursor: grabbing !important;
}
</style>
