provider "aws" {
  region = "us-east-1"
}

# ACM Certificate
module "acm_certificate" {
  source      = "./acm"  # Ensure this is referencing the correct directory
  domain_name = var.domain_name  # Pass the domain_name variable
}

# IAM Permissions for DNS validation in Route 53
module "acm_iam" {
  source = "./iam"  # Ensure this is referencing the correct directory
}

