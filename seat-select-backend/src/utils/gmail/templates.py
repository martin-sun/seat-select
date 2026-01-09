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
