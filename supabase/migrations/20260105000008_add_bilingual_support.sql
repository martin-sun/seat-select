-- Add English support to CMS tables

-- 1. chunwan_settings
ALTER TABLE chunwan_settings 
ADD COLUMN site_title_en TEXT,
ADD COLUMN event_theme_en TEXT,
ADD COLUMN event_date_en TEXT,
ADD COLUMN event_location_en TEXT,
ADD COLUMN event_address_en TEXT,
ADD COLUMN banner_title_en TEXT,
ADD COLUMN banner_subtitle_en TEXT,
ADD COLUMN about_content_en TEXT;

UPDATE chunwan_settings SET
  site_title_en = '2026 RBC New Year Night',
  event_theme_en = 'RBC New Year Night',
  event_date_en = 'February 14, 2026',
  event_location_en = 'Lakeview Church, Saskatoon',
  event_address_en = '1908 Lac La Ronge Dr, Saskatoon, SK S7K 5S1',
  banner_title_en = '2026 RBC New Year Night',
  banner_subtitle_en = '🏮 Saskatoon Spring Festival Gala 🏮',
  about_content_en = 'The 2026 Saskatoon Spring Festival Gala "RBC New Year Night" is officially launched! Sponsored by RBC Royal Bank of Canada, the event will be held on February 14, 2026, at Lakeview Church. Cultural activities and exhibitions from 2:00 PM to 6:30 PM, followed by the formal performance from 7:00 PM to 9:00 PM. We cordially invite you to celebrate the New Year together!'
WHERE site_title = '2026 RBC 新春之夜';

-- 2. chunwan_programs
ALTER TABLE chunwan_programs
ADD COLUMN title_en TEXT,
ADD COLUMN performers_en TEXT,
ADD COLUMN description_en TEXT;

-- Update sample programs
UPDATE chunwan_programs SET 
  title_en = 'Opening Dance: Prosperity',
  performers_en = 'Saskatoon Dance Group',
  description_en = 'Showcasing the magnificent dance of Chinese prosperity'
WHERE title = '开场舞：盛世欢腾';

-- 3. chunwan_tickets
ALTER TABLE chunwan_tickets
ADD COLUMN name_en TEXT,
ADD COLUMN description_en TEXT;

UPDATE chunwan_tickets SET
  name_en = 'VIP Seats',
  description_en = 'Front row view, includes exquisite souvenirs'
WHERE name = 'VIP 座位';

UPDATE chunwan_tickets SET
  name_en = 'Regular Section A',
  description_en = 'Comfortable middle seats, wide view'
WHERE name = '普通 A 区';

UPDATE chunwan_tickets SET
  name_en = 'Regular Section B',
  description_en = 'Economical choice in the back, high value'
WHERE name = '普通 B 区';

-- 4. chunwan_history
ALTER TABLE chunwan_history
ADD COLUMN title_en TEXT;

UPDATE chunwan_history SET title_en = '2025 Prosperity Spring Festival Gala' WHERE year = '2025';
UPDATE chunwan_history SET title_en = '2024 Vitality Spring Festival Gala' WHERE year = '2024';

-- 5. chunwan_sponsors
ALTER TABLE chunwan_sponsors
ADD COLUMN name_en TEXT;

UPDATE chunwan_sponsors SET name_en = 'RBC Royal Bank of Canada' WHERE name = 'RBC Royal Bank 加拿大皇家银行';
UPDATE chunwan_sponsors SET name_en = 'City of Saskatoon' WHERE name = 'City of Saskatoon';
UPDATE chunwan_sponsors SET name_en = 'Saskatchewan Lotteries' WHERE name = 'Saskatchewan Lotteries';
UPDATE chunwan_sponsors SET name_en = 'CIBC Bank' WHERE name = 'CIBC 银行';
UPDATE chunwan_sponsors SET name_en = 'BMW Saskatoon' WHERE name = 'BMW 宝马车行';
UPDATE chunwan_sponsors SET name_en = 'Lin & Tang Real Estate' WHERE name = '林与唐地产 (Lin & Tang Real Estate)';
UPDATE chunwan_sponsors SET name_en = 'Baydo Development Corporation' WHERE name = 'Baydo Development Corporation';
UPDATE chunwan_sponsors SET name_en = 'Zilongteng Restaurant' WHERE name = '紫龙腾酒家 (Zilongteng Restaurant)';
UPDATE chunwan_sponsors SET name_en = 'Dapeng Real Estate - Toronto' WHERE name = '大鹏地产-多伦多';
UPDATE chunwan_sponsors SET name_en = 'Reliance Real Estate Ottawa' WHERE name = '渥太华信实地产';
UPDATE chunwan_sponsors SET name_en = 'Saskatchewan Indian Gaming Authority' WHERE name = 'Saskatchewan Indian Gaming Authority';
UPDATE chunwan_sponsors SET name_en = 'Yijia Art & Victor Education' WHERE name = '艺佳美育和维克多教育';
UPDATE chunwan_sponsors SET name_en = 'SaskTel' WHERE name = 'SaskTel';
UPDATE chunwan_sponsors SET name_en = 'Encore Immigration' WHERE name = '安可移民';
UPDATE chunwan_sponsors SET name_en = 'Santa Lucia Pizza' WHERE name = 'Santa Lucia Pizza';
UPDATE chunwan_sponsors SET name_en = 'Mei Hao PGA Professional Golf Instructor' WHERE name = '郝梅 PGA 职业高尔夫教练';
UPDATE chunwan_sponsors SET name_en = 'Jincheng Immigration' WHERE name = '锦程移民';

-- 6. chunwan_organizers
ALTER TABLE chunwan_organizers
ADD COLUMN name_en TEXT,
ADD COLUMN description_en TEXT;

UPDATE chunwan_organizers SET name_en = 'Saskatoon Chinese Canadian Association' WHERE name = '萨斯卡通华人联合会';
UPDATE chunwan_organizers SET name_en = 'Saskatoon Chinese Language School' WHERE name = '萨斯卡通中文学校';
UPDATE chunwan_organizers SET name_en = 'University of Saskatchewan Chinese Students and Scholars Association' WHERE name = '萨省大学中国学生学者联谊会';
