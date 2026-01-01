-- Add RLS policies for authenticated users

-- Reservations: Allow authenticated users to read their own reservations
CREATE POLICY "Allow authenticated read own reservations"
  ON reservations FOR SELECT
  TO authenticated
  USING (customer_email = auth.jwt() ->> 'email');

-- Reservation seats: Allow authenticated users to read reservation seats for their reservations
CREATE POLICY "Allow authenticated read reservation_seats"
  ON reservation_seats FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM reservations
      WHERE reservations.id = reservation_seats.reservation_id
      AND reservations.customer_email = auth.jwt() ->> 'email'
    )
  );

-- Events: Allow authenticated users to read events
CREATE POLICY "Allow authenticated read events"
  ON events FOR SELECT
  TO authenticated
  USING (true);

-- Seats: Allow authenticated users to read seats
CREATE POLICY "Allow authenticated read seats"
  ON seats FOR SELECT
  TO authenticated
  USING (true);
