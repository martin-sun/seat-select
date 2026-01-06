/*
  @author zenghao0219
  @description 用于动态生成座位图,缩略图,座位左边栏
  @updateDate 最后更新时间为:2019-02-21
*/
<template>
    <div class="activity-area">
      <!-- 缩略图已移除 -->
      <div class="box" ref="pinchAndPan" :class="{ 'cursor-grabbing': touchStatus }">
        <slot name="seat-area-solt">
          <!--所有可以点击座位的数据会放入此插槽,此插槽可以缩放,拖动-->
        </slot>
      </div>
        <!--座位左边栏 - 已移除，改为嵌入式行号-->
      <!-- <div class="seat-tool-parent">
        <div class="seat-tool" :style="{marginTop:seatToolMargin+'px',
        fontSize:seatToolFontSize +'px'}">
            <div v-for="(item, index) in seatToolArr" :key="'seat-tool' + index" class="seat-tool-item"
            :style="{height:seatHeightWithScale+'px',width:seatToolWidthWithScale+'px',lineHeight:seatHeightWithScale+'px'}">
                {{item}}
            </div>
        </div>
      </div> -->
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
    propInitialScale: Number,
    propSeatHeight: Number,
    propSeatAreaWidthPx: Number,
    propMiddleLine: Number,
    propHorizontalLine: Number,
    propSeatBoxHeight: Number,
    propSeatBoxWidth: Number,
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
      initialScale: this.propInitialScale,
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
        // 由于现在底层是 1.0 (高清) 渲染，最大倍数设为 5 或根据初始比例动态计算
        // 确保最终能放大到足够清晰
        const dynamicMaxZoom = Math.max(8, 4 / this.initialScale)
        
        this.panzoomInstance = panzoom(this.$refs.pinchAndPan, {
          maxZoom: dynamicMaxZoom,
          minZoom: this.initialScale * 0.5, // 允许缩位到初始大小的一半
          bounds: false, // 禁用边界限制，解决在嵌套缩放下的滑动锁死 Bug
          smoothScroll: true,
          zoomDoubleClickSpeed: 1, // 禁用双击/双指双击缩放
          onClick: (event) => {
            this.handlePanzoomClick(event)
          }
        })

        // 初始应用适配逻辑
        this.refit()

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
      const heightProportion = (this.seatBoxHeight / this.thumbnailHeightPx)
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
      this.refit(true) // 使用平滑过渡
    },
    // 适配屏幕并居中显示
    refit: function (smooth = false) {
      if (!this.panzoomInstance || !this.initialScale || !isFinite(this.initialScale) || this.initialScale <= 0) {
        return
      }

      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      const seatAreaHeightPx = windowHeight - 120
      
      // 计算居中位置
      const actualWidth = (this.propSeatBoxWidth || this.seatAreaWidthPx) * this.initialScale
      const actualHeight = this.seatBoxHeight * this.initialScale
      
      const initialLeft = (this.seatAreaWidthPx - actualWidth) / 2
      let initialTop = 0
      if (actualHeight < seatAreaHeightPx) {
        initialTop = (seatAreaHeightPx - actualHeight) / 2
      }

      // 更新缩放限制
      const dynamicMaxZoom = Math.max(8, 4 / this.initialScale)
      this.panzoomInstance.setMaxZoom(dynamicMaxZoom)
      this.panzoomInstance.setMinZoom(this.initialScale * 0.3) // 允许稍微缩小更多一点

      if (smooth) {
        this.panzoomInstance.smoothZoom(0, 0, this.initialScale / this.scale)
        this.panzoomInstance.moveTo(initialLeft, initialTop)
      } else {
        this.panzoomInstance.zoomAbs(0, 0, this.initialScale)
        this.panzoomInstance.moveTo(initialLeft, initialTop)
        
        // 第一次非平滑适配完成后，通知父组件已就绪
        this.$emit('ready')
      }
    },
    handlePanzoomClick: function (event) {
      const target = event.target
      if (!target || !target.closest) return
      const seatNode = target.closest('[data-seat-index]')
      if (!seatNode) return
      const index = Number(seatNode.dataset.seatIndex)
      if (Number.isNaN(index)) return
      this.$emit('seatClick', index)
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
      // 现在逻辑非常简单：就是跟随 panzoom 的 top 偏移量
      return this.top + 8 // 8 是额外的 margin-top
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
    propInitialScale: function (value) {
      this.initialScale = value
      this.refit()
    },
    propMiddleLine: function (value) {
      this.middleLine = value
      this.refit()
    },
    propHorizontalLine: function (value) {
      this.horizontalLine = value
      this.refit()
    },
    propSeatBoxHeight: function (value) {
      this.seatBoxHeight = value
      this.refit()
    },
    propSeatToolArr: function (value) {
      this.seatToolArr = value
    },
    propSeatAreaWidthPx: function (value) {
      this.seatAreaWidthPx = value
      this.refit()
    },
    propSeatBoxWidth: function () {
      this.refit()
    }
  },
  mounted: function () {
    this.initPanzoom()
    
    // 安全起见，如果 3 秒后还没 ready (比如数据加载失败)，也通知父组件关闭 loading
    setTimeout(() => {
      this.$emit('ready')
    }, 3000)
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
  touch-action: none;
  overscroll-behavior: contain;
  user-select: none;
  -webkit-user-select: none;
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
  cursor: grab;
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
