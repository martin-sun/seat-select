from fastapi import APIRouter, HTTPException, Header, Depends
from pydantic import BaseModel
from datetime import datetime, timezone
from src.database import supabase
from src.utils.gmail.gmail_api import get_gmail_api
from src.utils.gmail.templates import get_payment_instruction_html, get_payment_confirmation_html
from src.config import settings

router = APIRouter(prefix="/api/mail", tags=["mail"])


async def verify_api_key(x_api_key: str = Header(None)):
    """
    Verify API key for mail endpoints.
    """
    if not x_api_key or x_api_key != settings.API_KEY:
        raise HTTPException(status_code=401, detail="Invalid API key")
    return x_api_key


class SendInstructionsRequest(BaseModel):
    reservation_id: str


class SendConfirmationRequest(BaseModel):
    reservation_id: str


def get_user_locale(reservation) -> str:
    """
    直接从预约记录获取语言偏好
    preferred_language 字段在创建预约时已保存
    """
    return reservation.get("preferred_language", "en-US")


def get_user_locale_sync(reservation) -> str:
    """
    同步版本 - 直接从预约记录获取
    """
    return reservation.get("preferred_language", "en-US")


@router.post("/send-instructions", dependencies=[Depends(verify_api_key)])
async def send_instructions(req: SendInstructionsRequest):
    """
    立即发送支付指导邮件（按需触发）
    如果已发送则跳过（基于 instruction_sent_at）
    """
    gmail = get_gmail_api()
    if not gmail:
        raise HTTPException(status_code=500, detail="Gmail API not initialized")

    # 检查预约是否存在
    response = supabase.table("reservations") \
        .select("*") \
        .eq("id", req.reservation_id) \
        .maybe_single() \
        .execute()

    if not response.data:
        raise HTTPException(status_code=404, detail="Reservation not found")

    res = response.data

    # 检查预约状态和过期时间
    now = datetime.now(timezone.utc)
    if res.get("status") != "pending":
        raise HTTPException(status_code=400, detail="Reservation not in pending status")

    expires_at = res.get("expires_at")
    if expires_at:
        expiry = datetime.fromisoformat(expires_at.replace('Z', '+00:00'))
        if expiry < now:
            raise HTTPException(status_code=400, detail="Reservation has expired")

    # 检查是否已发送
    if res.get("instruction_sent_at"):
        return {
            "message": "Payment instructions already sent",
            "reservation_id": req.reservation_id,
            "sent_at": res["instruction_sent_at"]
        }

    customer_email = res.get('customer_email')
    if not customer_email:
        raise HTTPException(status_code=400, detail="Missing customer email")

    try:
        # 获取座位信息 - 通过 reservation_seats 中间表
        seat_ids_res = supabase.table("reservation_seats") \
            .select("seat_id") \
            .eq("reservation_id", req.reservation_id) \
            .execute()

        if seat_ids_res.data:
            seat_ids = [s["seat_id"] for s in seat_ids_res.data]
            seats_res = supabase.table("seats") \
                .select("row, col") \
                .in_("id", seat_ids) \
                .execute()
            seats_list = [f"{s['row']}{s['col']}" for s in seats_res.data]
        else:
            seats_list = []

        # 生成并发送邮件（新模板返回 subject, html 元组）
        # 直接从预约记录获取语言偏好
        locale = get_user_locale(res)

        subject, html_body = get_payment_instruction_html(
            customer_name=res.get('customer_name', 'Valued Customer'),
            order_id=res.get('order_id', req.reservation_id),
            amount=res['total_amount'],
            seats=seats_list,
            customer_phone=res.get('customer_phone', ''),
            support_phone=settings.SUPPORT_PHONE,
            locale=locale,
            etransfer_email=settings.ETRANSFER_RECEIVE_EMAIL
        )

        gmail.send_email(
            to=customer_email,
            subject=subject,
            body=html_body,
            body_type='html'
        )

        # 更新数据库
        supabase.table("reservations") \
            .update({"instruction_sent_at": datetime.now(timezone.utc).isoformat()}) \
            .eq("id", req.reservation_id) \
            .execute()

        return {
            "message": "Payment instructions sent",
            "reservation_id": req.reservation_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {str(e)}")


@router.post("/send-confirmation", dependencies=[Depends(verify_api_key)])
async def send_confirmation(req: SendConfirmationRequest):
    """
    发送支付确认邮件
    """
    gmail = get_gmail_api()
    if not gmail:
        raise HTTPException(status_code=500, detail="Gmail API not initialized")

    # 检查预约是否存在
    response = supabase.table("reservations") \
        .select("*") \
        .eq("id", req.reservation_id) \
        .maybe_single() \
        .execute()

    if not response.data:
        raise HTTPException(status_code=404, detail="Reservation not found")

    res = response.data
    customer_email = res.get('customer_email')
    if not customer_email:
        raise HTTPException(status_code=400, detail="Missing customer email")

    try:
        # 获取座位信息 - 通过 reservation_seats 中间表
        seat_ids_res = supabase.table("reservation_seats") \
            .select("seat_id") \
            .eq("reservation_id", req.reservation_id) \
            .execute()

        if seat_ids_res.data:
            seat_ids = [s["seat_id"] for s in seat_ids_res.data]
            seats_res = supabase.table("seats") \
                .select("row, col") \
                .in_("id", seat_ids) \
                .execute()
            seats_list = [f"{s['row']}{s['col']}" for s in seats_res.data]
        else:
            seats_list = []

        # 直接从预约记录获取语言偏好
        locale = get_user_locale(res)

        # 生成并发送邮件（返回 subject, html 元组）
        subject, html_body = get_payment_confirmation_html(
            customer_name=res.get('customer_name', 'Valued Customer'),
            order_id=res.get('order_id', req.reservation_id),
            amount=res['total_amount'],
            seats=seats_list,
            locale=locale
        )

        gmail.send_email(
            to=customer_email,
            subject=subject,
            body=html_body,
            body_type='html'
        )

        return {
            "message": "Payment confirmation sent",
            "reservation_id": req.reservation_id
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send email: {str(e)}")
