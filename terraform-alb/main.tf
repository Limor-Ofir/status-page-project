provider "aws" {
  region = "us-east-1"
}

# Declare variables
variable "vpc_id" {
  description = "The ID of the VPC where the resources will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs."
  type        = list(string)
}

variable "eks_cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}

# Data sources for existing resources
data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

data "aws_subnet" "private_subnets" {
  for_each = toset(var.private_subnet_ids)
  id       = each.value
}

data "aws_subnet" "public_subnets" {
  for_each = toset(var.public_subnet_ids)
  id       = each.value
}

data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  name = var.eks_cluster_name
}

variable "node_group_name" {
  description = "The name of the node group."
  type        = string
}
