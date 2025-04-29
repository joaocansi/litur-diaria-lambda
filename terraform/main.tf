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
  region     = "us-east-1"
}

resource "aws_lambda_function" "liturgia_extractor_function" {
  function_name = "liturgia_extractor"
  filename      = "../extractor/extractor.zip"
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.liturgia_lambda_role.arn

  source_code_hash = filebase64sha256("../extractor/extractor.zip")
  timeout          = 300

  environment {
    variables = {
      OPENAI_API_KEY = var.openai_api_key
    }
  }
}

resource "aws_lambda_function" "liturgia_mailer_function" {
  function_name = "liturgia_mailer"
  filename      = "../mailer/mailer.zip"
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.liturgia_lambda_role.arn

  source_code_hash = filebase64sha256("../mailer/mailer.zip")
  timeout          = 300

  environment {
    variables = {
      MAILER_TOKEN  = var.mailer_token
      MAILER_SENDER = var.mailer_sender
    }
  }
}

resource "aws_cloudwatch_event_rule" "liturgia_extractor_schedule" {
  name                = "liturgia_extractor_schedule"
  description         = "Trigger liturgia_extractor daily at 6 AM BRT (9 AM UTC)"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "liturgia_extractor_event_target" {
  rule      = aws_cloudwatch_event_rule.liturgia_extractor_schedule.name
  target_id = "liturgia_extractor_target"
  arn       = aws_lambda_function.liturgia_extractor_function.arn
}

resource "aws_lambda_permission" "liturgia_extractor_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.liturgia_extractor_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.liturgia_extractor_schedule.arn
}

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

resource "aws_iam_policy_attachment" "liturgia_lambda_basic_execution" {
  name       = "liturgia_lambda_basic_execution"
  roles      = [aws_iam_role.liturgia_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "liturgia_lambda_custom_access" {
  name       = "liturgia_lambda_custom_access"
  roles      = [aws_iam_role.liturgia_lambda_role.name]
  policy_arn = aws_iam_policy.liturgia_lambda_custom_policy.arn
}
