provider "aws" {
  region = "us-east-1"
}

# Variables Definition
variable "eks_cluster_name" {}
variable "node_group_name" {}
variable "vpc_id" {}
variable "private_subnet_ids" {
  type = list(string)
}

# Security Group for EKS Cluster
resource "aws_security_group" "eks_sg" {
  name   = "${var.eks_cluster_name}-sg"
  vpc_id = var.vpc_id  

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eks_cluster_name}-sg"
  }
}

# Security Group for EKS Nodes
resource "aws_security_group" "eks_nodes" {
  vpc_id = var.vpc_id
  
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eks_cluster_name}-nodes-sg"
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name = "${var.eks_cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      },
    ]
  })
}

# IAM Policy Attachment for EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_policy" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# EKS Cluster
resource "aws_eks_cluster" "my_cluster" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    security_group_ids      = [aws_security_group.eks_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy]
}

# IAM Role for Node Groups
resource "aws_iam_role" "eks_node_role" {
  name = "${var.node_group_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "eks.amazonaws.com",
            "ec2.amazonaws.com"
          ]
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policies Attachment for Node Groups
resource "aws_iam_role_policy_attachment" "eks_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_readonly_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Inline Policy for Additional Node Permissions
resource "aws_iam_role_policy" "eks_custom_node_policy" {
  name = "eksNodeCustomPolicy"
  role = aws_iam_role.eks_node_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListNodegroups",
          "eks:DescribeNodegroup"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Node Group for Application
resource "aws_eks_node_group" "node_group_application" {
  cluster_name    = aws_eks_cluster.my_cluster.name
  node_group_name = "${var.node_group_name}-application"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = 2  # Change these values as needed
    max_size     = 3
    min_size     = 1
  }

  depends_on = [aws_eks_cluster.my_cluster]
}
