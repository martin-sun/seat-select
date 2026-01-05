import os
import base64
import json
import pickle
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from googleapiclient.discovery import build
from google_auth_oauthlib.flow import InstalledAppFlow
from google.auth.transport.requests import Request
from src.config import settings

# If modifying these SCOPES, delete the file token.pickle.
SCOPES = [
    'https://www.googleapis.com/auth/gmail.readonly',
    'https://www.googleapis.com/auth/gmail.send',
    'https://www.googleapis.com/auth/gmail.modify',
    'https://www.googleapis.com/auth/gmail.compose'
]

class GmailAPI:
    def __init__(self):
        self.service = self._get_service()

    def _get_service(self):
        creds = None
        if os.path.exists(settings.GMAIL_TOKEN_PATH):
            with open(settings.GMAIL_TOKEN_PATH, 'rb') as token:
                creds = pickle.load(token)
        
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                if not os.path.exists(settings.GMAIL_CREDENTIALS_PATH):
                    raise FileNotFoundError(f"Credentials file not found at {settings.GMAIL_CREDENTIALS_PATH}")
                flow = InstalledAppFlow.from_client_secrets_file(
                    settings.GMAIL_CREDENTIALS_PATH, SCOPES)
                creds = flow.run_local_server(port=0)
            
            with open(settings.GMAIL_TOKEN_PATH, 'wb') as token:
                pickle.dump(creds, token)

        return build('gmail', 'v1', credentials=creds)

    def search_messages(self, query):
        try:
            result = self.service.users().messages().list(userId='me', q=query).execute()
            messages = result.get('messages', [])
            return messages
        except Exception as e:
            print(f"Error searching messages: {e}")
            return []

    def get_message_detail(self, msg_id):
        try:
            message = self.service.users().messages().get(userId='me', id=msg_id, format='full').execute()
            return message
        except Exception as e:
            print(f"Error getting message detail: {e}")
            return None

    def send_email(self, to, subject, body, body_type='plain'):
        """
        Sends an email using the Gmail API.
        """
        try:
            message = MIMEText(body, body_type)
            message['to'] = to
            message['subject'] = subject
            
            raw_message = base64.urlsafe_b64encode(message.as_bytes()).decode('utf-8')
            
            sent_message = self.service.users().messages().send(
                userId='me', 
                body={'raw': raw_message}
            ).execute()
            
            print(f"Message Id: {sent_message['id']} sent to {to}")
            return sent_message
        except Exception as e:
            print(f"Error sending email: {e}")
            return None

    def mark_as_processed(self, msg_id, label_name='Processed'):
        """
        Moves email from INBOX to another label.
        """
        try:
            # First, ensure the label exists
            results = self.service.users().labels().list(userId='me').execute()
            labels = results.get('labels', [])
            label_id = None
            for label in labels:
                if label['name'] == label_name:
                    label_id = label['id']
                    break
            
            if not label_id:
                # Create label if it doesn't exist
                label_body = {
                    'name': label_name,
                    'labelListVisibility': 'labelShow',
                    'messageListVisibility': 'show'
                }
                new_label = self.service.users().labels().create(userId='me', body=label_body).execute()
                label_id = new_label['id']

            # Modify labels: remove INBOX, add the target label
            self.service.users().messages().modify(
                userId='me',
                id=msg_id,
                body={
                    'addLabelIds': [label_id],
                    'removeLabelIds': ['INBOX']
                }
            ).execute()
            print(f"Message {msg_id} marked as {label_name} and removed from INBOX")
            return True
        except Exception as e:
            print(f"Error marking message as processed: {e}")
            return False

    def parse_interac_payment(self, message):
        """
        Parses Interac payment email to extract amount and sender.
        """
        payload = message.get('payload', {})
        headers = payload.get('headers', [])
        
        subject = ""
        for h in headers:
            if h['name'] == 'Subject':
                subject = h['value']
        
        snippet = message.get('snippet', '')
        body = self._get_body(payload)
        
        return {
            "subject": subject,
            "snippet": snippet,
            "body": body
        }

    def _get_body(self, payload):
        if 'parts' in payload:
            for part in payload['parts']:
                if part['mimeType'] == 'text/plain':
                    data = part['body'].get('data')
                    if data:
                        return base64.urlsafe_b64decode(data).decode('utf-8')
        else:
            data = payload.get('body', {}).get('data')
            if data:
                return base64.urlsafe_b64decode(data).decode('utf-8')
        return ""

gmail_api = None
def get_gmail_api():
    global gmail_api
    if not gmail_api:
        try:
            gmail_api = GmailAPI()
        except Exception as e:
            print(f"Failed to initialize Gmail API: {e}")
            return None
    return gmail_api
