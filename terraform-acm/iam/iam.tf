resource "aws_iam_policy" "acm_dns_validation" {
  name        = "TeamI-ACM-DNS-Validation"
  description = "IAM policy for ACM DNS validation with Route 53"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "route53:GetChange",
          "route53:ChangeResourceRecordSets",
          "route53:ListHostedZonesByName",
          "route53:ListResourceRecordSets"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "acm_dns_validation_role" {
  name               = "TeamI-ACM-DNS-Validation-Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "acm.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "acm_dns_validation_attach" {
  role       = aws_iam_role.acm_dns_validation_role.name
  policy_arn = aws_iam_policy.acm_dns_validation.arn
}
