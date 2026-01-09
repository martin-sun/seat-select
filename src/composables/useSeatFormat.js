import i18n from '@/i18n'

/**
 * Format seat display based on locale
 * @param {Object} seat - Seat object with row and col properties
 * @returns {string} Formatted seat string
 */
export function formatSeat(seat) {
  if (!seat) return ''
  const locale = i18n.global.locale?.value || localStorage.getItem('locale') || 'zh-CN'
  if (locale === 'zh-CN' || locale === 'zh') {
    return `${seat.row}排${seat.col}座`
  }
  return `Row ${seat.row}, Seat ${seat.col}`
}

/**
 * Composable for seat formatting utilities
 */
export function useSeatFormat() {
  return {
    formatSeat
  }
}
