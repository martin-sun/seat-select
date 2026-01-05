-- 1. Create table
CREATE TABLE IF NOT EXISTS chunwan_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_title TEXT,
  site_title_en TEXT,
  event_year TEXT,
  event_theme TEXT,
  event_theme_en TEXT,
  event_date TEXT,
  event_date_en TEXT,
  event_location TEXT,
  event_location_en TEXT,
  event_address TEXT,
  event_address_en TEXT,
  banner_title TEXT,
  banner_title_en TEXT,
  banner_subtitle TEXT,
  banner_subtitle_en TEXT,
  about_content TEXT,
  about_content_en TEXT,
  show_programs_link BOOLEAN DEFAULT false,
  banner_image TEXT,
  contact_email TEXT,
  facebook_url TEXT,
  twitter_url TEXT,
  youtube_url TEXT,
  instagram_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE chunwan_settings ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy
CREATE POLICY "Allow public read on chunwan_settings" ON chunwan_settings FOR SELECT USING (true);

-- 4. Insert Data (Cleaned and Merged)
DELETE FROM chunwan_settings;
INSERT INTO chunwan_settings (
  site_title, site_title_en,
  event_year,
  event_theme, event_theme_en,
  event_date, event_date_en,
  event_location, event_location_en,
  event_address, event_address_en,
  banner_title, banner_title_en,
  banner_subtitle, banner_subtitle_en,
  about_content, about_content_en,
  show_programs_link,
  contact_email,
  facebook_url,
  youtube_url
) VALUES (
  '2026年RBC新春之夜萨斯卡通春晚', '2026 RBC New Year Night',
  '2026',
  'RBC 新春之夜', 'RBC New Year Night',
  '2026年2月14日', 'February 14, 2026',
  'Lakeview Church, Saskatoon', 'Lakeview Church, Saskatoon',
  '1908 Lac La Ronge Dr, Saskatoon, SK S7K 5S1', '1908 Lac La Ronge Dr, Saskatoon, SK S7K 5S1',
  '2026 RBC 新春之夜', '2026 RBC New Year Night',
  '🏮 萨斯卡通春晚 🏮', '🏮 Saskatoon Spring Festival Gala 🏮',
  '2026年萨斯卡通春晚“RBC新春之夜”正式启动！本次活动由RBC加拿大皇家银行冠名赞助，将于2026年2月14日在Lakeview Church隆重举行。下午2点至6点半为游园活动和文化展示，晚上7点至9点为正式演出。诚邀各界共庆新春！', 
  'The 2026 Saskatoon Spring Festival Gala "RBC New Year Night" is officially launched! Sponsored by RBC Royal Bank of Canada, the event will be held on February 14, 2026, at Lakeview Church. Cultural activities and exhibitions from 2:00 PM to 6:30 PM, followed by the formal performance from 7:00 PM to 9:00 PM. We cordially invite you to celebrate the New Year together!',
  true,
  'saskatoonsfc@gmail.com',
  'https://www.facebook.com/saskatoonchunwan',
  'https://www.youtube.com/@saskatoonchunwan'
);
