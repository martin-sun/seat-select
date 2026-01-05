-- 1. Create table
CREATE TABLE IF NOT EXISTS chunwan_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  year TEXT,
  title TEXT,
  title_en TEXT,
  thumbnail TEXT,
  video_url TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE chunwan_history ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy
CREATE POLICY "Allow public read on chunwan_history" ON chunwan_history FOR SELECT USING (true);

-- 4. Insert Data
DELETE FROM chunwan_history;
INSERT INTO chunwan_history (year, title, title_en, sort) VALUES 
('2025', '2025 龙腾盛世春晚', '2025 Prosperity Spring Festival Gala', 1),
('2024', '2024 龙马精神春晚', '2024 Vitality Spring Festival Gala', 2);
