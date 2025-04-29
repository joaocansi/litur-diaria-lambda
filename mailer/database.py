from dotenv import load_dotenv
load_dotenv()

import boto3
from datetime import datetime

db = boto3.resource('dynamodb')
payment_table = db.Table('liturgia_Payment')
liturgia_table = db.Table('liturgia_LiturgiaDiaria')

def get_liturgia():
    today_date = datetime.now().strftime('%Y-%m-%d')
    response = liturgia_table.get_item(Key={'id': today_date})

    item = response.get('Item')
    if item:
        return item
    else:
        return None
    
def get_paid_payments():
    response = payment_table.scan(
        FilterExpression=boto3.dynamodb.conditions.Attr('status').eq('paid')
    )
    return response.get('Items', [])