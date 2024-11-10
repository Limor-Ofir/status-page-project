# Provider Configuration
provider "aws" {
  region = var.aws_region
}

# Data source to use the existing IAM Policy for ALB Ingress Controller
data "aws_iam_policy" "alb_ingress_policy" {
  name = "ALBIngressControllerPolicy"
}

# Data source to use the existing IAM Role for ALB Ingress Controller
data "aws_iam_role" "alb_ingress_role" {
  name = "ALBIngressControllerRole"
}

# Attach the existing IAM Policy to the existing Role
resource "aws_iam_role_policy_attachment" "alb_ingress_policy_attachment" {
  role       = data.aws_iam_role.alb_ingress_role.name
  policy_arn = data.aws_iam_policy.alb_ingress_policy.arn
}
