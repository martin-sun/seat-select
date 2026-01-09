import { ref, onMounted, onUnmounted } from 'vue'

/**
 * 设备检测 composable
 * 使用原生 userAgent 和屏幕宽度检测是否为移动设备
 */
export function useDevice() {
  const isMobile = ref(false)

  const checkDevice = () => {
    const ua = navigator.userAgent
    const width = window.innerWidth

    // 检测手机设备（排除平板）
    // iPhone, iPod, Android phones (not tablets)
    const isPhone = /iPhone|iPod|Android(?=.*Mobile)/i.test(ua)

    // 检测平板设备
    const isTablet = /iPad|Android(?!.*Mobile)|Tablet/i.test(ua)

    // 手机或窄屏平板使用移动端视图
    isMobile.value = isPhone || (isTablet && width < 768)
  }

  onMounted(() => {
    checkDevice()
    window.addEventListener('resize', checkDevice)
  })

  onUnmounted(() => {
    window.removeEventListener('resize', checkDevice)
  })

  return { isMobile }
}
