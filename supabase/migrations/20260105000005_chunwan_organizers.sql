-- 1. Create table
CREATE TABLE IF NOT EXISTS chunwan_organizers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_en TEXT,
  type TEXT, -- 'organizer', 'co-organizer', 'supporter'
  logo_url TEXT,
  description TEXT,
  description_en TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE chunwan_organizers ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy
CREATE POLICY "Allow public read on chunwan_organizers" ON chunwan_organizers FOR SELECT USING (true);

-- 4. Insert Data (Cleaned)
DELETE FROM chunwan_organizers;
INSERT INTO chunwan_organizers (name, name_en, type, sort) VALUES
('萨省中国舞蹈学校', 'Saskatchewan Chinese Dance School', 'organizer', 1),
('春之声合唱团', 'Voice of Spring Choir', 'organizer', 2),
('加拿大育才学校', 'Canada Yucai School', 'organizer', 3),
('海外新生活', 'Overseas New Life', 'co-organizer', 4);
