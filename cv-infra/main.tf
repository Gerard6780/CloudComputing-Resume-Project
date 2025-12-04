# Main Terraform configuration file
# Orchestrates all resources for CV Portfolio infrastructure

# Note: Ensure lambda.zip exists before running terraform apply
# Create it with: cd ../cv-backend/lambda && zip -r ../../cv-infra/lambda.zip handler.py

locals {
  project_name = "cv-portfolio"
  lambda_zip   = "${path.module}/lambda.zip"
}
