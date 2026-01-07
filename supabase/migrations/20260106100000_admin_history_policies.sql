-- Add admin policies for chunwan_history management
DROP POLICY IF EXISTS "Allow admin update on chunwan_history" ON chunwan_history;
CREATE POLICY "Allow admin update on chunwan_history" ON chunwan_history 
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin insert on chunwan_history" ON chunwan_history;
CREATE POLICY "Allow admin insert on chunwan_history" ON chunwan_history 
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin delete on chunwan_history" ON chunwan_history;
CREATE POLICY "Allow admin delete on chunwan_history" ON chunwan_history 
  FOR DELETE USING (true);
