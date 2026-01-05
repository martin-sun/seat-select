-- ==============================================================================
-- BASE SYSTEM MIGRATION (CONSOLIDATED)
-- Includes: Events, Reservations, Seats, Indexes, RLS Policies, Booking RPC
-- ==============================================================================

-- 1. Create Tables
CREATE TABLE IF NOT EXISTS events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  hall_name TEXT,
  show_time TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT true,
  zone_prices JSONB NOT NULL DEFAULT '{}',
  zone_config JSONB NOT NULL DEFAULT '[]',
  max_seats_per_booking INT DEFAULT 4,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reservations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_email TEXT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'paid', 'expired', 'cancelled')),
  expires_at TIMESTAMPTZ NOT NULL,
  payment_confirmed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS seats (
  id TEXT PRIMARY KEY,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  row TEXT NOT NULL,
  col TEXT NOT NULL,
  g_row INT NOT NULL,
  g_col INT NOT NULL,
  zone TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'available' CHECK (status IN ('available', 'reserved', 'sold', 'unavailable')),
  locked_until TIMESTAMPTZ,
  reservation_id UUID REFERENCES reservations(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reservation_seats (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reservation_id UUID NOT NULL REFERENCES reservations(id) ON DELETE CASCADE,
  seat_id TEXT NOT NULL REFERENCES seats(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(reservation_id, seat_id)
);

-- 2. Create Indexes
CREATE INDEX IF NOT EXISTS idx_seats_event_id ON seats(event_id);
CREATE INDEX IF NOT EXISTS idx_seats_status ON seats(status);
CREATE INDEX IF NOT EXISTS idx_seats_event_status ON seats(event_id, status);
CREATE INDEX IF NOT EXISTS idx_reservations_event_id ON reservations(event_id);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_expires_at ON reservations(expires_at);
CREATE INDEX IF NOT EXISTS idx_reservation_seats_reservation_id ON reservation_seats(reservation_id);
CREATE INDEX IF NOT EXISTS idx_reservation_seats_seat_id ON reservation_seats(seat_id);

-- 3. Triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_events_updated_at ON events;
CREATE TRIGGER update_events_updated_at BEFORE UPDATE ON events FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_reservations_updated_at ON reservations;
CREATE TRIGGER update_reservations_updated_at BEFORE UPDATE ON reservations FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_seats_updated_at ON seats;
CREATE TRIGGER update_seats_updated_at BEFORE UPDATE ON seats FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 4. Enable RLS
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservation_seats ENABLE ROW LEVEL SECURITY;

-- 5. RLS Policies
-- Events: Public read
DROP POLICY IF EXISTS "Enable read access for all users" ON events;
CREATE POLICY "Enable read access for all users" ON events FOR SELECT USING (true);

-- Seats: Public read
DROP POLICY IF EXISTS "Enable read access for all users" ON seats;
CREATE POLICY "Enable read access for all users" ON seats FOR SELECT USING (true);

-- Reservations: Users can select their own reservations (by email matching or some logic, currently basic)
-- For this simplified version, we allow public insert but restricted select/update needs care.
-- (Adopting the rules from 20260101184513_create_rls_policies.sql and subsequent fixes)

DROP POLICY IF EXISTS "Enable insert access for all users" ON reservations;
CREATE POLICY "Enable insert access for all users" ON reservations FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable read access for own reservations" ON reservations;
CREATE POLICY "Enable read access for own reservations" ON reservations FOR SELECT USING (true); 
-- Note: In a real app you might restricting this more, but adhering to previous behavior for now.

DROP POLICY IF EXISTS "Enable insert access for all users" ON reservation_seats;
CREATE POLICY "Enable insert access for all users" ON reservation_seats FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Enable read access for all users" ON reservation_seats;
CREATE POLICY "Enable read access for all users" ON reservation_seats FOR SELECT USING (true);

-- 6. Booking RPC (Atomic Transaction)
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
  SELECT ARRAY_AGG(requested_id) INTO v_invalid_seats
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

  -- Lock the seats first to prevent concurrent bookings
  PERFORM id FROM seats
  WHERE id = ANY(p_seat_ids)
  FOR UPDATE NOWAIT;

  -- Check if all seats are available
  SELECT ARRAY_AGG(id) INTO v_unavailable_seats
  FROM seats
  WHERE id = ANY(p_seat_ids)
    AND status != 'available';

  -- If any seats are not available, return error
  IF v_unavailable_seats IS NOT NULL AND array_length(v_unavailable_seats, 1) > 0 THEN
    RETURN json_build_object(
      'success', false,
      'error', 'Some seats are no longer available',
      'unavailable_seats', v_unavailable_seats
    );
  END IF;

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
$$;
