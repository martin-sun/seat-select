from src.config import settings


def get_payment_confirmation_html(customer_name, order_id, amount, seats, locale="en-US"):
    """
    生成支付成功确认邮件的 HTML 内容 (支持中英文)

    Args:
        customer_name: 客户姓名
        order_id: 订单号
        amount: 金额
        seats: 座位列表
        locale: 语言 (zh-CN 或 en-US)
    """
    seats_str = ", ".join(seats)
    is_chinese = locale.lower().startswith('zh')

    if is_chinese:
        # 中文邮件模板
        subject = f"支付成功 - 订单 {order_id}"
        html = f"""
<!DOCTYPE html>
<html>
<head>
  <style>
    .container {{ font-family: 'Microsoft YaHei', Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }}
    .header {{ background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 30px 20px; text-align: center; }}
    .content {{ padding: 30px; line-height: 1.6; color: #333; }}
    .footer {{ background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }}
    .order-info {{ background-color: #fcfcfc; border: 1px solid #e8e8e8; padding: 20px; margin: 20px 0; border-radius: 8px; }}
    .success-icon {{ width: 60px; height: 60px; margin: 0 auto 20px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; }}
    .success-icon svg {{ width: 36px; height: 36px; }}
    .highlight {{ color: #10b981; font-weight: bold; font-size: 18px; }}
    .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #eee; }}
    .info-row:last-child {{ border-bottom: none; }}
    .info-label {{ color: #666; }}
    .info-value {{ font-weight: 500; }}
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
      <p>尊敬的 <strong>{customer_name}</strong>：</p>
      <p>您的订单已成功支付！感谢您购买 2026 春晚门票。</p>

      <div class="order-info">
        <div class="info-row">
          <span class="info-label">订单号：</span>
          <span class="info-value">{order_id}</span>
        </div>
        <div class="info-row">
          <span class="info-label">支付金额：</span>
          <span class="info-value highlight">${amount}</span>
        </div>
        <div class="info-row">
          <span class="info-label">已选座位：</span>
          <span class="info-value">{seats_str}</span>
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
        """
    else:
        # 英文邮件模板
        subject = f"Payment Confirmed - Order {order_id}"
        html = f"""
<!DOCTYPE html>
<html>
<head>
  <style>
    .container {{ font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }}
    .header {{ background: linear-gradient(135deg, #10b981 0%, #059669 100%); color: white; padding: 30px 20px; text-align: center; }}
    .content {{ padding: 30px; line-height: 1.6; color: #333; }}
    .footer {{ background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }}
    .order-info {{ background-color: #fcfcfc; border: 1px solid #e8e8e8; padding: 20px; margin: 20px 0; border-radius: 8px; }}
    .success-icon {{ width: 60px; height: 60px; margin: 0 auto 20px; background: rgba(255,255,255,0.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; }}
    .success-icon svg {{ width: 36px; height: 36px; }}
    .highlight {{ color: #10b981; font-weight: bold; font-size: 18px; }}
    .info-row {{ display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #eee; }}
    .info-row:last-child {{ border-bottom: none; }}
    .info-label {{ color: #666; }}
    .info-value {{ font-weight: 500; }}
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
      <p>Dear <strong>{customer_name}</strong>,</p>
      <p>Your payment has been successfully confirmed! Thank you for purchasing tickets for the 2026 Chunwan event.</p>

      <div class="order-info">
        <div class="info-row">
          <span class="info-label">Order ID:</span>
          <span class="info-value">{order_id}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Amount Paid:</span>
          <span class="info-value highlight">${amount}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Seats Selected:</span>
          <span class="info-value">{seats_str}</span>
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
        """

    return subject, html

def get_payment_instruction_html(customer_name, order_id, amount, seats, customer_phone="", support_phone="N/A", locale="en-US", etransfer_email=None):
    """
    生成支付指令邮件的 HTML 内容 (支持中英文)

    Args:
        customer_name: 客户姓名
        order_id: 订单号
        amount: 金额
        seats: 座位列表
        customer_phone: 客户手机号
        support_phone: 客服电话
        locale: 语言 (zh-CN 或 en-US)
        etransfer_email: E-transfer 收款邮箱
    """
    seats_str = ", ".join(seats)
    receive_email = etransfer_email or settings.ETRANSFER_RECEIVE_EMAIL or "saskatoonsfc@gmail.com"
    is_chinese = locale.lower().startswith('zh')

    if is_chinese:
        # 中文邮件模板
        subject = f"预订确认 - 支付指导 - 订单 {order_id}"
        html = f"""
<!DOCTYPE html>
<html>
<head>
    <style>
        .container {{ font-family: 'Microsoft YaHei', Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }}
        .header {{ background-color: #34495e; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 30px; line-height: 1.6; color: #333; }}
        .footer {{ background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }}
        .order-info {{ background-color: #fcfcfc; border: 1px dashed #ddd; padding: 15px; margin: 20px 0; }}
        .instruction-box {{ background-color: #fff9db; border: 1px solid #fab005; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        .highlight {{ color: #e74c3c; font-weight: bold; }}
        .step {{ margin-bottom: 10px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🎉 预订已提交</h2>
        </div>
        <div class="content">
            <p>尊敬的 <strong>{customer_name}</strong>：</p>
            <p>感谢您预订 2026 春晚门票！请在 <strong>24 小时内</strong> 完成支付以锁定您的座位。</p>

            <div class="order-info">
                <p><strong>📋 订单号：</strong> {order_id}</p>
                <p><strong>💰 总金额：</strong> <span class="highlight">${amount}</span></p>
                <p><strong>🪑 已选座位：</strong> {seats_str}</p>
            </div>

            <div class="instruction-box">
                <h3>💳 如何支付 (E-transfer 电子转账)</h3>
                <div class="step">
                    <strong>1. 接收人邮箱：</strong><br/>
                    <span class="highlight">{receive_email}</span>
                </div>
                <div class="step">
                    <strong>2. 备注信息 (⚠️ 非常重要)：</strong><br/>
                    请务必在备注中填写您的手机号：<span class="highlight">{customer_phone}</span>
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
            <p>客服电话：{support_phone}</p>
            <p>此为系统自动发送，请勿直接回复。</p>
        </div>
    </div>
</body>
</html>
        """
    else:
        # 英文邮件模板
        subject = f"Reservation Confirmed - Payment Instructions - Order {order_id}"
        html = f"""
<!DOCTYPE html>
<html>
<head>
    <style>
        .container {{ font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }}
        .header {{ background-color: #34495e; color: white; padding: 20px; text-align: center; }}
        .content {{ padding: 30px; line-height: 1.6; color: #333; }}
        .footer {{ background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }}
        .order-info {{ background-color: #fcfcfc; border: 1px dashed #ddd; padding: 15px; margin: 20px 0; }}
        .instruction-box {{ background-color: #fff9db; border: 1px solid #fab005; padding: 15px; border-radius: 5px; margin: 20px 0; }}
        .highlight {{ color: #e74c3c; font-weight: bold; }}
        .step {{ margin-bottom: 10px; }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h2>🎉 Reservation Received</h2>
        </div>
        <div class="content">
            <p>Dear <strong>{customer_name}</strong>,</p>
            <p>Thank you for your reservation for the 2026 Chunwan event! Please complete your payment within <strong>24 hours</strong> to secure your seats.</p>

            <div class="order-info">
                <p><strong>📋 Order ID:</strong> {order_id}</p>
                <p><strong>💰 Total Amount:</strong> <span class="highlight">${amount}</span></p>
                <p><strong>🪑 Seats Selected:</strong> {seats_str}</p>
            </div>

            <div class="instruction-box">
                <h3>💳 How to Pay (E-transfer)</h3>
                <div class="step">
                    <strong>1. Recipient Email:</strong><br/>
                    <span class="highlight">{receive_email}</span>
                </div>
                <div class="step">
                    <strong>2. Message/Memo (⚠️ IMPORTANT):</strong><br/>
                    Please include your Phone Number: <span class="highlight">{customer_phone}</span>
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
            <p>Support Phone: {support_phone}</p>
            <p>This is an automated message, please do not reply directly.</p>
        </div>
    </div>
</body>
</html>
        """

    return subject, html
