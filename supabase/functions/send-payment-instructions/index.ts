// Supabase Edge Function: Send Payment Instructions via Resend
// Trigger: Immediately after booking is created
// Supports: English and Chinese email templates

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY') || ''
const RESEND_FROM_EMAIL = Deno.env.get('RESEND_FROM_EMAIL') || 'noreply@yourdomain.com'
// Internal API key for authentication between services
const INTERNAL_API_KEY = Deno.env.get('INTERNAL_API_KEY') || ''
const SUPPORT_PHONE = Deno.env.get('SUPPORT_PHONE') || 'N/A'
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
}

serve(async (req) => {
  // Handle CORS preflight request
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // 1. Authentication: Accept either INTERNAL_API_KEY or valid Supabase session token
    const authHeader = req.headers.get('authorization')
    let isAuthenticated = false

    if (authHeader) {
      const token = authHeader.replace('Bearer ', '')

      // Check if it's the internal API key
      if (token === INTERNAL_API_KEY) {
        isAuthenticated = true
      } else {
        // Otherwise, verify it's a valid Supabase session token
        const supabaseAuth = createClient(supabaseUrl, supabaseAnonKey, {
          global: { headers: { Authorization: authHeader } }
        })
        const { data: { user }, error: authError } = await supabaseAuth.auth.getUser()
        if (!authError && user) {
          isAuthenticated = true
        }
      }
    }

    if (!isAuthenticated) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 2. Parse request
    const { reservation_id, language = 'en-US' } = await req.json()

    if (!reservation_id) {
      return new Response(JSON.stringify({ error: 'Missing reservation_id' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // 3. Initialize Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // 4. Prevent abuse: check if payment instructions were already sent
    const { data: existingReservation } = await supabase
      .from('reservations')
      .select('id, instruction_sent_at')
      .eq('id', reservation_id)
      .maybeSingle()

    if (!existingReservation) {
      return new Response(JSON.stringify({ error: 'Reservation not found' }), {
        status: 404,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    if (existingReservation.instruction_sent_at) {
      // Already sent, return success to prevent duplicate emails
      return new Response(JSON.stringify({
        message: 'Payment instructions already sent',
        reservation_id,
        locale: language
      }), {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      })
    }

    // Determine if Chinese or English
    const isChinese = language.toLowerCase().startsWith('zh')
    const locale = isChinese ? 'zh-CN' : 'en-US'

    // 5. Fetch reservation details
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

    // 6. Get seat information
    let seatsList: string[] = []
    const seatIds = res.seat_ids || []

    if (seatIds.length > 0) {
      const { data: seats } = await supabase
        .from('seats')
        .select('row, col')
        .in('id', seatIds)

      seatsList = seats?.map(s => `${s.row}${s.col}`) || []
    } else {
      const { data: seats } = await supabase
        .from('seats')
        .select('row, col')
        .eq('reservation_id', reservation_id)

      seatsList = seats?.map(s => `${s.row}${s.col}`) || []
    }

    // 7. Generate email HTML based on language
    const emailContent = generatePaymentInstructionEmail({
      locale,
      customerName: res.customer_name || 'Valued Customer',
      orderId: res.order_id || reservation_id,
      amount: res.total_amount,
      seats: seatsList,
      customerPhone: res.customer_phone || 'N/A',
      supportPhone: SUPPORT_PHONE
    })

    // 8. Send email via Resend
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
    console.log(`Email sent via Resend (${locale}): ${resendData.id}`)

    // 9. Update database
    const { error: updateError } = await supabase
      .from('reservations')
      .update({ instruction_sent_at: new Date().toISOString() })
      .eq('id', reservation_id)

    if (updateError) {
      console.error('Failed to update reservation:', updateError)
    }

    return new Response(JSON.stringify({
      message: 'Payment instructions sent',
      reservation_id,
      locale,
      email_id: resendData.id
    }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })

  } catch (error) {
    console.error('Error in send-payment-instructions:', error)
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    })
  }
})

// Email template generator with locale support
function generatePaymentInstructionEmail(params: {
  locale: string
  customerName: string
  orderId: string
  amount: number
  seats: string[]
  customerPhone: string
  supportPhone: string
}): { subject: string; html: string } {
  const { locale, customerName, orderId, amount, seats, customerPhone, supportPhone } = params
  const seatsStr = seats.join(', ')

  if (locale === 'zh-CN') {
    // Chinese Email Template
    return {
      subject: `预订确认 - 支付指导 - 订单 ${orderId}`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    .container { font-family: 'Microsoft YaHei', Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
    .header { background-color: #34495e; color: white; padding: 20px; text-align: center; }
    .content { padding: 30px; line-height: 1.6; color: #333; }
    .footer { background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }
    .order-info { background-color: #fcfcfc; border: 1px dashed #ddd; padding: 15px; margin: 20px 0; }
    .instruction-box { background-color: #fff9db; border: 1px solid #fab005; padding: 15px; border-radius: 5px; margin: 20px 0; }
    .highlight { color: #e74c3c; font-weight: bold; }
    .step { margin-bottom: 10px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>🎉 预订已提交</h2>
    </div>
    <div class="content">
      <p>尊敬的 <strong>${customerName}</strong>：</p>
      <p>感谢您预订 2026 春晚门票！请在 <strong>24 小时内</strong> 完成支付以锁定您的座位。</p>

      <div class="order-info">
        <p><strong>📋 订单号：</strong> ${orderId}</p>
        <p><strong>💰 总金额：</strong> <span class="highlight">$${amount}</span></p>
        <p><strong>🪑 已选座位：</strong> ${seatsStr}</p>
      </div>

      <div class="instruction-box">
        <h3>💳 如何支付 (E-transfer 电子转账)</h3>
        <div class="step">
          <strong>1. 接收人邮箱：</strong><br/>
          <span class="highlight">saskatoonsfc@gmail.com</span>
        </div>
        <div class="step">
          <strong>2. 备注信息 (⚠️ 非常重要)：</strong><br/>
          请务必在备注中填写您的手机号：<span class="highlight">${customerPhone}</span>
        </div>
        <div class="step">
          <strong>3. 自动核销：</strong><br/>
          一旦电子转账存入，系统将自动确认您的支付，无需人工处理。
        </div>
      </div>

      <p style="color: #666; font-size: 14px;">⚠️ 注意：若 24 小时内未收到款项，您的座位将重新向公众开放。</p>
    </div>
    <div class="footer">
      <p>&copy; 2026 Saskatoon SFC - 选座系统</p>
      <p>客服电话：${supportPhone}</p>
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
      subject: `Reservation Confirmed - Payment Instructions - Order ${orderId}`,
      html: `
<!DOCTYPE html>
<html>
<head>
  <style>
    .container { font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }
    .header { background-color: #34495e; color: white; padding: 20px; text-align: center; }
    .content { padding: 30px; line-height: 1.6; color: #333; }
    .footer { background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }
    .order-info { background-color: #fcfcfc; border: 1px dashed #ddd; padding: 15px; margin: 20px 0; }
    .instruction-box { background-color: #fff9db; border: 1px solid #fab005; padding: 15px; border-radius: 5px; margin: 20px 0; }
    .highlight { color: #e74c3c; font-weight: bold; }
    .step { margin-bottom: 10px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h2>🎉 Reservation Received</h2>
    </div>
    <div class="content">
      <p>Dear <strong>${customerName}</strong>,</p>
      <p>Thank you for your reservation for the 2026 Chunwan event! Please complete your payment within <strong>24 hours</strong> to secure your seats.</p>

      <div class="order-info">
        <p><strong>📋 Order ID:</strong> ${orderId}</p>
        <p><strong>💰 Total Amount:</strong> <span class="highlight">$${amount}</span></p>
        <p><strong>🪑 Seats Selected:</strong> ${seatsStr}</p>
      </div>

      <div class="instruction-box">
        <h3>💳 How to Pay (E-transfer)</h3>
        <div class="step">
          <strong>1. Recipient Email:</strong><br/>
          <span class="highlight">saskatoonsfc@gmail.com</span>
        </div>
        <div class="step">
          <strong>2. Message/Memo (⚠️ IMPORTANT):</strong><br/>
          Please include your Phone Number: <span class="highlight">${customerPhone}</span>
        </div>
        <div class="step">
          <strong>3. Automatic Verification:</strong><br/>
          Our system will automatically confirm your payment once the E-transfer is deposited.
        </div>
      </div>

      <p style="color: #666; font-size: 14px;">⚠️ Note: If payment is not received within 24 hours, your seats will be released back to the public.</p>
    </div>
    <div class="footer">
      <p>&copy; 2026 Saskatoon SFC - Seat Select System</p>
      <p>Support Phone: ${supportPhone}</p>
      <p>This is an automated message, please do not reply directly.</p>
    </div>
  </div>
</body>
</html>
      `.trim()
    }
  }
}
