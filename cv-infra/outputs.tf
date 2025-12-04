output "api_url" {
  description = "URL of the API Gateway endpoint"
  value       = "${aws_api_gateway_deployment.main.invoke_url}${aws_api_gateway_stage.main.stage_name}/cv"
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.main.id
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.cv_handler.function_name
}

output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.cv_handler.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.curriculums.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.curriculums.arn
}

output "instructions" {
  description = "Next steps after deployment"
  value       = <<-EOT
    ✅ Infrastructure deployed successfully!
    
    Next steps:
    1. Update frontend api.js with API URL: ${aws_api_gateway_deployment.main.invoke_url}${aws_api_gateway_stage.main.stage_name}/cv
    2. Insert test data into DynamoDB table: ${aws_dynamodb_table.curriculums.name}
    3. Deploy frontend to AWS Amplify
    
    Test the API:
    curl "${aws_api_gateway_deployment.main.invoke_url}${aws_api_gateway_stage.main.stage_name}/cv?id=portfolio1"
  EOT
}
