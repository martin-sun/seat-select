from datetime import datetime, timezone
from celery_app.celery import app
from src.database import supabase

@app.task
def cleanup_reservations():
    """
    Finds expired pending reservations and releases the seats.
    """
    now = datetime.now(timezone.utc).isoformat()
    
    # 1. Find expired 'pending' reservations
    response = supabase.table("reservations") \
        .select("id") \
        .eq("status", "pending") \
        .lt("expires_at", now) \
        .execute()
    
    expired_reservations = response.data
    
    if not expired_reservations:
        return f"No expired reservations found at {now}"
    
    ids = [r["id"] for r in expired_reservations]
    
    # 2. Update reservations to 'expired'
    supabase.table("reservations") \
        .update({"status": "expired", "updated_at": now}) \
        .in_("id", ids) \
        .execute()
    
    # 3. Release seats associated with these reservations
    supabase.table("seats") \
        .update({
            "status": "available", 
            "reservation_id": None, 
            "locked_until": None,
            "updated_at": now
        }) \
        .in_("reservation_id", ids) \
        .execute()
    
    return f"Cleaned up {len(ids)} expired reservations: {ids}"
