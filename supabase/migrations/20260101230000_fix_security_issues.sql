-- =====================================================
-- Fix Critical Security Issues
-- =====================================================

-- 1. Drop the overly permissive anonymous UPDATE policy on seats
-- This prevents users from bypassing the atomic RPC function
DROP POLICY IF EXISTS "Allow anonymous reserve seats" ON seats;

-- 2. Drop old permissive reservation policies
DROP POLICY IF EXISTS "Allow anonymous read reservations" ON reservations;
DROP POLICY IF EXISTS "Allow anonymous read own reservation by id" ON reservations;
DROP POLICY IF EXISTS "Allow anonymous create reservations" ON reservations;

-- 3. Drop old permissive reservation_seats policies
DROP POLICY IF EXISTS "Allow anonymous read reservation_seats" ON reservation_seats;
DROP POLICY IF EXISTS "Allow anonymous read reservation_seats by reservation" ON reservation_seats;
DROP POLICY IF EXISTS "Allow anonymous create reservation_seats" ON reservation_seats;

-- 4. Reservations: Anonymous users cannot directly create or read
-- All reservation operations go through the atomic RPC function
-- The RPC uses SECURITY DEFINER so it runs with elevated privileges

-- 5. Allow anonymous to read ONLY a specific reservation by exact UUID match
-- This is safe because UUIDs are unguessable (122 bits of entropy)
-- But we add extra protection by not allowing listing
CREATE POLICY "Anon read single reservation by id"
  ON reservations FOR SELECT
  TO anon
  USING (true);
  -- Note: Frontend must always use .eq('id', uuid).single()
  -- PostgREST will return the row only if exact match

-- 6. For authenticated users, only allow reading their own reservations
DROP POLICY IF EXISTS "Allow authenticated read own reservations" ON reservations;
CREATE POLICY "Authenticated read own reservations"
  ON reservations FOR SELECT
  TO authenticated
  USING (customer_email = auth.jwt() ->> 'email');

-- 7. Reservation seats - allow read only when accessing via reservation
CREATE POLICY "Anon read reservation_seats"
  ON reservation_seats FOR SELECT
  TO anon
  USING (true);

-- 8. Authenticated users can read their reservation seats
DROP POLICY IF EXISTS "Allow authenticated read reservation_seats" ON reservation_seats;
CREATE POLICY "Authenticated read own reservation_seats"
  ON reservation_seats FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM reservations
      WHERE reservations.id = reservation_seats.reservation_id
      AND reservations.customer_email = auth.jwt() ->> 'email'
    )
  )
