from dotenv import load_dotenv
import os
import boto3
from openai import OpenAI

load_dotenv()

openai_client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
dynamodb_table = dynamodb.Table('liturgia_LiturgiaDiaria')
lambda_client = boto3.client('lambda', region_name='us-east-1')
