# IAM configuration for Lambda function
# AWS Learner Lab only allows using the existing LabRole

# Data source to get the existing LabRole
data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

# Note: In AWS Learner Lab, you cannot create custom IAM roles or policies.
# The LabRole already has permissions for:
# - Lambda execution (CloudWatch Logs)
# - DynamoDB full access
# - And many other AWS services
#
# This is sufficient for our Lambda function to:
# 1. Write logs to CloudWatch
# 2. Read/Write to DynamoDB
# 3. Be invoked by API Gateway
