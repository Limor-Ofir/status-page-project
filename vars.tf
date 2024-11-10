# AWS Region
variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
}

# IAM Policy Name
variable "alb_ingress_policy_name" {
  description = "Name of the IAM policy for ALB Ingress Controller"
  type        = string
  default     = "ALBIngressControllerPolicy"
}

# IAM Role Name
variable "alb_ingress_role_name" {
  description = "Name of the IAM role for ALB Ingress Controller"
  type        = string
  default     = "ALBIngressControllerRole"
}

# EKS Cluster Name
variable "eks_cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}
