-- Enable realtime for seats table (for real-time seat status updates)
ALTER PUBLICATION supabase_realtime ADD TABLE seats;

-- Enable realtime for reservations table (for payment status updates)
ALTER PUBLICATION supabase_realtime ADD TABLE reservations;
