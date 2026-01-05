-- Fix English content update for chunwan_settings
-- The previous migration failed because site_title had been updated to a bilingual version

UPDATE chunwan_settings SET
  site_title_en = '2026 RBC New Year Night',
  event_theme_en = 'RBC New Year Night',
  event_date_en = 'February 14, 2026',
  event_location_en = 'Lakeview Church, Saskatoon',
  event_address_en = '1908 Lac La Ronge Dr, Saskatoon, SK S7K 5S1',
  banner_title_en = '2026 RBC New Year Night',
  banner_subtitle_en = '🏮 Saskatoon Spring Festival Gala 🏮',
  about_content_en = 'The 2026 Saskatoon Spring Festival Gala "RBC New Year Night" is officially launched! Sponsored by RBC Royal Bank of Canada, the event will be held on February 14, 2026, at Lakeview Church. Cultural activities and exhibitions from 2:00 PM to 6:30 PM, followed by the formal performance from 7:00 PM to 9:00 PM. We cordially invite you to celebrate the New Year together!'
WHERE event_year = '2026';
