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

// Helper function to create a reservation
export async function createReservation ({ eventId, customerName, customerPhone, customerEmail, seatIds, totalAmount }) {
  // Calculate expiry time (24 hours from now)
  const expiresAt = new Date()
  expiresAt.setHours(expiresAt.getHours() + 24)

  // Start a transaction-like operation
  // 1. Create reservation
  const { data: reservation, error: reservationError } = await supabase
    .from('reservations')
    .insert({
      event_id: eventId,
      customer_name: customerName,
      customer_phone: customerPhone,
      customer_email: customerEmail,
      total_amount: totalAmount,
      status: 'pending',
      expires_at: expiresAt.toISOString()
    })
    .select()
    .single()

  if (reservationError) throw reservationError

  // 2. Create reservation_seats entries
  const reservationSeats = seatIds.map(seatId => ({
    reservation_id: reservation.id,
    seat_id: seatId
  }))

  const { error: seatsLinkError } = await supabase
    .from('reservation_seats')
    .insert(reservationSeats)

  if (seatsLinkError) {
    // Rollback: delete the reservation
    await supabase.from('reservations').delete().eq('id', reservation.id)
    throw seatsLinkError
  }

  // 3. Update seats status to 'reserved'
  const { error: seatsUpdateError } = await supabase
    .from('seats')
    .update({
      status: 'reserved',
      reservation_id: reservation.id,
      locked_until: expiresAt.toISOString()
    })
    .in('id', seatIds)

  if (seatsUpdateError) {
    // Rollback
    await supabase.from('reservation_seats').delete().eq('reservation_id', reservation.id)
    await supabase.from('reservations').delete().eq('id', reservation.id)
    throw seatsUpdateError
  }

  return reservation
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
