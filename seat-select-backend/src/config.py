import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    SUPABASE_URL: str = os.getenv("SUPABASE_URL", "")
    SUPABASE_KEY: str = os.getenv("SUPABASE_KEY", "")
    REDIS_URL: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")
    
    GMAIL_CREDENTIALS_PATH: str = os.getenv("GMAIL_CREDENTIALS_PATH", "./src/utils/gmail/creds/credentials.json")
    GMAIL_TOKEN_PATH: str = os.getenv("GMAIL_TOKEN_PATH", "./src/utils/gmail/creds/token.pickle")
    ETRANSFER_RECEIVE_EMAIL: str = os.getenv("ETRANSFER_RECEIVE_EMAIL", "")
    
    RESERVATION_EXPIRY_HOURS: int = int(os.getenv("RESERVATION_EXPIRY_HOURS", "24"))

settings = Settings()

# Debug: Check if Supabase key is loaded
if not settings.SUPABASE_KEY:
    print("WARNING: SUPABASE_KEY is empty!")
else:
    print(f"DEBUG: SUPABASE_KEY loaded (length: {len(settings.SUPABASE_KEY)})")
