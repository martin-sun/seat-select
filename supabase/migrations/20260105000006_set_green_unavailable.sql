-- Migration to update Green Zone seats to 'unavailable' status

-- First, update the check constraint to allow 'unavailable' status
ALTER TABLE seats DROP CONSTRAINT IF EXISTS seats_status_check;
ALTER TABLE seats ADD CONSTRAINT seats_status_check
  CHECK (status IN ('available', 'reserved', 'sold', 'unavailable'));

-- Now update the seats
UPDATE seats
SET status = 'unavailable'
WHERE zone = 'green';
