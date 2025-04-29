terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "s3" {
    bucket         = "liturgia-terraform-state"
    key            = "terraform/state-lambda"
    region         = "us-east-1"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

# Função Lambda responsável por extrair os dados da liturgia
resource "aws_lambda_function" "liturgia_extractor_function" {
  function_name = "liturgia_extractor"
  filename      = "../extractor/extractor.zip"
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.liturgia_lambda_role.arn

  source_code_hash = filebase64sha256("../extractor/extractor.zip") # Garante que mudanças no código invalidem cache
  timeout          = 300 # Timeout de 5 minutos

  environment {
    variables = {
      OPENAI_API_KEY = var.openai_api_key
    }
  }
}

# Função Lambda responsável por enviar os e-mails
resource "aws_lambda_function" "liturgia_mailer_function" {
  function_name = "liturgia_mailer"
  filename      = "../mailer/mailer.zip"
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.liturgia_lambda_role.arn

  source_code_hash = filebase64sha256("../mailer/mailer.zip") # Garante que mudanças no código invalidem cache
  timeout          = 480 # Timeout de 8 minutos

  environment {
    variables = {
      MAILER_TOKEN  = var.mailer_token
      MAILER_SENDER = var.mailer_sender
      MAILER_LAMBDA_NAME = aws_lambda_function.liturgia_extractor_function.function_name
    }
  }
}

# Regra de agendamento do CloudWatch para executar a função de extração diariamente às 9h UTC (6h BRT)
resource "aws_cloudwatch_event_rule" "liturgia_extractor_schedule" {
  name                = "liturgia_extractor_schedule"
  description         = "Trigger liturgia_extractor daily at 6 AM BRT (9 AM UTC)"
  schedule_expression = "cron(0 9 * * ? *)"
}

# Associa a regra de evento à função Lambda de extração
resource "aws_cloudwatch_event_target" "liturgia_extractor_event_target" {
  rule      = aws_cloudwatch_event_rule.liturgia_extractor_schedule.name
  target_id = "liturgia_extractor_target"
  arn       = aws_lambda_function.liturgia_extractor_function.arn
}

# Permite que o CloudWatch invoque a função Lambda
resource "aws_lambda_permission" "liturgia_extractor_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.liturgia_extractor_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.liturgia_extractor_schedule.arn
}

# Define o papel IAM para a execução das funções Lambda
resource "aws_iam_role" "liturgia_lambda_role" {
  name = "liturgia_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Política personalizada para acesso a recursos do DynamoDB e outras Lambdas
resource "aws_iam_policy" "liturgia_lambda_custom_policy" {
  name = "liturgia_lambda_custom_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "dynamodb:*"
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Anexa a política básica de execução de Lambdas (logs no CloudWatch)
resource "aws_iam_policy_attachment" "liturgia_lambda_basic_execution" {
  name       = "liturgia_lambda_basic_execution"
  roles      = [aws_iam_role.liturgia_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Anexa a política customizada criada anteriormente
resource "aws_iam_policy_attachment" "liturgia_lambda_custom_access" {
  name       = "liturgia_lambda_custom_access"
  roles      = [aws_iam_role.liturgia_lambda_role.name]
  policy_arn = aws_iam_policy.liturgia_lambda_custom_policy.arn
}
