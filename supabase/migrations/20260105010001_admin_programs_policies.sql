-- Additional admin policies for programs management
DROP POLICY IF EXISTS "Allow admin update on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow admin update on chunwan_programs" ON chunwan_programs 
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin insert on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow admin insert on chunwan_programs" ON chunwan_programs 
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin delete on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow admin delete on chunwan_programs" ON chunwan_programs 
  FOR DELETE USING (true);
