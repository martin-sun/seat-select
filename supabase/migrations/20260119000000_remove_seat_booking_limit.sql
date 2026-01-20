-- ==============================================================================
-- REMOVE SEAT BOOKING LIMIT
-- Changes default max_seats_per_booking from 4 to 999 (effectively unlimited)
-- ==============================================================================

-- Alter the default value for new events
ALTER TABLE events
  ALTER COLUMN max_seats_per_booking SET DEFAULT 999;

-- Update existing events to have the new higher limit
UPDATE events
SET max_seats_per_booking = 999
WHERE max_seats_per_booking = 4;
