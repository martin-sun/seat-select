def get_payment_confirmation_html(customer_name, order_id, amount, seats):
    """
    生成支付成功确认邮件的 HTML 内容 (中英双语)
    """
    seats_str = ", ".join(seats)
    
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <style>
            .container {{ font-family: 'Microsoft YaHei', Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #eee; border-radius: 8px; overflow: hidden; }}
            .header {{ background-color: #2c3e50; color: white; padding: 20px; text-align: center; }}
            .content {{ padding: 30px; line-height: 1.6; color: #333; }}
            .footer {{ background-color: #f9f9f9; color: #7f8c8d; padding: 20px; text-align: center; font-size: 12px; }}
            .order-info {{ background-color: #fcfcfc; border: 1px dashed #ddd; padding: 15px; margin: 20px 0; }}
            .highlight {{ color: #e74c3c; font-weight: bold; }}
            .btn {{ display: inline-block; padding: 10px 20px; background-color: #27ae60; color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; }}
        </style>
    </head>
    <body>
        <div class="container">
            <div class="header">
                <h2>Payment Confirmed / 支付已确认</h2>
            </div>
            <div class="content">
                <p>Dear <strong>{customer_name}</strong>,</p>
                <p>We have successfully received your payment for the 2026 Chunwan Ticketing. Your reservation is now officially confirmed.</p>
                <p>亲爱的 <strong>{customer_name}</strong>：</p>
                <p>我们已成功收到您关于 2026 春晚门票的余款。您的预订现已正式确认。</p>
                
                <div class="order-info">
                    <p><strong>Order ID / 订单号:</strong> {order_id}</p>
                    <p><strong>Amount Paid / 已付金额:</strong> <span class="highlight">${amount}</span></p>
                    <p><strong>Seats / 座位:</strong> {seats_str}</p>
                </div>
                
                <p>Please keep this email as your proof of purchase. We look forward to seeing you at the event!</p>
                <p>请妥善保管此邮件作为购票凭证。我们期待在活动现场见到您！</p>
                
                <div style="text-align: center;">
                    <a href="https://chunwan.saskatoonsfc.ca" class="btn">View My Orders / 查看订单</a>
                </div>
            </div>
            <div class="footer">
                <p>&copy; 2026 Saskatoon SFC - Seat Select System</p>
                <p>This is an automated message, please do not reply directly. / 此为系统自动发送，请勿直接回复。</p>
            </div>
        </div>
    </body>
    </html>
    """
    return html

def get_payment_instruction_html(customer_name, order_id, amount, seats):
    """
    生成支付指令邮件的 HTML 内容 (中英双语)
    """
    seats_str = ", ".join(seats)
    
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
                <h2>Reservation Received / 预订已提交</h2>
            </div>
            <div class="content">
                <p>Dear <strong>{customer_name}</strong>,</p>
                <p>Thank you for your reservation for the 2026 Chunwan event! Please complete your payment within <strong>24 hours</strong> to secure your seats.</p>
                <p>亲爱的 <strong>{customer_name}</strong>：</p>
                <p>感谢您预订 2026 春晚门票！请在 <strong>24 小时内</strong> 完成支付以锁定您的座位。</p>
                
                <div class="order-info">
                    <p><strong>Order ID / 订单号:</strong> {order_id}</p>
                    <p><strong>Total Amount / 总金额:</strong> <span class="highlight">${amount}</span></p>
                    <p><strong>Seats / 已选座位:</strong> {seats_str}</p>
                </div>

                <div class="instruction-box">
                    <h3>How to Pay / 如何支付 (E-transfer)</h3>
                    <div class="step">
                        <strong>1. Recipient Email / 接收人邮箱:</strong><br/>
                        <span class="highlight">saskatoonsfc@gmail.com</span>
                    </div>
                    <div class="step">
                        <strong>2. Message/Memo / 备注信息 (IMPORTANT/非常重要):</strong><br/>
                        Please include your Order ID: <span class="highlight">{order_id}</span><br/>
                        请务必在备注中填写订单号：<span class="highlight">{order_id}</span>
                    </div>
                    <div class="step">
                        <strong>3. Verification / 自动核销:</strong><br/>
                        Our system will automatically confirm your payment once the E-transfer is deposited.
                        一旦电子转账存入，系统将自动确认您的支付。
                    </div>
                </div>

                <p style="color: #666; font-size: 14px;">Note: If payment is not received within 24 hours, your seats will be released back to the public.</p>
                <p style="color: #666; font-size: 14px;">注意：若 24 小时内未收到款项，您的座位将重新向公众开放。</p>
            </div>
            <div class="footer">
                <p>&copy; 2026 Saskatoon SFC - Seat Select System</p>
                <p>This is an automated message, please do not reply directly. / 此为系统自动发送，请勿直接回复。</p>
            </div>
        </div>
    </body>
    </html>
    """
    return html
