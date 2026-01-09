// Supabase Edge Function: Send Auth OTP via Resend
// Trigger: When user needs login/signup verification
// Supports: English and Chinese email templates

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') || ''
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL') || 'noreply@yourdomain.com'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
}

interface AuthOtp {
  email: string
  otp_code: string
  expires_at: string
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Parse request
    const { email, language = 'en-US' } = await req.json()

    if (!email) {
      return new Response(JSON.stringify({ error: 'Missing email' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Determine if Chinese or English
    const isChinese = language.toLowerCase().startsWith('zh')
    const locale = isChinese ? 'zh-CN' : 'en-US'

    // 2. Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 3. Generate 6-digit OTP code using cryptographically secure random
    const array = new Uint32Array(1)
    crypto.getRandomValues(array)
    const otpCode = (100000 + (array[0] % 900000)).toString()
    const expiresAt = new Date(Date.now() + 15 * 60 * 1000).toISOString() // 15 minutes

    // 4. Store OTP in database (delete any existing OTPs for this email first)
    await supabase
      .from('auth_otps')
      .delete()
      .lt('expires_at', new Date().toISOString()) // Clean expired

    await supabase
      .from('auth_otps')
      .delete()
      .eq('email', email.toLowerCase().trim()) // Delete any existing OTP for this email (normalized)

    const { error: insertError } = await supabase
      .from('auth_otps')
      .insert({
        email: email.toLowerCase().trim(),
        otp_code: otpCode,
        expires_at: expiresAt
      })

    if (insertError) {
      console.error('Failed to store OTP:', insertError)
      throw new Error('Failed to generate OTP code')
    }

    // 5. Generate email HTML based on language
    const emailContent = generateAuthOtpEmail({
      locale,
      email: email.toLowerCase().trim(),
      otpCode
    })

    // 6. Send email via Resend
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: [email.toLowerCase().trim()],
        subject: emailContent.subject,
        html: emailContent.html
      })
    })

    if (!resendResponse.ok) {
      const errorText = await resendResponse.text()
      console.error('Resend API error:', errorText)
      throw new Error(`Failed to send email: ${errorText}`)
    }

    const resendData = await resendResponse.json()
    console.log(`Auth OTP email sent via Resend (${locale}): ${resendData.id}`)

    return new Response(JSON.stringify({
      message: 'OTP sent successfully',
      email: email.toLowerCase().trim(),
      locale,
      email_id: resendData.id
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error in send-auth-otp:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

// Email template generator with locale support
function generateAuthOtpEmail(params: {
  locale: string
  email: string
  otpCode: string
}): { subject: string; html: string } {
  const { locale, email, otpCode } = params

  if (locale === 'zh-CN') {
    // Chinese Email Template
    return {
      subject: '登录验证码 - 2026 春晚选座系统',
      html: `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <style>
    .container { font-family: 'Microsoft YaHei', Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
    .content { padding: 30px; line-height: 1.6; color: #333; }
    .footer { background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }
    .otp-box { background-color: #f0f9ff; border: 2px dashed #3b82f6; padding: 20px; text-align: center; border-radius: 8px; margin: 25px 0; }
    .otp-code { font-size: 36px; font-weight: bold; color: #2563eb; letter-spacing: 8px; font-family: 'Courier New', monospace; }
    .email-display { background-color: #f3f4f6; padding: 10px; border-radius: 4px; text-align: center; font-family: monospace; color: #6b7280; }
    .warning { background-color: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; font-size: 14px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔐 登录验证</h1>
    </div>
    <div class="content">
      <p>您好！</p>
      <p>您正在登录 <strong>2026 春晚选座系统</strong>，账号：</p>
      <div class="email-display">${email}</div>

      <p>请使用以下验证码完成登录：</p>

      <div class="otp-box">
        <div class="otp-code">${otpCode}</div>
      </div>

      <div class="warning">
        ⚠️ <strong>请注意：</strong>
        <ul style="margin: 10px 0 0 0; padding-left: 20px;">
          <li>此验证码将在 <strong>15 分钟</strong>后失效</li>
          <li>请勿将验证码透露给任何人</li>
          <li>如果您没有请求此验证码，请忽略此邮件</li>
        </ul>
      </div>
    </div>
    <div class="footer">
      <p>&copy; 2026 Saskatoon SFC - 选座系统</p>
      <p>此为系统自动发送，请勿直接回复。</p>
    </div>
  </div>
</body>
</html>
      `.trim()
    }
  } else {
    // English Email Template
    return {
      subject: 'Login Verification Code - 2026 Chunwan Seat Select',
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; text-align: center; }
    .content { padding: 30px; line-height: 1.6; color: #333; }
    .footer { background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }
    .otp-box { background-color: #f0f9ff; border: 2px dashed #3b82f6; padding: 20px; text-align: center; border-radius: 8px; margin: 25px 0; }
    .otp-code { font-size: 36px; font-weight: bold; color: #2563eb; letter-spacing: 8px; font-family: 'Courier New', monospace; }
    .email-display { background-color: #f3f4f6; padding: 10px; border-radius: 4px; text-align: center; font-family: monospace; color: #6b7280; }
    .warning { background-color: #fef3c7; border-left: 4px solid #f59e0b; padding: 15px; margin: 20px 0; font-size: 14px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔐 Login Verification</h1>
    </div>
    <div class="content">
      <p>Hello!</p>
      <p>You are logging into <strong>2026 Chunwan Seat Select System</strong> for account:</p>
      <div class="email-display">${email}</div>

      <p>Please use the following verification code to complete your login:</p>

      <div class="otp-box">
        <div class="otp-code">${otpCode}</div>
      </div>

      <div class="warning">
        ⚠️ <strong>Please Note:</strong>
        <ul style="margin: 10px 0 0 0; padding-left: 20px;">
          <li>This code will expire in <strong>15 minutes</strong></li>
          <li>Do not share this code with anyone</li>
          <li>If you didn't request this code, please ignore this email</li>
        </ul>
      </div>
    </div>
    <div class="footer">
      <p>&copy; 2026 Saskatoon SFC - Seat Select System</p>
      <p>This is an automated message, please do not reply directly.</p>
    </div>
  </div>
</body>
</html>
      `.trim()
    }
  }
}
