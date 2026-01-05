from datetime import datetime, timezone
from celery_app.celery import app
from src.database import supabase
from src.utils.gmail.gmail_api import get_gmail_api
from src.utils.gmail.templates import get_payment_instruction_html

@app.task
def send_payment_instructions():
    """
    定期检查 pending 状态且未发送指令邮件的预约，发送支付指南。
    """
    gmail = get_gmail_api()
    if not gmail:
        return "Gmail API not initialized"

    # 1. 查询 pending 状态且 instruction_sent_at 为空的预约
    # 注意：确保已运行 migrations/20260105040000_add_instruction_tracking.sql
    response = supabase.table("reservations") \
        .select("*") \
        .eq("status", "pending") \
        .is_("instruction_sent_at", "null") \
        .execute()
    
    new_reservations = response.data
    
    if not new_reservations:
        return "No new reservations needing instructions"

    sent_count = 0
    for res in new_reservations:
        res_id = res['id']
        customer_email = res.get('customer_email')
        
        if not customer_email:
            print(f"Reservation {res_id} missing customer_email, skipping.")
            continue

        try:
            # 获取座位信息用于邮件显示
            # 优先从 reservation 的 seat_ids 字段（如果存在）获取，否则从 reservation_seats 表关联查询
            seat_ids = res.get('seat_ids', [])
            if not seat_ids:
                seats_res = supabase.table("seats") \
                    .select("row, col") \
                    .eq("reservation_id", res_id) \
                    .execute()
                seats_list = [f"{s['row']}{s['col']}" for s in seats_res.data]
            else:
                seats_info = supabase.table("seats").select("row, col").in_("id", seat_ids).execute()
                seats_list = [f"{s['row']}{s['col']}" for s in seats_info.data]

            # 生成 HTML
            html_body = get_payment_instruction_html(
                customer_name=res.get('customer_name', 'Valued Customer'),
                order_id=res.get('order_id', res_id),
                amount=res['total_amount'],
                seats=seats_list,
                customer_phone=res.get('customer_phone', 'N/A')
            )

            # 发送邮件
            subject = f"Action Required: Payment Instructions for Order {res.get('order_id', res_id)}"
            gmail.send_email(
                to=customer_email,
                subject=subject,
                body=html_body,
                body_type='html'
            )

            # 更新数据库标记已发送
            supabase.table("reservations") \
                .update({"instruction_sent_at": datetime.now(timezone.utc).isoformat()}) \
                .eq("id", res_id) \
                .execute()
            
            print(f"📧 Instruction email sent to {customer_email} for Reservation {res_id}")
            sent_count += 1

        except Exception as e:
            print(f"⚠️ Failed to send instruction email for {res_id}: {e}")

    return f"Processed {len(new_reservations)} reservations, sent {sent_count} instructions."
