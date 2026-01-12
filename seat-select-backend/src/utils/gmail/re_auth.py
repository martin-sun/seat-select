"""
One-time script to re-authorize Gmail API.
Run this locally when the token has expired or been revoked.
"""
import os
import pickle
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from src.config import settings

SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/gmail.compose'
]


def re_authenticate():
    """Delete old token and create a new one."""
    print(f"Current token path: {settings.GMAIL_TOKEN_PATH}")
    print(f"Credentials path: {settings.GMAIL_CREDENTIALS_PATH}")

    # Step 1: Delete old token if exists
    if os.path.exists(settings.GMAIL_TOKEN_PATH):
        print(f"\nDeleting old token: {settings.GMAIL_TOKEN_PATH}")
        os.remove(settings.GMAIL_TOKEN_PATH)
        print("Old token deleted.")
    else:
        print("\nNo existing token found.")

    # Step 2: Check credentials file exists
    if not os.path.exists(settings.GMAIL_CREDENTIALS_PATH):
        raise FileNotFoundError(f"Credentials file not found at {settings.GMAIL_CREDENTIALS_PATH}")

    # Step 3: Run OAuth flow
    print("\nStarting OAuth flow...")
    print("A browser window will open. Please authorize the application.")
    flow = InstalledAppFlow.from_client_secrets_file(
        settings.GMAIL_CREDENTIALS_PATH,
        SCOPES,
        redirect_uri='urn:ietf:wg:oauth:2.0:oob')
    creds = flow.run_local_server(
        port=0,
        access_type='offline',  # Get refresh_token for offline access
        prompt='consent',       # Force consent screen to ensure refresh_token is returned
        include_granted_scopes='true')

    # Step 4: Save new token
    print(f"\nSaving new token to: {settings.GMAIL_TOKEN_PATH}")
    with open(settings.GMAIL_TOKEN_PATH, 'wb') as token:
        pickle.dump(creds, token)
    print("New token saved successfully!")

    print("\nRe-authorization complete! You can now restart Celery.")


if __name__ == "__main__":
    re_authenticate()
