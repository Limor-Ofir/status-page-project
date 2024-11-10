# Security Group for ALB (allowing HTTP and HTTPS)
resource "aws_security_group" "alb_sg" {
  name        = "${var.eks_cluster_name}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = data.aws_vpc.existing_vpc.id

  # Allow HTTP traffic to the ALB
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS traffic to the ALB
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule for ALB
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.eks_cluster_name}-alb-sg"
  }
}

# ALB Configuration
resource "aws_lb" "application_load_balancer" {
  name                     = "${var.eks_cluster_name}-alb"
  internal                 = false
  load_balancer_type       = "application"
  security_groups          = [aws_security_group.alb_sg.id]
  subnets                  = [for subnet in data.aws_subnet.public_subnets : subnet.id]
  enable_deletion_protection = false

  tags = {
    Name = "${var.eks_cluster_name}-alb"
  }
}

# Target Group for Nginx Service
resource "aws_lb_target_group" "nginx_tg" {
  name     = "${var.eks_cluster_name}-nginx-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.existing_vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.eks_cluster_name}-nginx-tg"
  }
}

# HTTP Listener for ALB (optional redirect)
resource "aws_lb_listener" "alb_http_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener for ALB
resource "aws_lb_listener" "alb_https_listener" {
  load_balancer_arn = aws_lb.application_load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn  # Pass the ACM Certificate ARN here

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

# Register the Nginx service with the Target Group
resource "aws_lb_target_group_attachment" "nginx_service_attachment" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = "i-0cff90d1e4caea61d" # Replace with the IP or instance ID of the Nginx service/pod
  port             = 80
}

