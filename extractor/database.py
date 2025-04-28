import boto3
import os 
from config import dynamodb

def create_table_if_not_exists():
    try:
        dynamodb = boto3.client('dynamodb')
        dynamodb.describe_table(TableName='liturgia_LiturgiaDiaria')
        print("Tabela já existe.")
    except dynamodb.exceptions.ResourceNotFoundException:
        dynamodb.create_table(
            TableName='liturgia_LiturgiaDiaria',
            KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
            AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}],
            ProvisionedThroughput={'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
        )
        print("Tabela criada com sucesso.")
