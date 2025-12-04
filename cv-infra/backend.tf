terraform {
  backend "s3" {
    bucket = "terraform-state-leonilo"
    key    = "cv-portfolio/terraform.tfstate"
    region = "us-east-1"
  }
}
