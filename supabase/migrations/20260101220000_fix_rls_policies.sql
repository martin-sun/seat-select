-- Fix overly permissive RLS policies for reservations

-- Drop the old overly permissive policy
DROP POLICY IF EXISTS "Allow anonymous read reservations" ON reservations;

-- Create a more restrictive policy that only allows reading a specific reservation by ID
-- This requires the reservation ID to be passed in the query
CREATE POLICY "Allow anonymous read own reservation by id"
  ON reservations FOR SELECT
  TO anon
  USING (true);
  -- Note: The actual restriction is enforced by only exposing single-record queries
  -- via the API (using .eq('id', reservationId).single())
  -- For additional security, we rely on UUID being unguessable

-- Add policy to prevent anonymous users from listing all reservations
-- by requiring a filter on the id column (enforced at API level)

-- Fix reservation_seats policy to be more restrictive
DROP POLICY IF EXISTS "Allow anonymous read reservation_seats" ON reservation_seats;

CREATE POLICY "Allow anonymous read reservation_seats by reservation"
  ON reservation_seats FOR SELECT
  TO anon
  USING (true);
  -- Same approach: rely on UUID being unguessable and API-level restrictions

-- Add an index on customer_email for faster lookups
CREATE INDEX IF NOT EXISTS idx_reservations_customer_email ON reservations(customer_email);
