-- Create auth_otps table for custom OTP verification
CREATE TABLE IF NOT EXISTS public.auth_otps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT NOT NULL,
  otp_code TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS auth_otps_email_idx ON public.auth_otps(email);
CREATE INDEX IF NOT EXISTS auth_otps_expires_at_idx ON public.auth_otps(expires_at);

-- Enable RLS
ALTER TABLE public.auth_otps ENABLE ROW LEVEL SECURITY;

-- Policy: Service role can do everything
CREATE POLICY "Service role has full access" ON public.auth_otps
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
