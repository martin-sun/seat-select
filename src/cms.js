import { supabase } from './supabase'

/**
 * 获取春节联欢晚会全局设置（单例）
 */
export async function getSettings() {
  const { data, error } = await supabase
    .from('chunwan_settings')
    .select('*')
    .maybeSingle()

  if (error) {
    console.error('Error fetching settings from Supabase:', error)
    return null
  }
  return data
}

/**
 * 获取节目单列表
 */
export async function getPrograms() {
  const { data, error } = await supabase
    .from('chunwan_programs')
    .select('*')
    .eq('status', 'published')
    .order('sort', { ascending: true })

  if (error) {
    console.error('Error fetching programs from Supabase:', error)
    return []
  }
  return data
}

/**
 * 获取票价信息
 */
export async function getTickets() {
  const { data, error } = await supabase
    .from('chunwan_tickets')
    .select('*')
    .eq('available', true)
    .order('sort', { ascending: true })

  if (error) {
    console.error('Error fetching tickets from Supabase:', error)
    return []
  }
  return data
}

/**
 * 获取往期回顾
 */
export async function getHistory() {
  const { data, error } = await supabase
    .from('chunwan_history')
    .select('*')
    .order('year', { ascending: false })

  if (error) {
    console.error('Error fetching history from Supabase:', error)
    return []
  }
  return data
}

/**
 * 获取赞助商列表
 */
export async function getSponsors() {
  const { data, error } = await supabase
    .from('chunwan_sponsors')
    .select('*')
    .order('sort', { ascending: true })

  if (error) {
    console.error('Error fetching sponsors from Supabase:', error)
    return []
  }
  return data
}

/**
 * 获取承办/协办单位
 */
export async function getOrganizers() {
  const { data, error } = await supabase
    .from('chunwan_organizers')
    .select('*')
    .order('sort', { ascending: true })

  if (error) {
    console.error('Error fetching organizers from Supabase:', error)
    return []
  }
  return data
}

/**
 * 获取资源 URL (Supabase 存储或其他)
 */
export function getAssetUrl(fileId) {
  if (!fileId) return null
  if (typeof fileId === 'string' && (fileId.startsWith('http') || fileId.startsWith('/'))) {
    return fileId
  }
  // 如果是 Supabase 存储路径，可以根据需求拼接 URL
  // 目前 mock 数据中使用的是占位符或绝对路径
  return fileId
}

export default supabase
