/*
  @author zenghao0219
  @description 座位页面父级组件,控制点击选座,数据加载处理
  @updateDate 最后更新时间为:2019-04-29
*/
<template>
  <div class="wapper">
    <!--头部 开始-->
    <header-view :titleText="movieName" @backHandleClick="back"></header-view>
    <!--头部 结束-->
    <seat-area :propThumbnailAreaWidth="thumbnailBoxWidth" :propThumbnailAreaHeight="thumbnailBoxHeight"
    :propYMax="yMax" :propSeatScale="seatScale" :propSeatHeight="positionDistin" :propSeatToolArr="seatToolArr"
    :propSeatAreaWidthPx="seatAreaWidthPx"
    :propSeatBoxHeight="seatBoxHeight" :propMiddleLine="middleLine" :propHorizontalLine="horizontalLine" ref="seatArea">
      <!--以下为缩略座位图具名插槽 开始-->
      <template #thumbnail-seat-solt>
            <div v-for="seatItem in seatList" :key="'thumbnail'+seatItem.id" class="thumbnailSeatClass" :style="{height:thumbnailHeight +'px',
            width:thumbnailWidth +'px',background: thumbnailBackgroud(seatItem),
            top:seatItem.gRow * thumbnailPositionDistin +'px',left:seatItem.gCol * thumbnailPositionDistin +'px'}">
            </div>
      </template>
      <!--以上为缩略座位图具名插槽 结束-->
      <!--以下为座位图具名插槽 开始-->
      <template #seat-area-solt>
        <div class="seatBox" :style="{transform: 'scale('+seatScale+')',height:seatBoxHeight +'px',
        width:seatBoxWidth +'px',marginLeft:seatBoxCenterMargin+'px'}">
         <!--中轴线-->
          <div v-show="seatList.length>0" class="middle-line" :style="{height:seatBoxHeight +'px',left: middleLine +'px'}"></div>
            <div v-for="(seatItem,index) in seatList" :key="seatItem.id" class="seatClass" @click.prevent="clickSeat(index)" :style="{height:height +'px',width:width +'px',
            top:seatItem.gRow * positionDistin +'px',left:seatItem.gCol * positionDistin +'px'}"
            >
              <img class="seatImgClass" :seatId="seatItem.id" :seatIndex="index" :src="seatItem.nowIcon"/>
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
    ></confirm-lock>
    <loading :load="load"></loading>
  </div>
</template>
<script>
import SeatArea from './component/SeatArea'
import SelectedTab from './component/SelectedTab'
import ConfirmLock from './component/ConfirmLock'
import HeaderView from '@/components/Header'
import Loading from '@/components/loading'
export default {
  name: 'HallSeat',
  data () {
    return {
      seatList: [], // 座位对象list
      seatTypeList: [], // 座位类型list
      movieName: '', // 展示用 电影名称 接口获取
      hallName: '', // 展示用 影厅名称 接口获取
      showDate: '', // 展示用 开始日期 接口获取
      showTime: '', // 展示用 开始时间 接口获取
      // 座位尺寸配置（px）
      positionDistin: 32, // 每个座位偏移距离
      width: 28, // 每个座位的宽
      height: 28, // 每个座位的高
      thumbnailWidth: 6, // 缩略图每个座位的宽
      thumbnailHeight: 6, // 缩略图每个座位的高
      thumbnailPositionDistin: 10, // 缩略图每个座位偏移距离
      selectedSeatList: [], // 已选择座位
      maxSelect: 4, // 最大选择座位数量 改动可改变最大选择座位数
      load: false // 加载dom的控制
    }
  },
  components: {
    SeatArea,
    HeaderView,
    SelectedTab,
    ConfirmLock,
    Loading
  },
  mounted () {
    this.loading(true)
    this.getSeatList()
    this.loading(false)
  },
  // // fixme 这里确认是否还需要
  // beforeRouteLeave (to, from, next) {
  //   if (to.path === '/moviePlan') {
  //     to.meta.keepAlive = true
  //   } else {
  //     to.meta.keepAlive = false
  //   }
  //   next()
  // },
  methods: {
    // 请求影院列表数据
    getSeatList: function () {
      // mock数据
      this.$get('/mock/seatLove.json')
        .then((response) => {
          console.log('座位返回response------>>>>', response)
          if (response.errorCode !== 0) {
            alert(response.errorMsg)
            this.$router.go(-1)
          }
          var resSeatList = response.seatList
          // 座位处理 -------开始
          if (!resSeatList) {
            return
          }
          resSeatList.forEach(element => {
            // 获取座位的类型的首字母
            let firstNumber = element.type.substr(0, 1)
            // 在原来的对象中加入两个属性  otherLoveSeatIndex 对应情侣座位的原数组下标 otherLoveSeatId  对应情侣座位的Id
            element.otherLoveSeatIndex = null
            element.otherLoveSeatId = null
            // 座位的类型的首字母为 '1' 是情侣首座 处理情侣首座位
            if (firstNumber === '1') {
              for (const index in resSeatList) {
                if (resSeatList[index].gRow === element.gRow &&
                  resSeatList[index].gCol === element.gCol + 1) {
                  element.otherLoveSeatIndex = index
                  element.otherLoveSeatId = resSeatList[index].id
                }
              }
            }
            // 座位的类型的首字母为 '2' 是情侣次座 处理情侣次座位
            if (firstNumber === '2') {
              for (const index in resSeatList) {
                if (resSeatList[index].gRow === element.gRow &&
                  resSeatList[index].gCol === element.gCol - 1) {
                  element.otherLoveSeatIndex = index
                  element.otherLoveSeatId = resSeatList[index].id
                }
              }
            }
            // 加载座位的图标
            for (const item of response.seatTypeList) {
              // 加载每个座位的初始图标defautIcon 和 当前图标 nowIcon
              if (element.type === item.type) {
                element.nowIcon = item.icon
                element.defautIcon = item.icon
              }
              // 根据首字母找到对应的被选中图标
              if (firstNumber + '-1' === item.type) {
                element.selectedIcon = item.icon
              }
              // 根据首字母找到对应的被选中图标
              if (firstNumber + '-2' === item.type) {
                element.soldedIcon = item.icon
              }
              // 根据首字母找到对应的被选中图标
              if (firstNumber + '-3' === item.type) {
                element.fixIcon = item.icon
              }
            }
            // 如果座位是已经售出 和 维修座位 加入属性canClick 判断座位是否可以点击
            if (element.defautIcon === element.soldedIcon || element.defautIcon === element.fixIcon) {
              element.canClick = false
            } else {
              element.canClick = true
            }
          })
          // 座位处理 -------结束
          // 开始处理上方影片信息显示数据
          var temp = response.showTime
          if (temp.length === 19) {
            this.showDate = temp.substring(0, 10) + '(' + temp.substring(11, 13) + ')'
            this.showTime = temp.substring(14, 19)
          }
          this.seatList = resSeatList
          this.seatTypeList = response.seatTypeList
          this.movieName = response.movieName
          this.hallName = response.name
        }, err => {
          console.log(err)
        })
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
    // 处理已选的座位
    processSelected: function (index) {
      let _selectedSeatList = this.selectedSeatList
      let otherLoveSeatIndex = this.seatList[index].otherLoveSeatIndex
      if (otherLoveSeatIndex !== null) {
        // 如果是情侣座位
        // 改变这些座位的图标为初始图标
        this.seatList[index].nowIcon = this.seatList[index].defautIcon
        this.seatList[otherLoveSeatIndex].nowIcon = this.seatList[otherLoveSeatIndex].defautIcon
        for (const key in _selectedSeatList) {
          // 移除id一样的座位
          if (_selectedSeatList[key].id === this.seatList[index].id) {
            _selectedSeatList.splice(key, 1)
          }
        }
        // 移除对应情侣座位
        for (const key in _selectedSeatList) {
          if (_selectedSeatList[key].id === this.seatList[otherLoveSeatIndex].id) {
            _selectedSeatList.splice(key, 1)
          }
        }
      } else {
        // 改变这些座位的图标为初始图标 并 移除id一样的座位
        this.seatList[index].nowIcon = this.seatList[index].defautIcon
        for (const key in _selectedSeatList) {
          if (_selectedSeatList[key].id === this.seatList[index].id) {
            _selectedSeatList.splice(key, 1)
          }
        }
      }
    },
    // 处理未选择的座位
    processUnSelected: function (index) {
      let _selectedSeatList = this.selectedSeatList
      let otherLoveSeatIndex = this.seatList[index].otherLoveSeatIndex
      if (otherLoveSeatIndex !== null) {
        // 如果选中的是情侣座位 判断选择个数不大于 maxSelect
        if (_selectedSeatList.length >= this.maxSelect - 1) {
          alert('最多只能选择' + this.maxSelect + '个座位哦~')
          return
        }
        // 改变这些座位的图标为已选择图标
        this.seatList[index].nowIcon = this.seatList[index].selectedIcon
        this.seatList[otherLoveSeatIndex].nowIcon = this.seatList[otherLoveSeatIndex].selectedIcon
        // 记录 orgIndex属性 是原seatList数组中的下标值
        this.seatList[index].orgIndex = index
        this.seatList[otherLoveSeatIndex].orgIndex = otherLoveSeatIndex
        // 把选择的座位放入到已选座位数组中
        _selectedSeatList.push(this.seatList[index])
        _selectedSeatList.push(this.seatList[otherLoveSeatIndex])
      } else {
        // 如果选中的是非情侣座位 判断选择个数不大于 maxSelect
        if (_selectedSeatList.length >= this.maxSelect) {
          alert('最多只能选择' + this.maxSelect + '个座位哦~')
          return
        }
        // 改变这些座位的图标为已选择图标
        this.seatList[index].nowIcon = this.seatList[index].selectedIcon
        // 记录 orgIndex属性 是原seatList数组中的下标值
        this.seatList[index].orgIndex = index
        // 把选择的座位放入到已选座位数组中
        _selectedSeatList.push(this.seatList[index])
      }
    },
    back: function () {
      this.$router.go(-1)
    },
    loading: function (value) {
      this.load = value
    },
    thumbnailBackgroud: function (seatItem) {
      if (seatItem.nowIcon === seatItem.selectedIcon) {
        return 'green'
      } else if (seatItem.nowIcon === seatItem.soldedIcon) {
        return 'red'
      } else if (seatItem.nowIcon === seatItem.fixIcon) {
        return 'red'
      } else {
        return 'white'
      }
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
    // 竖中轴线（px）
    middleLine: function () {
      // 座位偏移值的一半作为线宽的一半也需要居中
      return ((this.xMax / 2) + 1) * this.positionDistin
    },
    // 横中轴线（px）
    horizontalLine: function () {
      return ((this.yMax / 2) + 1) * this.positionDistin
    },
    // 根据影厅的大小缩放比例(需要把影厅全部显示出来)
    seatScale: function () {
      let seatScaleX = 1
      let seatScaleY = 1
      // 使用窗口高度计算缩放比例
      const windowHeight = window.innerHeight || document.documentElement.clientHeight || document.body.clientHeight
      // 座位区域可用高度：窗口高度减去头部和底部确认按钮
      const otherHeight = 100 // 预留其他区域的高度
      const availableHeight = windowHeight - otherHeight

      seatScaleX = this.seatAreaWidthPx / this.seatBoxWidth
      seatScaleY = availableHeight / this.seatBoxHeight
      return seatScaleX < seatScaleY ? seatScaleX : seatScaleY
    },
    // 让影厅居中展示的偏移值
    seatBoxCenterMargin: function () {
      return -(this.seatBoxWidth * this.seatScale) / 2
    },
    // class 为 seatBox 的高度值 单位为rem
    seatBoxHeight: function () {
      // 纵轴总数量+1 * 座位偏移值 + 一个座位高度
      return (this.yMax + 1) * this.positionDistin + this.height
    },
    // class 为 seatBox 的宽度值 单位为rem
    seatBoxWidth: function () {
      // 横轴总数量+1 * 座位偏移值 + 一个座位宽度
      return (this.xMax + 1) * this.positionDistin + this.width
    },
    // 缩略图宽 rem
    thumbnailBoxWidth: function () {
      return ((this.xMax + 1) * this.thumbnailPositionDistin + this.thumbnailWidth)
    },
    // 缩略图高 rem
    thumbnailBoxHeight: function () {
      return ((this.yMax + 1) * this.thumbnailPositionDistin + this.thumbnailHeight)
    },
    // 座位左边栏的数组
    seatToolArr: function () {
      let seatToolArr = []
      let yMax = this.yMax
      for (let i = 1; i <= yMax; i++) {
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
</style>
