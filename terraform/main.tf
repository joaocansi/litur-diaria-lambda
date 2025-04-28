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
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}

resource "aws_lambda_function" "extractor" {
  function_name = "extractor"
  filename      = "../extractor/extractor.zip"
  handler       = "main.lambda_handler"
  runtime       = "python3.10"
  role          = aws_iam_role.lambda_exec.arn

  source_code_hash = filebase64sha256("../extractor/extractor.zip")

  timeout = 300

  environment {
    variables = {
      "OPENAI_API_KEY" = var.openai_api_key
    }
  }
}

resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "daily_trigger"
  description         = "Trigger Lambda daily at 6am BR Time"
  schedule_expression = "cron(0 9 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.extractor.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.extractor.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "dynamodb_access_policy" {
  name = "dynamodb_access_policy"

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

resource "aws_iam_policy_attachment" "lambda_exec_policy" {
  name       = "lambda_exec_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy_attachment" "dynamodb_access_policy_attachment" {
  name       = "dynamodb_access_policy_attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = aws_iam_policy.dynamodb_access_policy.arn
}
