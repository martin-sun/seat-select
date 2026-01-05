-- Create CMS Tables for Homepage Content
CREATE TABLE IF NOT EXISTS chunwan_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  site_title TEXT,
  event_year TEXT,
  event_theme TEXT,
  event_date TEXT,
  event_location TEXT,
  event_address TEXT,
  banner_title TEXT,
  banner_subtitle TEXT,
  about_content TEXT,
  show_programs_link BOOLEAN DEFAULT false,
  banner_image TEXT,
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chunwan_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  type TEXT,
  performers TEXT,
  description TEXT,
  thumbnail TEXT,
  sort INTEGER DEFAULT 0,
  status TEXT DEFAULT 'published',
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chunwan_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  price DECIMAL(10,2),
  description TEXT,
  available BOOLEAN DEFAULT true,
  color TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS chunwan_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  year TEXT,
  title TEXT,
  thumbnail TEXT,
  video_url TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS (Row Level Security) - Allow public read for these CMS tables
ALTER TABLE chunwan_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE chunwan_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE chunwan_tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE chunwan_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow public read on chunwan_settings" ON chunwan_settings FOR SELECT USING (true);
CREATE POLICY "Allow public read on chunwan_programs" ON chunwan_programs FOR SELECT USING (true);
CREATE POLICY "Allow public read on chunwan_tickets" ON chunwan_tickets FOR SELECT USING (true);
CREATE POLICY "Allow public read on chunwan_history" ON chunwan_history FOR SELECT USING (true);

-- Insert Mock Data
INSERT INTO chunwan_settings (site_title, event_year, event_theme, event_date, event_location, event_address, banner_title, banner_subtitle, about_content, show_programs_link)
VALUES (
  '2026 萨斯卡通春晚',
  '2026',
  '蛇年大吉',
  '2026年1月25日 18:00',
  'Saskatoon Hall',
  '123 Main St, Saskatoon, SK',
  '2026 萨斯卡通春节联欢晚会',
  '欢度佳节，共庆新春',
  '这是一场汇聚了当地华人艺术精英的盛会，旨在弘扬中华传统文化，丰富萨斯卡通华人社区的文化生活。今年我们将带来更加精彩的节目，诚邀您共度佳节！',
  true
);

INSERT INTO chunwan_tickets (name, price, color, description, sort)
VALUES 
('VIP 座位', 50.00, '#DC2626', '前排绝佳视野，含精美纪念品', 1),
('普通 A 区', 30.00, '#EC4899', '中部舒适座位，视野开阔', 2),
('普通 B 区', 20.00, '#7C3AED', '后排经济选择，性价比高', 3);

INSERT INTO chunwan_programs (title, type, performers, description, sort)
VALUES 
('开场舞：盛世欢腾', 'dance', '萨斯卡通舞蹈团', '展示中华盛世的壮丽舞姿', 1),
('小品：异国他乡', 'skit', '华人小品社', '讲述留学生在萨省的趣闻乐事', 2),
('歌曲：我和我的祖国', 'song', '张三', '深情演唱，表达对祖国的热爱', 3),
('武术表演：功夫魂', 'acrobatics', '少年武术队', '刚劲有力的武术套路展示', 4);

INSERT INTO chunwan_history (year, title, sort)
VALUES 
('2025', '2025 龙腾盛世春晚', 1),
('2024', '2024 龙马精神春晚', 2);
