-- Add payment_message_id to track Gmail messages associated with payments
ALTER TABLE reservations 
ADD COLUMN IF NOT EXISTS payment_message_id TEXT;

-- Add a comment for documentation
COMMENT ON COLUMN reservations.payment_message_id IS 'Gmail message ID of the Interac payment notification';
