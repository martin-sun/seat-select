import { createDirectus, rest, readItems, readSingleton } from '@directus/sdk'

// Directus Cloud URL - 需要替换为你的实际 URL
const DIRECTUS_URL = import.meta.env?.VITE_DIRECTUS_URL
  || process.env.VUE_APP_DIRECTUS_URL
  || 'https://your-project.directus.app'

const directus = createDirectus(DIRECTUS_URL).with(rest())

/**
 * 获取春晚全局设置（单例）
 */
export async function getSettings() {
  return await directus.request(readSingleton('chunwan_settings'))
}

/**
 * 获取节目单列表
 */
export async function getPrograms() {
  return await directus.request(readItems('chunwan_programs', {
    filter: { status: { _eq: 'published' } },
    sort: ['sort'],
    fields: ['id', 'title', 'type', 'performers', 'description', 'thumbnail']
  }))
}

/**
 * 获取票价信息
 */
export async function getTickets() {
  return await directus.request(readItems('chunwan_tickets', {
    filter: { available: { _eq: true } },
    sort: ['sort'],
    fields: ['id', 'name', 'price', 'description', 'available', 'color']
  }))
}

/**
 * 获取往期回顾
 */
export async function getHistory() {
  return await directus.request(readItems('chunwan_history', {
    sort: ['-year'],
    fields: ['id', 'year', 'title', 'thumbnail', 'video_url']
  }))
}

/**
 * 获取 Directus 文件 URL
 */
export function getAssetUrl(fileId) {
  if (!fileId) return null
  if (typeof fileId === 'string' && fileId.startsWith('http')) {
    return fileId
  }
  return `${DIRECTUS_URL}/assets/${fileId}`
}

export default directus
