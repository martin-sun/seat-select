-- Migration to add 'picked_up' status to reservations
-- This updates the check constraint on the status column

ALTER TABLE reservations 
DROP CONSTRAINT IF EXISTS reservations_status_check;

ALTER TABLE reservations
ADD CONSTRAINT reservations_status_check 
CHECK (status IN ('pending', 'paid', 'expired', 'cancelled', 'picked_up'));
