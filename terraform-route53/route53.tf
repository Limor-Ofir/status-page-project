# Data source for the existing ALB
data "aws_lb" "existing_alb" {
  name = "limor-cluster-alb"  # Replace with the actual name of your ALB
}

# Create a new Route 53 hosted zone
resource "aws_route53_zone" "main" {
  name = var.domain_name  # e.g., "limor-status-page.online"
  
  tags = {  # Tagging section added
    Project = "TeamI"
  }
}

# A record pointing to the ALB using an alias
resource "aws_route53_record" "alb_a_record" {
  zone_id = aws_route53_zone.main.zone_id  # Use the new hosted zone ID
  name     = var.domain_name
  type     = "A"
  alias {
    name                   = data.aws_lb.existing_alb.dns_name  # ALB DNS name
    zone_id                = data.aws_lb.existing_alb.zone_id   # ALB hosted zone ID
    evaluate_target_health = true                               # Optional: Enable health checks
  }
}

# Declare the alb_dns_name variable
variable "alb_dns_name" {
  description = "The DNS name of the existing Application Load Balancer."
  type        = string
}

# Declare the domain_name variable
variable "domain_name" {
  description = "The domain name to point to the ALB."  # Ensure this string is complete
  type        = string
  default     = "limor-status-page.online"  # Set a default value if desired
}

# Declare the alb_zone_id variable
variable "alb_zone_id" {
  description = "The hosted zone ID for the existing Application Load Balancer."
  type        = string
}

# Output the Zone ID
output "zone_id" {
  value = aws_route53_zone.main.zone_id
}

