resource "aws_acm_certificate" "alb_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags = {
    Name    = "TeamI-acm-certificate"
    Project = "TeamI"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.alb_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
      zone_id = data.aws_route53_zone.main.zone_id
    }
  }

  name    = each.value.name
  type    = each.value.type
  zone_id = each.value.zone_id
  records = [each.value.value]
  ttl     = 60
}

data "aws_route53_zone" "main" {
  name = var.domain_name
}

output "certificate_arn" {
  value = aws_acm_certificate.alb_cert.arn
}
