# E-Transfer Payment Confirmation System Implementation Plan

## Overview
Implement E-transfer payment confirmation for seat selection system.

**Tech Stack:**
- Frontend: Vue 3 (existing)
- Backend: FastAPI + Celery + Redis (new)
- Database: Supabase (PostgreSQL)
- Email Checking: Gmail API (copy from overseas_api)

---

## User Flow
1. User selects seats → enters booking info (name, phone, E-transfer email)
2. System reserves seats for 24 hours, shows E-transfer payment instructions
3. Celery task checks Gmail every 2 minutes for Interac confirmation
4. If payment found → mark seats as sold
5. If 24 hours pass without payment → release seats

---

## Phase 1: Backend Project Setup

**Location:** `/Users/woohelps/CascadeProjects/seat-select/seat-select-backend/`

### 1.1 Create project structure
```
seat-select/seat-select-backend/
├── pyproject.toml
├── .env
├── src/
│   ├── main.py                 # FastAPI app
│   ├── config.py               # Settings
│   ├── database.py             # Supabase connection
│   ├── models/                 # SQLAlchemy models
│   │   ├── seat.py
│   │   ├── reservation.py
│   │   └── event.py
│   ├── schemas/                # Pydantic schemas
│   ├── api/v1/                 # API routes
│   │   ├── seats.py
│   │   ├── reservations.py
│   │   └── events.py
│   ├── services/               # Business logic
│   └── utils/gmail/            # Gmail API (copy from overseas_api)
│       ├── gmail_api.py
│       └── creds/
└── celery_app/
    ├── celery.py               # Celery config
    └── tasks/
        ├── payment_check.py    # E-transfer verification
        └── reservation_cleanup.py
```

### 1.2 Dependencies (pyproject.toml)
- fastapi, uvicorn, sqlalchemy, asyncpg
- celery, redis
- google-api-python-client, google-auth-oauthlib
- pydantic, pydantic-settings

---

## Phase 2: Database Schema (Supabase)

### Tables to create:

**events**
- id, name, hall_name, show_time, price_per_seat, max_seats_per_booking, is_active

**seats**
- id, event_id, seat_id, row_label, col_label, g_row, g_col, seat_type, price
- status: `available` | `reserved` | `sold`
- other_love_seat_id (for couple seats)

**reservations**
- id, event_id, customer_name, customer_phone, customer_email
- total_amount, status: `pending` | `paid` | `expired` | `cancelled`
- reservation_expires_at (24 hours from creation)
- payment_confirmed_at

**reservation_seats**
- id, reservation_id, seat_id

---

## Phase 3: FastAPI Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/events/{id}/seats` | Get seats with status |
| POST | `/api/v1/reservations` | Create reservation (reserve seats 24h) |
| GET | `/api/v1/reservations/{id}` | Get reservation status |
| DELETE | `/api/v1/reservations/{id}` | Cancel reservation |
| POST | `/api/v1/admin/confirm-payment/{id}` | Manual payment confirm |

### POST /reservations Request:
```json
{
  "event_id": "uuid",
  "customer_name": "张先生",
  "customer_phone": "+1234567890",
  "customer_email": "customer@email.com",
  "seat_ids": ["16879097", "16879099"]
}
```

### Response:
```json
{
  "reservation_id": "uuid",
  "status": "pending",
  "total_amount": 138.00,
  "expires_at": "2026-01-02T15:30:00Z",
  "etransfer_email": "your-business@email.com",
  "message": "Please send E-transfer of $138.00 within 24 hours"
}
```

---

## Phase 4: Celery Tasks

### 4.1 Payment Check Task (every 2 minutes)
- Query pending reservations (not expired)
- For each, search Gmail for Interac email matching amount
- If found: update reservation to `paid`, seats to `sold`
- Copy Gmail search logic from: `/Users/woohelps/expoprojects/overseas_api/src/utils/gmail/gmail_api.py`

### 4.2 Cleanup Task (every 10 minutes)
- Find expired pending reservations
- Update status to `expired`
- Release seats back to `available`

### Gmail Search Query:
```
from:[catch|notify]@payments.interac.ca
subject:has been automatically deposited
after:{reservation_date}
in:inbox {amount}
```

---

## Phase 5: Frontend Modifications

### 5.1 New: `BookingForm.vue`
Location: `src/pages/hallseat/component/BookingForm.vue`
- Modal form with: 称呼, 电话, E-transfer邮箱
- Validation
- Submit to POST /reservations
- Show E-transfer instructions on success

### 5.2 Modify: `ConfirmLock.vue`
Location: `src/pages/hallseat/component/ConfirmLock.vue`
- Replace `alert('在这里开始走锁座逻辑')` with BookingForm trigger
- Emit event to show booking modal

### 5.3 Modify: `HallSeat.vue`
Location: `src/pages/hallseat/HallSeat.vue`
- Change data source from `/mock/seats.json` to backend API
- Add event_id handling
- Integrate BookingForm component

### 5.4 New: `ReservationStatus.vue`
Location: `src/pages/reservation/ReservationStatus.vue`
- Show reservation details
- E-transfer payment instructions
- 24-hour countdown timer
- Poll for payment status

### 5.5 Update: `router.js`
- Add route: `/reservation/:id` → ReservationStatus

### 5.6 Update: `http.js`
- Configure backend API base URL

---

## Implementation Order

1. **Backend setup** - Project structure, Supabase connection
2. **Database** - Create tables in Supabase
3. **Models & Schemas** - SQLAlchemy models, Pydantic schemas
4. **Events API** - GET /events/{id}/seats
5. **Reservations API** - POST, GET, DELETE
6. **Gmail integration** - Copy from overseas_api, test
7. **Celery setup** - Redis, tasks, beat schedule
8. **Frontend BookingForm** - New component
9. **Frontend integration** - Modify ConfirmLock, HallSeat
10. **ReservationStatus page** - Status display, polling
11. **Testing** - End-to-end flow

---

## Key Files to Modify/Create

**Backend (new):**
- `seat-select-backend/src/main.py`
- `seat-select-backend/src/api/v1/reservations.py`
- `seat-select-backend/src/utils/gmail/gmail_api.py` (copy from overseas_api)
- `seat-select-backend/celery_app/tasks/payment_check.py`

**Frontend (modify):**
- `/Users/woohelps/CascadeProjects/seat-select/src/pages/hallseat/component/ConfirmLock.vue`
- `/Users/woohelps/CascadeProjects/seat-select/src/pages/hallseat/HallSeat.vue`
- `/Users/woohelps/CascadeProjects/seat-select/src/http.js`
- `/Users/woohelps/CascadeProjects/seat-select/src/router.js`

**Reference:**
- `/Users/woohelps/expoprojects/overseas_api/src/utils/gmail/gmail_api.py`
- `/Users/woohelps/expoprojects/overseas_api/src/applet/tasks.py` (lines 1626-1688)

---

## Gmail API Setup (New Credentials Required)

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create new project or select existing
3. Enable Gmail API
4. Create OAuth 2.0 credentials (Desktop app)
5. Download `credentials.json` to `seat-select-backend/src/utils/gmail/creds/`
6. First run will prompt for OAuth consent, generates `token.pickle`

---

## Environment Variables (.env)

```env
SUPABASE_URL=https://xxx.supabase.co
SUPABASE_KEY=your-service-role-key
DATABASE_URL=postgresql://...
REDIS_URL=redis://localhost:6379/0
GMAIL_CREDENTIALS_PATH=./src/utils/gmail/creds/credentials.json
ETRANSFER_RECEIVE_EMAIL=your-business@email.com
RESERVATION_EXPIRY_HOURS=24
CORS_ORIGINS=http://localhost:8080
```
