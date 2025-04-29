from dotenv import load_dotenv
load_dotenv()

import requests
import json

from template import build_template
from database import get_liturgia, get_paid_payments
from datetime import datetime

import os
import time

mailer_token = os.getenv('MAILER_TOKEN')
mailer_sender = os.getenv('MAILER_SENDER')

def lambda_handler(event, context):
    if event is None or event['conteudo_html'] is None:
        return {
            "statusCode": 404,
            "body": "Liturgia not found"
        }
    
    liturgia = event
    today = datetime.now().strftime("%d/%m/%Y")
    template = build_template(today, liturgia['conteudo_html'])

    payments = get_paid_payments()
    url = "https://send.api.mailtrap.io/api/send"
    headers = {
        "Authorization": f"Bearer {mailer_token}",
        "Content-Type": "application/json"
    }

    for payment in payments:
        payload = {
            "from": {
                "email": mailer_sender,
                "name": "Reflexão da Liturgia"
            },
            "to": [{"email": payment['email']}],
            "subject": f"Reflexão da liturgia de hoje ({today})",
            "html": template
        }
        payload = json.dumps(payload)
        response = requests.request("POST", url, headers=headers, data=payload)
        print(f"Email sent to {payment['email']}: {response.status_code} - {response.text}")
        time.sleep(2)

    print("Finished")
    return {
        "statusCode": 200,
        "body": "Emails sent successfully"
    }
