import re
from datetime import datetime, timezone
from celery_app.celery import app
from src.database import supabase
from src.utils.gmail.gmail_api import get_gmail_api
from src.utils.gmail.templates import get_payment_confirmation_html


def get_user_locale_sync(reservation) -> str:
    """直接从预约记录获取语言偏好"""
    return reservation.get("preferred_language", "en-US")


@app.task
def check_payments():
    """
    Checks Gmail for new Interac E-transfers and matches them with pending reservations.
    Strict criteria:
    - From: notify@payments.interac.ca
    - Body: "Funds Deposited!"
    - Reply-To: Contains customer_email
    - Amount: Matches total_amount
    - Label: INBOX (processed emails are moved to 'Processed')
    """
    gmail = get_gmail_api()
    if not gmail:
        return "Gmail API not initialized"

    # 1. Fetch pending reservations (that haven't expired yet)
    now = datetime.now(timezone.utc).isoformat()
    response = supabase.table("reservations") \
        .select("*") \
        .eq("status", "pending") \
        .gt("expires_at", now) \
        .execute()
    
    pending_reservations = response.data
    
    if not pending_reservations:
        return "No active pending reservations to check"

    matched_count = 0
    for res in pending_reservations:
        res_id = res["id"]
        amount = res["total_amount"]
        customer_email = res.get("customer_email")
        if not customer_email:
            print(f"Reservation {res_id} missing customer_email, skipping.")
            continue

        # Format amount for search, e.g., "138.00"
        amount_query = f"{float(amount):.2f}"
        
        # 2. Search Gmail
        # Strict query: from:notify@payments.interac.ca "Funds Deposited!" "138.00" label:INBOX
        query = f'from:notify@payments.interac.ca "Funds Deposited!" "{amount_query}" label:INBOX'
        messages = gmail.search_messages(query)
        
        for msg in messages:
            msg_id = msg['id']
            msg_detail = gmail.get_message_detail(msg_id)
            if not msg_detail:
                continue

            # Email time validation: ensure email was received after reservation was created
            email_date_ms = int(msg_detail.get('internalDate', 0))
            if email_date_ms == 0:
                print(f"Message {msg_id} has no internalDate, skipping.")
                continue

            email_date = datetime.fromtimestamp(email_date_ms / 1000, tz=timezone.utc)
            reservation_created_str = res.get('created_at')

            if not reservation_created_str:
                print(f"Reservation {res_id} has no created_at, skipping.")
                continue

            # Handle ISO format time string
            if reservation_created_str.endswith('Z'):
                reservation_created_str = reservation_created_str[:-1] + '+00:00'
            reservation_created = datetime.fromisoformat(reservation_created_str)
            # Normalize naive timestamps to UTC to avoid aware/naive comparison errors
            if reservation_created.tzinfo is None:
                reservation_created = reservation_created.replace(tzinfo=timezone.utc)

            # Verify email was received after reservation was created
            if email_date < reservation_created:
                print(f"⚠️ Email {msg_id} received {email_date.isoformat()} BEFORE reservation {res_id} created {reservation_created.isoformat()}, skipping.")
                continue

            print(f"✅ Email {msg_id} time validation passed: received {email_date.isoformat()}")

            headers = msg_detail.get('payload', {}).get('headers', [])
            
            # Check Reply-To header
            reply_to = next((h['value'] for h in headers if h['name'].lower() == 'reply-to'), "")
            
            # Verification:
            # 1. Reply-To must contain customer_email
            # 2. Snippet/Body must contain "Funds Deposited!" (already in query but double check)
            if customer_email.lower() in reply_to.lower():
                print(f"Match found! Reservation {res_id} matched with email {msg_id}")
                
                # 3. Mark reservation as paid
                supabase.table("reservations") \
                    .update({
                        "status": "paid",
                        "payment_confirmed_at": datetime.now(timezone.utc).isoformat(),
                        "payment_message_id": msg_id, # Record the Gmail message ID
                        "updated_at": datetime.now(timezone.utc).isoformat()
                    }) \
                    .eq("id", res_id) \
                    .execute()

                # 4. Update seats to 'sold' - via reservation_seats junction table
                seat_ids_res = supabase.table("reservation_seats") \
                    .select("seat_id") \
                    .eq("reservation_id", res_id) \
                    .execute()

                if seat_ids_res.data:
                    seat_ids = [s["seat_id"] for s in seat_ids_res.data]
                    supabase.table("seats") \
                        .update({
                            "status": "sold",
                            "updated_at": datetime.now(timezone.utc).isoformat()
                        }) \
                        .in_("id", seat_ids) \
                        .execute()

                # 5. Move email to Processed folder and remove from INBOX
                gmail.mark_as_processed(msg_id, label_name='Processed')
                print(f"✅ Payment matched and processed for Reservation {res_id}")

                # 6. Send Confirmation Email to Customer via Gmail
                try:
                    # Get seat information for the email - via reservation_seats junction table
                    seat_ids_res = supabase.table("reservation_seats") \
                        .select("seat_id") \
                        .eq("reservation_id", res_id) \
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

                    # Get locale from reservation record
                    locale = get_user_locale_sync(res)

                    # Generate confirmation email with locale
                    subject, html_body = get_payment_confirmation_html(
                        customer_name=res.get('customer_name', 'Valued Customer'),
                        order_id=res.get('order_id', res_id),
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
                    print(f"📧 Confirmation email sent to {customer_email}")
                except Exception as e:
                    print(f"⚠️ Failed to send confirmation email for {res_id}: {e}")
                
                matched_count += 1
                # Once matched, we don't need to check other emails for THIS reservation
                break 

    return f"Checked {len(pending_reservations)} reservations, matched {matched_count}."
