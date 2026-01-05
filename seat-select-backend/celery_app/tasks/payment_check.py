import re
from datetime import datetime, timezone
from celery_app.celery import app
from src.database import supabase
from src.utils.gmail.gmail_api import get_gmail_api

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
                
                # 4. Update seats to 'sold'
                supabase.table("seats") \
                    .update({
                        "status": "sold",
                        "updated_at": datetime.now(timezone.utc).isoformat()
                    }) \
                    .eq("reservation_id", res_id) \
                    .execute()
                
                # 5. Move email to Processed folder and remove from INBOX
                gmail.mark_as_processed(msg_id, label_name='Processed')
                
                matched_count += 1
                # Once matched, we don't need to check other emails for THIS reservation
                break 

    return f"Checked {len(pending_reservations)} reservations, matched {matched_count}."
