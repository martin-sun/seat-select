-- 1. Create table
CREATE TABLE IF NOT EXISTS chunwan_tickets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_en TEXT,
  price DECIMAL(10,2),
  description TEXT,
  description_en TEXT,
  available BOOLEAN DEFAULT true,
  color TEXT,
  sort INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE chunwan_tickets ENABLE ROW LEVEL SECURITY;

-- 3. Create Policy
CREATE POLICY "Allow public read on chunwan_tickets" ON chunwan_tickets FOR SELECT USING (true);

-- 4. Insert Data
DELETE FROM chunwan_tickets;
INSERT INTO chunwan_tickets (name, name_en, price, color, description, description_en, sort) VALUES 
('VIP 座位', 'VIP Seats', 50.00, '#DC2626', '前排绝佳视野，含精美纪念品', 'Front row view, includes exquisite souvenirs', 1),
('普通 A 区', 'Regular Section A', 30.00, '#EC4899', '中部舒适座位，视野开阔', 'Comfortable middle seats, wide view', 2),
('普通 B 区', 'Regular Section B', 20.00, '#7C3AED', '后排经济选择，性价比高', 'Economical choice in the back, high value', 3);
