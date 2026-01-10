from supabase import create_client, Client
from src.config import settings

def get_supabase() -> Client:
    return create_client(settings.SUPABASE_URL, settings.SUPABASE_KEY)

supabase: Client = get_supabase()

# Admin client for accessing auth.users and other system tables
# Requires SUPABASE_SERVICE_ROLE_KEY for elevated privileges
supabase_admin: Client = create_client(
    settings.SUPABASE_URL,
    settings.SUPABASE_SERVICE_ROLE_KEY
)
