-- 1. Create table
CREATE TABLE IF NOT EXISTS chunwan_programs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  title_en TEXT,
  type TEXT,
  performers TEXT,
  performers_en TEXT,
  description TEXT,
  description_en TEXT,
  thumbnail TEXT,
  sort INTEGER DEFAULT 0,
  status TEXT DEFAULT 'published',
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE chunwan_programs ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy
CREATE POLICY "Allow public read on chunwan_programs" ON chunwan_programs FOR SELECT USING (true);

-- 4. Insert Data
DELETE FROM chunwan_programs;
INSERT INTO chunwan_programs (title, title_en, type, performers, performers_en, description, description_en, sort) VALUES 
('开场舞：盛世欢腾', 'Opening Dance: Prosperity', 'dance', '萨斯卡通舞蹈团', 'Saskatoon Dance Group', '展示中华盛世的壮丽舞姿', 'Showcasing the magnificent dance of Chinese prosperity', 1),
('小品：异国他乡', NULL, 'skit', '华人小品社', NULL, '讲述留学生在萨省的趣闻乐事', NULL, 2),
('歌曲：我和我的祖国', NULL, 'song', '张三', NULL, '深情演唱，表达对祖国的热爱', NULL, 3),
('武术表演：功夫魂', NULL, 'acrobatics', '少年武术队', NULL, '刚劲有力的武术套路展示', NULL, 4);
