-- Add preferred_language column to reservations table
-- This stores the user's language preference at the time of reservation creation
-- Used for sending emails in the correct language

ALTER TABLE reservations ADD COLUMN IF NOT EXISTS preferred_language TEXT DEFAULT 'en-US';

COMMENT ON COLUMN reservations.preferred_language IS 'User''s preferred language for email communications (en-US, zh-CN, etc.)';
