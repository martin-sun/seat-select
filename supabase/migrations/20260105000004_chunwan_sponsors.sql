-- 1. Create table
CREATE TABLE IF NOT EXISTS chunwan_sponsors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_en TEXT,
  level TEXT, -- e.g., 'title', 'gold', 'silver', 'bronze'
  logo_url TEXT,
  website_url TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE chunwan_sponsors ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy
CREATE POLICY "Allow public read on chunwan_sponsors" ON chunwan_sponsors FOR SELECT USING (true);

-- 4. Insert Data
DELETE FROM chunwan_sponsors;
INSERT INTO chunwan_sponsors (name, name_en, level, sort) VALUES
('RBC Royal Bank 加拿大皇家银行', 'RBC Royal Bank of Canada', 'title', 1),
('City of Saskatoon', 'City of Saskatoon', 'gold', 2),
('Saskatchewan Lotteries', 'Saskatchewan Lotteries', 'gold', 3),
('CIBC 银行', 'CIBC Bank', 'silver', 4),
('BMW 宝马车行', 'BMW Saskatoon', 'silver', 5),
('林与唐地产 (Lin & Tang Real Estate)', 'Lin & Tang Real Estate', 'silver', 6),
('Baydo Development Corporation', 'Baydo Development Corporation', 'silver', 7),
('紫龙腾酒家 (Zilongteng Restaurant)', 'Zilongteng Restaurant', 'silver', 8),
('大鹏地产-多伦多', 'Dapeng Real Estate - Toronto', 'bronze', 9),
('渥太华信实地产', 'Reliance Real Estate Ottawa', 'bronze', 10),
('Saskatchewan Indian Gaming Authority', 'Saskatchewan Indian Gaming Authority', 'bronze', 11),
('艺佳美育和维克多教育', 'Yijia Art & Victor Education', 'bronze', 12),
('SaskTel', 'SaskTel', 'bronze', 13),
('安可移民', 'Encore Immigration', 'bronze', 14),
('Santa Lucia Pizza', 'Santa Lucia Pizza', 'bronze', 15),
('郝梅 PGA 职业高尔夫教练', 'Mei Hao PGA Professional Golf Instructor', 'bronze', 16),
('锦程移民', 'Jincheng Immigration', 'bronze', 17);
