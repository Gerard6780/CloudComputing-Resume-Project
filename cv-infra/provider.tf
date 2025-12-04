terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  # AWS Learner Lab uses LabRole
  # No need to specify credentials, they are provided by the environment
  
  default_tags {
    tags = {
      Project     = "CV-Portfolio"
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
