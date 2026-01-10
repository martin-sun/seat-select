// Supabase Edge Function: Send Payment Confirmation via Resend
// Trigger: After payment is confirmed (auto or manual)
// Supports: English and Chinese email templates based on user preference

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL')
const supabaseUrl = Deno.env.get('SUPABASE_URL')!
const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY')!

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
}

interface Reservation {
  id: string
  customer_name: string
  customer_email: string
  customer_phone: string
  order_id?: string
  total_amount: number
  seat_ids?: string[]
  payment_confirmed_at?: string
  preferred_language?: string
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Validate environment variables
    if (!RESEND_API_KEY) {
      return new Response(JSON.stringify({ error: 'Server misconfiguration: RESEND_API_KEY not set' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }
    if (!RESEND_FROM_EMAIL) {
      return new Response(JSON.stringify({ error: 'Server misconfiguration: RESEND_FROM_EMAIL not set' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 1. Parse request
    const { reservation_id } = await req.json()

    if (!reservation_id) {
      return new Response(JSON.stringify({ error: 'Missing reservation_id' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Initialize Supabase client with service role key
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 3. Fetch reservation details
    const { data: reservation, error: resError } = await supabase
      .from('reservations')
      .select('*')
      .eq('id', reservation_id)
      .single()

    if (resError || !reservation) {
      return new Response(JSON.stringify({ error: 'Reservation not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    const res = reservation as Reservation
    const customerEmail = res.customer_email

    if (!customerEmail) {
      return new Response(JSON.stringify({ error: 'Missing customer email' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 4. Get language preference from reservation (saved at booking time)
    const language = res.preferred_language || 'en-US'
    const isChinese = language.toLowerCase().startsWith('zh')
    const locale = isChinese ? 'zh-CN' : 'en-US'

    console.log(`Reservation language preference: ${language}, locale: ${locale}`)

    // 5. Get seat information - via reservation_seats junction table
    const { data: reservationSeats } = await supabase
      .from('reservation_seats')
      .select('seat_id')
      .eq('reservation_id', reservation_id)

    let seatsList: string[] = []
    if (reservationSeats && reservationSeats.length > 0) {
      const seatIds = reservationSeats.map((rs: { seat_id: string }) => rs.seat_id)
      const { data: seats } = await supabase
        .from('seats')
        .select('row, col')
        .in('id', seatIds)

      seatsList = seats?.map((s: { row: string; col: string }) => `${s.row}${s.col}`) || []
    }

    // 6. Generate email HTML based on language
    const emailContent = generatePaymentConfirmationEmail({
      locale,
      customerName: res.customer_name || 'Valued Customer',
      orderId: res.order_id || reservation_id,
      amount: res.total_amount,
      seats: seatsList,
      confirmedAt: res.payment_confirmed_at || new Date().toISOString()
    })

    // 7. Send email via Resend
    const resendResponse = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        from: RESEND_FROM_EMAIL,
        to: [customerEmail],
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
    console.log(`Payment confirmation email sent via Resend (${locale}): ${resendData.id}`)

    return new Response(JSON.stringify({
      message: 'Payment confirmation sent',
      reservation_id,
      locale,
      email_id: resendData.id
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error in send-payment-confirmation:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

// Email template generator with locale support
function generatePaymentConfirmationEmail(params: {
  locale: string
  customerName: string
  orderId: string
  amount: number
  seats: string[]
  confirmedAt: string
}): { subject: string; html: string } {
  const { locale, customerName, orderId, amount, seats, confirmedAt } = params
  const seatsStr = seats.join(', ')
  const confirmedTime = new Date(confirmedAt).toLocaleString(
    locale === 'zh-CN' ? 'zh-CN' : 'en-US',
    { dateStyle: 'medium', timeStyle: 'short' }
  )

  if (locale === 'zh-CN') {
    // Chinese Email Template
    return {
      subject: `支付成功 - 订单 ${orderId}`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    .container { font-family: 'Microsoft YaHei', Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
    .header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 30px 20px; text-align: center; }
    .content { padding: 30px; line-height: 1.6; color: #333; }
    .footer { background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }
    .order-info { background-color: #fcfcfc; border: 1px solid #e8e8e8; padding: 20px; margin: 20px 0; border-radius: 8px; }
    .success-icon { width: 60px; height: 60px; margin: 0 auto 20px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; }
    .success-icon svg { width: 36px; height: 36px; }
    .highlight { color: #10b981; font-weight: bold; font-size: 18px; }
    .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #eee; }
    .info-row:last-child { border-bottom: none; }
    .info-label { color: #666; }
    .info-value { font-weight: 500; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="success-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
        </svg>
      </div>
      <h2>支付成功</h2>
    </div>
    <div class="content">
      <p>尊敬的 <strong>${customerName}</strong>：</p>
      <p>您的订单已成功支付！感谢您购买 2026 春晚门票。</p>

      <div class="order-info">
        <div class="info-row">
          <span class="info-label">订单号：</span>
          <span class="info-value">${orderId}</span>
        </div>
        <div class="info-row">
          <span class="info-label">支付金额：</span>
          <span class="info-value highlight">$${amount}</span>
        </div>
        <div class="info-row">
          <span class="info-label">已选座位：</span>
          <span class="info-value">${seatsStr}</span>
        </div>
        <div class="info-row">
          <span class="info-label">确认时间：</span>
          <span class="info-value">${confirmedTime}</span>
        </div>
      </div>

      <p style="color: #666; font-size: 14px; margin-top: 20px;">
        📧 请保存此邮件作为支付凭证。<br><br>
        <strong>【取票信息】</strong><br>
        地点：紫龙腾餐馆，129 Ave I South<br>
        时间：每天中午12:00之后（周二不营业）<br>
        凭证：请出示此凭证取票
      </p>
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
      subject: `Payment Confirmed - Order ${orderId}`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
    .header { background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 30px 20px; text-align: center; }
    .content { padding: 30px; line-height: 1.6; color: #333; }
    .footer { background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }
    .order-info { background-color: #fcfcfc; border: 1px solid #e8e8e8; padding: 20px; margin: 20px 0; border-radius: 8px; }
    .success-icon { width: 60px; height: 60px; margin: 0 auto 20px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; }
    .success-icon svg { width: 36px; height: 36px; }
    .highlight { color: #10b981; font-weight: bold; font-size: 18px; }
    .info-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #eee; }
    .info-row:last-child { border-bottom: none; }
    .info-label { color: #666; }
    .info-value { font-weight: 500; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <div class="success-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="3">
          <path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
        </svg>
      </div>
      <h2>Payment Confirmed</h2>
    </div>
    <div class="content">
      <p>Dear <strong>${customerName}</strong>,</p>
      <p>Your payment has been successfully confirmed! Thank you for purchasing tickets for the 2026 Chunwan event.</p>

      <div class="order-info">
        <div class="info-row">
          <span class="info-label">Order ID:</span>
          <span class="info-value">${orderId}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Amount Paid:</span>
          <span class="info-value highlight">$${amount}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Seats Selected:</span>
          <span class="info-value">${seatsStr}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Confirmed At:</span>
          <span class="info-value">${confirmedTime}</span>
        </div>
      </div>

      <p style="color: #666; font-size: 14px; margin-top: 20px;">
        📧 Please save this email as proof of payment.<br><br>
        <strong>[Ticket Pickup Information]</strong><br>
        Location: Dragon Emperor Dim Sum, 129 Ave I South<br>
        Time: Daily after 12:00 PM (closed Tuesdays)<br>
        Required: Present this email to pick up tickets
      </p>
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
