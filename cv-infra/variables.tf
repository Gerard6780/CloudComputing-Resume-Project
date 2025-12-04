variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table for CVs"
  type        = string
  default     = "curriculums"
}

variable "lambda_function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "cv-portfolio-function"
}

variable "api_gateway_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "cv-portfolio-api"
}

variable "api_stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}
