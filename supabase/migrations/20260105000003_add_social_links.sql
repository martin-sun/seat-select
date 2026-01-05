-- Add social media links to chunwan_settings
ALTER TABLE chunwan_settings 
ADD COLUMN IF NOT EXISTS facebook_url TEXT,
ADD COLUMN IF NOT EXISTS twitter_url TEXT,
ADD COLUMN IF NOT EXISTS youtube_url TEXT,
ADD COLUMN IF NOT EXISTS instagram_url TEXT,
ADD COLUMN IF NOT EXISTS contact_email TEXT;

-- Update existing settings with the new email
UPDATE chunwan_settings 
SET contact_email = 'saskatoonsfc@gmail.com',
    facebook_url = 'https://www.facebook.com/saskatoonchunwan',
    youtube_url = 'https://www.youtube.com/@saskatoonchunwan'
WHERE contact_email IS NULL;
