-- Enable Row Level Security on all tables
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE seats ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE reservation_seats ENABLE ROW LEVEL SECURITY;

-- Events: Allow anonymous read for active events
CREATE POLICY "Allow anonymous read active events"
  ON events FOR SELECT
  TO anon
  USING (is_active = true);

-- Seats: Allow anonymous read
CREATE POLICY "Allow anonymous read seats"
  ON seats FOR SELECT
  TO anon
  USING (true);

-- Reservations: Allow anonymous to create reservations
CREATE POLICY "Allow anonymous create reservations"
  ON reservations FOR INSERT
  TO anon
  WITH CHECK (true);

-- Reservations: Allow anonymous to read their own reservations (by id in URL)
CREATE POLICY "Allow anonymous read reservations"
  ON reservations FOR SELECT
  TO anon
  USING (true);

-- Reservation seats: Allow anonymous to create
CREATE POLICY "Allow anonymous create reservation_seats"
  ON reservation_seats FOR INSERT
  TO anon
  WITH CHECK (true);

-- Reservation seats: Allow anonymous to read
CREATE POLICY "Allow anonymous read reservation_seats"
  ON reservation_seats FOR SELECT
  TO anon
  USING (true);

-- Seats: Allow anonymous to update seat status (for reservations)
-- Only allow changing from 'available' to 'reserved'
CREATE POLICY "Allow anonymous reserve seats"
  ON seats FOR UPDATE
  TO anon
  USING (status = 'available')
  WITH CHECK (status = 'reserved');

-- Service role policies (for backend Celery tasks)
-- These allow the service role full access

CREATE POLICY "Service role full access events"
  ON events FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access seats"
  ON seats FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access reservations"
  ON reservations FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Service role full access reservation_seats"
  ON reservation_seats FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
