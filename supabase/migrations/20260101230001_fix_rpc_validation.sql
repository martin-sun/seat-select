-- =====================================================
-- Fix RPC Function: Add proper validation
-- =====================================================

CREATE OR REPLACE FUNCTION create_reservation_atomic(
  p_event_id UUID,
  p_customer_name TEXT,
  p_customer_phone TEXT,
  p_customer_email TEXT,
  p_seat_ids TEXT[],
  p_total_amount DECIMAL(10,2)
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_reservation_id UUID;
  v_expires_at TIMESTAMPTZ;
  v_unavailable_seats TEXT[];
  v_invalid_seats TEXT[];
  v_max_seats INT;
  v_seat_count INT;
  v_result JSON;
BEGIN
  -- Validate input
  IF p_seat_ids IS NULL OR array_length(p_seat_ids, 1) IS NULL OR array_length(p_seat_ids, 1) = 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'No seats selected'
    );
  END IF;

  -- Get event max_seats_per_booking
  SELECT max_seats_per_booking INTO v_max_seats
  FROM events
  WHERE id = p_event_id AND is_active = true;

  IF v_max_seats IS NULL THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Event not found or not active'
    );
  END IF;

  -- Check seat count against max allowed
  v_seat_count := array_length(p_seat_ids, 1);
  IF v_seat_count > v_max_seats THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Exceeds maximum seats per booking (' || v_max_seats || ')',
      'max_seats', v_max_seats,
      'requested', v_seat_count
    );
  END IF;

  -- Verify all seats belong to the specified event
  SELECT ARRAY_AGG(id) INTO v_invalid_seats
  FROM unnest(p_seat_ids) AS requested_id
  WHERE NOT EXISTS (
    SELECT 1 FROM seats
    WHERE seats.id = requested_id
    AND seats.event_id = p_event_id
  );

  IF v_invalid_seats IS NOT NULL AND array_length(v_invalid_seats, 1) > 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Some seats do not belong to this event',
      'invalid_seats', v_invalid_seats
    );
  END IF;

  -- Calculate expiry time (24 hours from now)
  v_expires_at := now() + INTERVAL '24 hours';

  -- Check if all seats are available (with FOR UPDATE to lock rows)
  SELECT ARRAY_AGG(id) INTO v_unavailable_seats
  FROM seats
  WHERE id = ANY(p_seat_ids)
    AND status != 'available'
  FOR UPDATE;

  -- If any seats are not available, return error
  IF v_unavailable_seats IS NOT NULL AND array_length(v_unavailable_seats, 1) > 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Some seats are no longer available',
      'unavailable_seats', v_unavailable_seats
    );
  END IF;

  -- Lock the available seats to prevent concurrent bookings
  PERFORM id FROM seats
  WHERE id = ANY(p_seat_ids)
    AND status = 'available'
  FOR UPDATE NOWAIT;

  -- Create the reservation
  INSERT INTO reservations (
    event_id,
    customer_name,
    customer_phone,
    customer_email,
    total_amount,
    status,
    expires_at
  ) VALUES (
    p_event_id,
    p_customer_name,
    p_customer_phone,
    p_customer_email,
    p_total_amount,
    'pending',
    v_expires_at
  )
  RETURNING id INTO v_reservation_id;

  -- Create reservation_seats entries
  INSERT INTO reservation_seats (reservation_id, seat_id)
  SELECT v_reservation_id, unnest(p_seat_ids);

  -- Update seats status to 'reserved'
  UPDATE seats
  SET
    status = 'reserved',
    reservation_id = v_reservation_id,
    locked_until = v_expires_at,
    updated_at = now()
  WHERE id = ANY(p_seat_ids);

  -- Return success with reservation details
  SELECT json_build_object(
    'success', true,
    'reservation', json_build_object(
      'id', r.id,
      'event_id', r.event_id,
      'customer_name', r.customer_name,
      'customer_phone', r.customer_phone,
      'customer_email', r.customer_email,
      'total_amount', r.total_amount,
      'status', r.status,
      'expires_at', r.expires_at,
      'created_at', r.created_at
    )
  ) INTO v_result
  FROM reservations r
  WHERE r.id = v_reservation_id;

  RETURN v_result;

EXCEPTION
  WHEN lock_not_available THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Seats are being booked by another user. Please try again.'
    );
  WHEN OTHERS THEN
    RETURN json_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$
