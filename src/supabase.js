import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.VUE_APP_SUPABASE_URL
const supabaseAnonKey = process.env.VUE_APP_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables. Please set VUE_APP_SUPABASE_URL and VUE_APP_SUPABASE_ANON_KEY in .env.local')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Helper function to get event with seats
export async function getEventWithSeats(eventId) {
  const { data: event, error: eventError } = await supabase
    .from('events')
    .select('*')
    .eq('id', eventId)
    .single()

  if (eventError) throw eventError

  const { data: seats, error: seatsError } = await supabase
    .from('seats')
    .select('*')
    .eq('event_id', eventId)
    .order('g_row', { ascending: true })
    .order('g_col', { ascending: true })

  if (seatsError) throw seatsError

  return { event, seats }
}

// Helper function to create a reservation using atomic RPC
export async function createReservation({ eventId, customerName, customerPhone, customerEmail, seatIds, totalAmount }) {
  const { data, error } = await supabase.rpc('create_reservation_atomic', {
    p_event_id: eventId,
    p_customer_name: customerName,
    p_customer_phone: customerPhone,
    p_customer_email: customerEmail,
    p_seat_ids: seatIds,
    p_total_amount: totalAmount
  })

  if (error) throw error

  if (!data.success) {
    const err = new Error(data.error)
    err.unavailableSeats = data.unavailable_seats
    throw err
  }

  return data.reservation
}

// Helper function to get reservation by ID
export async function getReservation(reservationId) {
  const { data: reservation, error: reservationError } = await supabase
    .from('reservations')
    .select(`
      *,
      reservation_seats (
        seat_id,
        seats (*)
      )
    `)
    .eq('id', reservationId)
    .single()

  if (reservationError) throw reservationError

  return reservation
}

// Subscribe to seat changes for real-time updates
export function subscribeToSeats(eventId, callback) {
  const subscription = supabase
    .channel(`seats:event_id=eq.${eventId}`)
    .on(
      'postgres_changes',
      {
        event: '*',
        schema: 'public',
        table: 'seats',
        filter: `event_id=eq.${eventId}`
      },
      callback
    )
    .subscribe()

  return subscription
}

// ============================================
// Auth Helper Functions (Email OTP)
// ============================================

// Send OTP to email for login
export async function sendOtpToEmail(email) {
  const { data, error } = await supabase.auth.signInWithOtp({
    email,
    options: {
      shouldCreateUser: true,
      emailRedirectTo: `${window.location.origin}/my-orders`
    }
  })
  if (error) throw error
  return data
}

// Verify OTP code
export async function verifyOtp(email, token) {
  const { data, error } = await supabase.auth.verifyOtp({
    email,
    token,
    type: 'email'
  })
  if (error) throw error
  return data
}

// Get current session
export async function getSession() {
  const { data: { session }, error } = await supabase.auth.getSession()
  if (error) throw error
  return session
}

// Sign out
export async function signOut() {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

// Get reservations by email (for authenticated user)
export async function getReservationsByEmail(email) {
  const { data, error } = await supabase
    .from('reservations')
    .select(`
      *,
      events (name, hall_name, show_time),
      reservation_seats (
        seat_id,
        seats (row, col, zone)
      )
    `)
    .eq('customer_email', email)
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

// ============================================
// Admin Helper Functions
// ============================================

const ADMIN_SESSION_KEY = 'admin_session'

// Admin login
export async function adminLogin(email, password) {
  const { data, error } = await supabase.rpc('verify_admin_login', {
    p_email: email,
    p_password: password
  })

  if (error) throw error

  if (data.success) {
    // Store admin session in localStorage
    localStorage.setItem(ADMIN_SESSION_KEY, JSON.stringify({
      ...data.admin,
      loginTime: new Date().toISOString()
    }))
  }

  return data
}

// Get admin session from localStorage
export function getAdminSession() {
  const sessionStr = localStorage.getItem(ADMIN_SESSION_KEY)
  if (!sessionStr) return null

  try {
    return JSON.parse(sessionStr)
  } catch {
    return null
  }
}

// Admin logout
export function adminLogout() {
  localStorage.removeItem(ADMIN_SESSION_KEY)
}

// Check if admin is logged in
export function isAdminLoggedIn() {
  return getAdminSession() !== null
}

// ============================================
// Admin Order Management
// ============================================

// Get all reservations with pagination and filtering
export async function getAllReservations({ page = 1, pageSize = 20, status = null, search = '' } = {}) {
  let query = supabase
    .from('reservations')
    .select(`
      *,
      events (name, hall_name, show_time),
      reservation_seats (
        seat_id,
        seats (row, col, zone)
      )
    `, { count: 'exact' })

  if (status) {
    query = query.eq('status', status)
  }

  if (search) {
    query = query.or(`customer_name.ilike.%${search}%,customer_email.ilike.%${search}%,customer_phone.ilike.%${search}%`)
  }

  const { data, error, count } = await query
    .order('created_at', { ascending: false })
    .range((page - 1) * pageSize, page * pageSize - 1)

  if (error) throw error
  return { data, count, page, pageSize }
}

// Update reservation status
export async function updateReservationStatus(reservationId, status) {
  const updateData = { status }

  // If marking as paid, set payment_confirmed_at
  if (status === 'paid') {
    updateData.payment_confirmed_at = new Date().toISOString()
  }

  const { data, error } = await supabase
    .from('reservations')
    .update(updateData)
    .eq('id', reservationId)
    .select()
    .single()

  if (error) throw error

  // If marked as paid, update seats to 'sold'
  if (status === 'paid') {
    await supabase
      .from('seats')
      .update({ status: 'sold' })
      .eq('reservation_id', reservationId)
  }

  // If cancelled, release seats
  if (status === 'cancelled') {
    await supabase
      .from('seats')
      .update({ status: 'available', reservation_id: null, locked_until: null })
      .eq('reservation_id', reservationId)
  }

  return data
}

// ============================================
// Admin Seat Management
// ============================================

// Get all seats for an event with stats
export async function getAdminSeats(eventId) {
  const { data: seats, error } = await supabase
    .from('seats')
    .select('*')
    .eq('event_id', eventId)
    .order('g_row', { ascending: true })
    .order('g_col', { ascending: true })

  if (error) throw error

  // Calculate stats by zone
  const stats = {}
  seats.forEach(seat => {
    if (!stats[seat.zone]) {
      stats[seat.zone] = { available: 0, reserved: 0, sold: 0, unavailable: 0, total: 0 }
    }
    stats[seat.zone][seat.status] = (stats[seat.zone][seat.status] || 0) + 1
    stats[seat.zone].total++
  })

  return { seats, stats }
}

// Update single seat status
export async function updateSeatStatus(seatId, status) {
  const updateData = { status }

  // If setting to available, clear reservation info
  if (status === 'available') {
    updateData.reservation_id = null
    updateData.locked_until = null
  }

  const { data, error } = await supabase
    .from('seats')
    .update(updateData)
    .eq('id', seatId)
    .select()
    .single()

  if (error) throw error
  return data
}

// Batch update seat status
export async function batchUpdateSeatStatus(seatIds, status) {
  const updateData = { status }

  if (status === 'available') {
    updateData.reservation_id = null
    updateData.locked_until = null
  }

  const { data, error } = await supabase
    .from('seats')
    .update(updateData)
    .in('id', seatIds)
    .select()

  if (error) throw error
  return data
}

// Batch update seat zone
export async function batchUpdateSeatZone(seatIds, zone) {
  const { data, error } = await supabase
    .from('seats')
    .update({ zone, updated_at: new Date().toISOString() })
    .in('id', seatIds)
    .select()

  if (error) throw error
  return data
}

// ============================================
// Admin Content Management
// ============================================

// Update chunwan settings
export async function updateChunwanSettings(settings) {
  // Get the current settings ID first
  const { data: current } = await supabase
    .from('chunwan_settings')
    .select('id')
    .maybeSingle()

  if (current) {
    const { data, error } = await supabase
      .from('chunwan_settings')
      .update({ ...settings, updated_at: new Date().toISOString() })
      .eq('id', current.id)
      .select()
      .single()

    if (error) throw error
    return data
  } else {
    const { data, error } = await supabase
      .from('chunwan_settings')
      .insert(settings)
      .select()
      .single()

    if (error) throw error
    return data
  }
}

// Get all sponsors (for admin)
export async function getAdminSponsors() {
  const { data, error } = await supabase
    .from('chunwan_sponsors')
    .select('*')
    .order('sort', { ascending: true })

  if (error) throw error
  return data
}

// Create sponsor
export async function createSponsor(sponsor) {
  const { data, error } = await supabase
    .from('chunwan_sponsors')
    .insert(sponsor)
    .select()
    .single()

  if (error) throw error
  return data
}

// Update sponsor
export async function updateSponsor(id, sponsor) {
  const { data, error } = await supabase
    .from('chunwan_sponsors')
    .update(sponsor)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// Delete sponsor
export async function deleteSponsor(id) {
  const { error } = await supabase
    .from('chunwan_sponsors')
    .delete()
    .eq('id', id)

  if (error) throw error
}

// Get all organizers (for admin)
export async function getAdminOrganizers() {
  const { data, error } = await supabase
    .from('chunwan_organizers')
    .select('*')
    .order('sort', { ascending: true })

  if (error) throw error
  return data
}

// Create organizer
export async function createOrganizer(organizer) {
  const { data, error } = await supabase
    .from('chunwan_organizers')
    .insert(organizer)
    .select()
    .single()

  if (error) throw error
  return data
}

// Update organizer
export async function updateOrganizer(id, organizer) {
  const { data, error } = await supabase
    .from('chunwan_organizers')
    .update(organizer)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// Delete organizer
export async function deleteOrganizer(id) {
  const { error } = await supabase
    .from('chunwan_organizers')
    .delete()
    .eq('id', id)

  if (error) throw error
}

// Get all events (for admin)
export async function getAdminEvents() {
  const { data, error } = await supabase
    .from('events')
    .select('*')
    .order('created_at', { ascending: false })

  if (error) throw error
  return data
}

// ============================================
// Admin Programs Management
// ============================================

// Get all programs (for admin)
export async function getAdminPrograms() {
  const { data, error } = await supabase
    .from('chunwan_programs')
    .select('*')
    .order('sort', { ascending: true })

  if (error) throw error
  return data
}

// Create program
export async function createProgram(program) {
  const { data, error } = await supabase
    .from('chunwan_programs')
    .insert(program)
    .select()
    .single()

  if (error) throw error
  return data
}

// Update program
export async function updateProgram(id, program) {
  const { data, error } = await supabase
    .from('chunwan_programs')
    .update(program)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// Delete program
export async function deleteProgram(id) {
  const { error } = await supabase
    .from('chunwan_programs')
    .delete()
    .eq('id', id)

  if (error) throw error
}

// ============================================
// Admin History Management
// ============================================

// Get all history items (for admin)
export async function getAdminHistory() {
  const { data, error } = await supabase
    .from('chunwan_history')
    .select('*')
    .order('year', { ascending: false })

  if (error) throw error
  return data
}

// Create history item
export async function createHistoryItem(item) {
  const { data, error } = await supabase
    .from('chunwan_history')
    .insert(item)
    .select()
    .single()

  if (error) throw error
  return data
}

// Update history item
export async function updateHistoryItem(id, item) {
  const { data, error } = await supabase
    .from('chunwan_history')
    .update(item)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data
}

// Delete history item
export async function deleteHistoryItem(id) {
  const { error } = await supabase
    .from('chunwan_history')
    .delete()
    .eq('id', id)

  if (error) throw error
}

