-- Add instruction_sent_at to track when payment instructions were sent
ALTER TABLE reservations ADD COLUMN IF NOT EXISTS instruction_sent_at TIMESTAMPTZ;
