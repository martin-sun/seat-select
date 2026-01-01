import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.VUE_APP_SUPABASE_URL
const supabaseAnonKey = process.env.VUE_APP_SUPABASE_ANON_KEY

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase environment variables. Please set VUE_APP_SUPABASE_URL and VUE_APP_SUPABASE_ANON_KEY in .env.local')
}

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

// Helper function to get event with seats
export async function getEventWithSeats (eventId) {
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
export async function createReservation ({ eventId, customerName, customerPhone, customerEmail, seatIds, totalAmount }) {
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
export async function getReservation (reservationId) {
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
export function subscribeToSeats (eventId, callback) {
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
export async function sendOtpToEmail (email) {
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
export async function verifyOtp (email, token) {
  const { data, error } = await supabase.auth.verifyOtp({
    email,
    token,
    type: 'email'
  })
  if (error) throw error
  return data
}

// Get current session
export async function getSession () {
  const { data: { session }, error } = await supabase.auth.getSession()
  if (error) throw error
  return session
}

// Sign out
export async function signOut () {
  const { error } = await supabase.auth.signOut()
  if (error) throw error
}

// Get reservations by email (for authenticated user)
export async function getReservationsByEmail (email) {
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
