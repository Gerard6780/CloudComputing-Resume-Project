# Lambda function for CV API

resource "aws_lambda_function" "cv_handler" {
  filename         = local.lambda_zip
  function_name    = var.lambda_function_name
  role            = data.aws_iam_role.lab_role.arn  # Use existing LabRole
  handler         = "handler.lambda_handler"
  source_code_hash = filebase64sha256(local.lambda_zip)
  runtime         = "python3.12"
  timeout         = 30
  memory_size     = 256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.curriculums.name
    }
  }

  tags = {
    Name        = var.lambda_function_name
    Description = "CV portfolio API handler"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.lambda_function_name}-logs"
  }
}
