-- ==============================================================================
-- ADMIN USERS TABLE
-- For admin management page authentication
-- ==============================================================================

-- 1. Create admin_users table
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Create updated_at trigger
DROP TRIGGER IF EXISTS update_admin_users_updated_at ON admin_users;
CREATE TRIGGER update_admin_users_updated_at 
  BEFORE UPDATE ON admin_users 
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3. Enable RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies - Only select is allowed via anon key for login verification
DROP POLICY IF EXISTS "Allow select for login verification" ON admin_users;
CREATE POLICY "Allow select for login verification" ON admin_users 
  FOR SELECT USING (true);

-- 5. Add admin policies for CMS tables (update/insert/delete)
-- chunwan_settings
DROP POLICY IF EXISTS "Allow admin update on chunwan_settings" ON chunwan_settings;
CREATE POLICY "Allow admin update on chunwan_settings" ON chunwan_settings 
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin insert on chunwan_settings" ON chunwan_settings;
CREATE POLICY "Allow admin insert on chunwan_settings" ON chunwan_settings 
  FOR INSERT WITH CHECK (true);

-- chunwan_sponsors
DROP POLICY IF EXISTS "Allow public read on chunwan_sponsors" ON chunwan_sponsors;
CREATE POLICY "Allow public read on chunwan_sponsors" ON chunwan_sponsors 
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin update on chunwan_sponsors" ON chunwan_sponsors;
CREATE POLICY "Allow admin update on chunwan_sponsors" ON chunwan_sponsors 
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin insert on chunwan_sponsors" ON chunwan_sponsors;
CREATE POLICY "Allow admin insert on chunwan_sponsors" ON chunwan_sponsors 
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin delete on chunwan_sponsors" ON chunwan_sponsors;
CREATE POLICY "Allow admin delete on chunwan_sponsors" ON chunwan_sponsors 
  FOR DELETE USING (true);

-- chunwan_organizers
DROP POLICY IF EXISTS "Allow public read on chunwan_organizers" ON chunwan_organizers;
CREATE POLICY "Allow public read on chunwan_organizers" ON chunwan_organizers 
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin update on chunwan_organizers" ON chunwan_organizers;
CREATE POLICY "Allow admin update on chunwan_organizers" ON chunwan_organizers 
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin insert on chunwan_organizers" ON chunwan_organizers;
CREATE POLICY "Allow admin insert on chunwan_organizers" ON chunwan_organizers 
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin delete on chunwan_organizers" ON chunwan_organizers;
CREATE POLICY "Allow admin delete on chunwan_organizers" ON chunwan_organizers 
  FOR DELETE USING (true);

-- seats (for admin seat management)
DROP POLICY IF EXISTS "Allow admin update on seats" ON seats;
CREATE POLICY "Allow admin update on seats" ON seats 
  FOR UPDATE USING (true);

-- reservations (for admin order management)
DROP POLICY IF EXISTS "Allow admin update on reservations" ON reservations;
CREATE POLICY "Allow admin update on reservations" ON reservations 
  FOR UPDATE USING (true);

-- 6. Create admin login verification function
CREATE OR REPLACE FUNCTION verify_admin_login(
  p_email TEXT,
  p_password TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_admin admin_users%ROWTYPE;
BEGIN
  -- Find admin by email
  SELECT * INTO v_admin
  FROM admin_users
  WHERE email = p_email AND is_active = true;

  IF v_admin.id IS NULL THEN
    RETURN json_build_object('success', false, 'error', '账户不存在或已禁用');
  END IF;

  -- Verify password (using simple comparison for now, should use bcrypt in production)
  IF v_admin.password_hash = p_password THEN
    RETURN json_build_object(
      'success', true,
      'admin', json_build_object(
        'id', v_admin.id,
        'email', v_admin.email,
        'name', v_admin.name
      )
    );
  ELSE
    RETURN json_build_object('success', false, 'error', '密码错误');
  END IF;
END;
$$;

-- 7. Insert default admin user (password: admin123 - should be changed in production)
INSERT INTO admin_users (email, password_hash, name) 
VALUES ('admin@chunwan.com', 'admin123', '系统管理员')
ON CONFLICT (email) DO NOTHING;

-- Additional policies for programs management
DROP POLICY IF EXISTS "Allow public read on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow public read on chunwan_programs" ON chunwan_programs 
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow admin update on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow admin update on chunwan_programs" ON chunwan_programs 
  FOR UPDATE USING (true);

DROP POLICY IF EXISTS "Allow admin insert on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow admin insert on chunwan_programs" ON chunwan_programs 
  FOR INSERT WITH CHECK (true);

DROP POLICY IF EXISTS "Allow admin delete on chunwan_programs" ON chunwan_programs;
CREATE POLICY "Allow admin delete on chunwan_programs" ON chunwan_programs 
  FOR DELETE USING (true);
