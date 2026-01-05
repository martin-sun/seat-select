import os
from celery import Celery
from celery.schedules import crontab
from dotenv import load_dotenv

load_dotenv()

redis_url = os.getenv("REDIS_URL", "redis://localhost:6379/0")

app = Celery(
    "seat_select_tasks",
    broker=redis_url,
    backend=redis_url,
    include=[
        "celery_app.tasks.payment_check", 
        "celery_app.tasks.reservation_cleanup",
        "celery_app.tasks.instruction_sender"
    ]
)

app.conf.update(
    result_expires=3600,
    timezone="America/Regina",
    enable_utc=True,
)

app.conf.beat_schedule = {
    "check-payments-every-minute": {
        "task": "celery_app.tasks.payment_check.check_payments",
        "schedule": 60.0,  # every 1 minute
    },
    "cleanup-expired-reservations-every-10-minutes": {
        "task": "celery_app.tasks.reservation_cleanup.cleanup_reservations",
        "schedule": crontab(minute="*/10"),
    },
    "send-instructions-every-minute": {
        "task": "celery_app.tasks.instruction_sender.send_payment_instructions",
        "schedule": 60.0,  # every 1 minute
    },
}

if __name__ == "__main__":
    app.start()
