-- ==============================================================================
-- TICKET CLERKS TABLE
-- For ticket clerk authentication and order pickup management
-- ==============================================================================

-- 1. Create ticket_clerks table
CREATE TABLE IF NOT EXISTS ticket_clerks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  name TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Create updated_at trigger
DROP TRIGGER IF EXISTS update_ticket_clerks_updated_at ON ticket_clerks;
CREATE TRIGGER update_ticket_clerks_updated_at
  BEFORE UPDATE ON ticket_clerks
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3. Enable RLS
ALTER TABLE ticket_clerks ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies for ticket_clerks
DROP POLICY IF EXISTS "Allow select for login verification" ON ticket_clerks;
CREATE POLICY "Allow select for login verification" ON ticket_clerks
  FOR SELECT USING (true);

-- 5. RLS Policies for reservations (ticket clerk access)
-- Allow ticket clerks to update picked_up status
DROP POLICY IF EXISTS "Allow ticket clerks to update picked_up status" ON reservations;
CREATE POLICY "Allow ticket clerks to update picked_up status" ON reservations
  FOR UPDATE USING (true)
  WITH CHECK (status IN ('paid', 'picked_up'));

-- Allow ticket clerks to read paid/picked_up reservations
DROP POLICY IF EXISTS "Allow ticket clerks to read paid/picked_up reservations" ON reservations;
CREATE POLICY "Allow ticket clerks to read paid/picked_up reservations" ON reservations
  FOR SELECT USING (status IN ('paid', 'picked_up'));

-- Allow ticket clerks to read related tables
DROP POLICY IF EXISTS "Allow ticket clerks to read events" ON events;
CREATE POLICY "Allow ticket clerks to read events" ON events
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow ticket clerks to read seats" ON seats;
CREATE POLICY "Allow ticket clerks to read seats" ON seats
  FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow ticket clerks to read reservation_seats" ON reservation_seats;
CREATE POLICY "Allow ticket clerks to read reservation_seats" ON reservation_seats
  FOR SELECT USING (true);

-- 6. Create ticket clerk login verification function
CREATE OR REPLACE FUNCTION verify_ticket_clerk_login(
  p_email TEXT,
  p_password TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_clerk ticket_clerks%ROWTYPE;
BEGIN
  -- Find clerk by email
  SELECT * INTO v_clerk
  FROM ticket_clerks
  WHERE email = p_email AND is_active = true;

  IF v_clerk.id IS NULL THEN
    RETURN json_build_object('success', false, 'error', '账户不存在或已禁用');
  END IF;

  -- Verify password
  IF v_clerk.password_hash = p_password THEN
    RETURN json_build_object(
      'success', true,
      'clerk', json_build_object(
        'id', v_clerk.id,
        'email', v_clerk.email,
        'name', v_clerk.name
      )
    );
  ELSE
    RETURN json_build_object('success', false, 'error', '密码错误');
  END IF;
END;
$$;

-- 7. Grant execute permission
GRANT EXECUTE ON FUNCTION verify_ticket_clerk_login(TEXT, TEXT) TO anon;
GRANT EXECUTE ON FUNCTION verify_ticket_clerk_login(TEXT, TEXT) TO authenticated;

-- 8. Insert default ticket clerk (password: clerk123 - should be changed in production)
INSERT INTO ticket_clerks (email, password_hash, name)
VALUES ('clerk@chunwan.com', 'clerk123', '取票管理员')
ON CONFLICT (email) DO NOTHING;
