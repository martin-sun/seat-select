-- Create cancel_reservation RPC function
-- This function ensures that only the reservation owner can cancel their own pending reservation
-- and releases the seats atomically

CREATE OR REPLACE FUNCTION cancel_reservation(
  p_reservation_id UUID,
  p_user_email TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_reservation RECORD;
  v_result JSON;
BEGIN
  -- Get the reservation and verify ownership
  SELECT * INTO v_reservation
  FROM reservations
  WHERE id = p_reservation_id;

  -- Check if reservation exists
  IF NOT FOUND THEN
    v_result := json_build_object(
      'success', false,
      'error', 'Reservation not found'
    );
    RETURN v_result;
  END IF;

  -- Verify ownership (email must match)
  IF v_reservation.customer_email != p_user_email THEN
    v_result := json_build_object(
      'success', false,
      'error', 'You do not have permission to cancel this reservation'
    );
    RETURN v_result;
  END IF;

  -- Only allow cancellation of pending reservations
  IF v_reservation.status != 'pending' THEN
    v_result := json_build_object(
      'success', false,
      'error', 'Only pending reservations can be cancelled'
    );
    RETURN v_result;
  END IF;

  -- Update reservation status to cancelled
  UPDATE reservations
  SET status = 'cancelled',
      updated_at = NOW()
  WHERE id = p_reservation_id;

  -- Release the seats
  UPDATE seats
  SET status = 'available',
      reservation_id = NULL,
      locked_until = NULL,
      updated_at = NOW()
  WHERE reservation_id = p_reservation_id;

  -- Return success
  v_result := json_build_object(
    'success', true,
    'reservation_id', p_reservation_id
  );

  RETURN v_result;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION cancel_reservation(UUID, TEXT) TO authenticated;
GRANT EXECUTE ON FUNCTION cancel_reservation(UUID, TEXT) TO anon;
