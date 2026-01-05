-- Add Sponsors and Organizers tables
CREATE TABLE IF NOT EXISTS chunwan_sponsors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  level TEXT, -- e.g., 'title', 'gold', 'silver', 'bronze'
  logo_url TEXT,
  website_url TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chunwan_organizers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  type TEXT, -- 'organizer', 'co-organizer', 'supporter'
  logo_url TEXT,
  description TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE chunwan_sponsors ENABLE ROW LEVEL SECURITY;
ALTER TABLE chunwan_organizers ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read on chunwan_sponsors" ON chunwan_sponsors FOR SELECT USING (true);
CREATE POLICY "Allow public read on chunwan_organizers" ON chunwan_organizers FOR SELECT USING (true);

-- Update Settings with real 2026 data
UPDATE chunwan_settings SET
  site_title = '2026 RBC 新春之夜',
  event_year = '2026',
  event_theme = 'RBC 新春之夜',
  event_date = '2026年2月14日',
  event_location = 'Lakeview Church, Saskatoon',
  event_address = '1908 Lac La Ronge Dr, Saskatoon, SK S7K 5S1',
  banner_title = '2026 RBC 新春之夜',
  banner_subtitle = '🏮 萨斯卡通春晚 🏮',
  about_content = '2026年萨斯卡通春晚“RBC新春之夜”正式启动！本次活动由RBC加拿大皇家银行冠名赞助，将于2026年2月14日在Lakeview Church隆重举行。下午2点至6点半为游园活动和文化展示，晚上7点至9点为正式演出。诚邀各界共庆新春！',
  show_programs_link = true
WHERE id = (SELECT id FROM chunwan_settings LIMIT 1);

-- Insert Real Sponsors
INSERT INTO chunwan_sponsors (name, level, sort) VALUES
('RBC Royal Bank 加拿大皇家银行', 'title', 1),
('City of Saskatoon', 'gold', 2),
('Saskatchewan Lotteries', 'gold', 3),
('CIBC 银行', 'silver', 4),
('BMW 宝马车行', 'silver', 5),
('林与唐地产 (Lin & Tang Real Estate)', 'silver', 6),
('Baydo Development Corporation', 'silver', 7),
('紫龙腾酒家 (Zilongteng Restaurant)', 'silver', 8),
('大鹏地产-多伦多', 'bronze', 9),
('渥太华信实地产', 'bronze', 10),
('Saskatchewan Indian Gaming Authority', 'bronze', 11),
('艺佳美育和维克多教育', 'bronze', 12),
('SaskTel', 'bronze', 13),
('安可移民', 'bronze', 14),
('Santa Lucia Pizza', 'bronze', 15),
('郝梅 PGA 职业高尔夫教练', 'bronze', 16),
('锦程移民', 'bronze', 17);

-- Insert Organizers (Sample - based on common Saskatoon community groups)
INSERT INTO chunwan_organizers (name, type, sort) VALUES
('萨斯卡通华人联合会', 'organizer', 1),
('萨斯卡通中文学校', 'co-organizer', 2),
('萨省大学中国学生学者联谊会', 'co-organizer', 3);
