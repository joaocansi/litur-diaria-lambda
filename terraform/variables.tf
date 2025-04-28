variable "openai_api_key" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type      = string
  default   = "us-east-1"
  sensitive = true
}

variable "aws_access_key_id" {
  type      = string
  sensitive = true
}

variable "aws_secret_access_key" {
  type      = string
  sensitive = true
}
