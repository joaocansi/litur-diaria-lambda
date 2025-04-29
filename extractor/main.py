import json
from datetime import datetime
from scraper import scrape_liturgia
from homily_generator import generate_homily
from database import create_table_if_not_exists
from config import dynamodb_table, lambda_client
from bs4 import BeautifulSoup

import os

def lambda_handler(event, context):
    create_table_if_not_exists()
    try:
        liturgia_completa = scrape_liturgia()
        reflexao = generate_homily(liturgia_completa)
        soup_reflexao = BeautifulSoup(reflexao, 'html.parser')
        titulo = soup_reflexao.find('h3').get_text(strip=True) if soup_reflexao.find('h3') else "Homilia do Dia"
        today = datetime.now().strftime('%Y-%m-%d')
        item = {
            'id': today,
            'titulo': titulo,
            'conteudo_html': reflexao,
            'created_at': datetime.now().isoformat()
        }
        dynamodb_table.put_item(Item=item)
        payload = {
            'id': today,
            'titulo': titulo,
            'conteudo_html': reflexao
        }
        lambda_client.invoke(
            FunctionName=os.getenv('MAILER_LAMBDA_NAME'),
            InvocationType='Event',
            Payload=json.dumps(payload)
        )
        return { 'statusCode': 200, 'body': json.dumps('Homilia salva com sucesso!') }
    except Exception as e:
        return { 'statusCode': 500, 'body': json.dumps(str(e)) }
