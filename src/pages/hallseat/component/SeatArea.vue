/*
  @author zenghao0219
  @description 用于动态生成座位图,缩略图,座位左边栏
  @updateDate 最后更新时间为:2019-02-21
*/
<template>
    <div class="activity-area">
      <!-- 缩略图已移除 -->
      <div class="box" ref="pinchAndPan"
      :style="{
        transform: 'scale('+scale+')',
        transformOrigin: '0 0',
        top: top + 'px',
        left: left + 'px',
        cursor: 'grab'
      }"
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
import panzoom from 'panzoom'

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
      panzoomInstance: null,
      scale: 1, // 区域放大尺寸
      top: 0, // 单位px
      left: 0, // 单位px
      topthumbnail: 0, // 单位px
      leftthumbnail: 0, // 单位px
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
      seatToolArr: this.propSeatToolArr
    }
  },
  methods: {
    initPanzoom () {
      if (this.$refs.pinchAndPan) {
        this.panzoomInstance = panzoom(this.$refs.pinchAndPan, {
          maxZoom: 5, // 增加最大缩放倍数，确保即使初始缩放很小也能放大看清
          minZoom: 0.1, // 允许更小的缩放
          bounds: false, // 禁用边界限制，解决在嵌套缩放下的滑动锁死 Bug
          smoothScroll: true,
          onDoubleClick: function () {
            return false // 禁用双击缩放，避免干扰选座
          }
        })

        // 初始居中处理 - 如果座位图高度小于可用区域
        const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
        const seatAreaHeightPx = windowHeight - 120
        const actualHeight = this.seatBoxHeight * this.seatScale
        if (actualHeight < seatAreaHeightPx) {
          const initialTop = (seatAreaHeightPx - actualHeight) / 2
          this.panzoomInstance.moveTo(0, initialTop)
        }

        this.panzoomInstance.on('transform', () => {
          const transform = this.panzoomInstance.getTransform()
          this.scale = transform.scale
          this.left = transform.x
          this.top = transform.y

          // 同步缩略图位置
          this.updateThumbnail()
        })

        this.panzoomInstance.on('panstart', () => {
          this.touchStatus = true
          this.thumbnailShow = true
          clearTimeout(this.timer)
        })

        this.panzoomInstance.on('panend', () => {
          this.touchStatus = false
          this.timer = setTimeout(() => {
            this.thumbnailShow = false
          }, 2000)
        })
      }
    },
    updateThumbnail () {
      // .seatBox的高和缩略图的高 换算比例
      const heightProportion = (this.seatBoxHeight * this.seatScale / this.thumbnailHeightPx)
      // .seatBox的宽和缩略图的宽 换算比例
      const widthProportion = (this.seatAreaWidthPx / this.thumbnailWidthPx)
      
      this.topthumbnail = -this.top / heightProportion * this.scalereciprocal
      this.leftthumbnail = -this.left / widthProportion * this.scalereciprocal
    },
    // 当缩放 放大的时候触发（按钮调用）
    pinchout: function () {
      if (this.panzoomInstance) {
        const cx = this.seatAreaWidthPx / 2
        const cy = (window.innerHeight - 100) / 2
        this.panzoomInstance.smoothZoom(cx, cy, 1.2)
      }
    },
    // 当缩放 缩小的时候触发（按钮调用）
    pinchin: function () {
      if (this.panzoomInstance) {
        const cx = this.seatAreaWidthPx / 2
        const cy = (window.innerHeight - 100) / 2
        this.panzoomInstance.smoothZoom(cx, cy, 0.8)
      }
    },
    // 重置视图并居中
    resetView: function () {
      if (this.panzoomInstance) {
        // 计算初始居中位置
        const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
        const seatAreaHeightPx = windowHeight - 120
        const actualHeight = this.seatBoxHeight * this.seatScale
        let initialTop = 0
        if (actualHeight < seatAreaHeightPx) {
          initialTop = (seatAreaHeightPx - actualHeight) / 2
        }

        // 平滑移动到初始位置并将缩放比例重置为 1
        this.panzoomInstance.smoothZoom(0, 0, 1 / this.scale) // 平滑缩放回 1
        this.panzoomInstance.moveTo(0, initialTop)
      }
    }
  },
  computed: {
    // scale的倒数
    scalereciprocal: function () {
      return 1 / this.scale
    },
    // 每个座位放大后的高度
    seatHeightWithScale: function () {
      return this.seatHeight * this.scale
    },
    // seat-tool 内的字体大小
    seatToolFontSize: function () {
      return 12 * this.scale
    },
    // seat-tool-item 的宽度
    seatToolWidthWithScale: function () {
      return this.seatToolWidth * this.scale
    },
    // 座位侧边栏需要偏移的长度
    seatToolMargin: function () {
      const height = (this.seatHeightWithScale * this.yMax) * this.scaleYCross * (this.seatScale - 1)
      return this.top + this.seatHeightWithScale * this.seatScale - this.crosstop + height
    },
    // 上边触边吸附边界值px
    crosstop: function () {
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      const seatAreaHeightPx = windowHeight - 100
      return (this.scale - 1) * seatAreaHeightPx * this.scaleYCross
    },
    // css样式控制.seat-tool缩放中心点
    transformOriginTool: function () {
      return '0 ' + this.scaleYCross * 100 + '%'
    },
    // 缩放.box区域 y轴的中心点比例 用于缩放原点
    scaleYCross: function () {
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      const seatAreaHeightPx = windowHeight - 100
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
    this.initPanzoom()
  },
  beforeUnmount () {
    if (this.panzoomInstance) {
      this.panzoomInstance.dispose()
    }
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

.box {
  @apply absolute z-0 w-full left-0;
  margin-top: 8px;
  /* 启用硬件加速，提升缩放性能 */
  will-change: transform;
}

@media (min-width: 768px) {
  .box {
    margin-top: 12px;
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



/* Seat tool (row numbers) */
.seat-tool-parent {
  @apply overflow-hidden;
  margin-top: 8px;
}

@media (min-width: 768px) {
  .seat-tool-parent {
    margin-top: 12px;
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
