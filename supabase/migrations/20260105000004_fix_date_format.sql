-- Fix event_date format to ISO string for better frontend parsing
UPDATE chunwan_settings 
SET event_date = '2026-02-14T19:00:00'
WHERE event_year = '2026';
