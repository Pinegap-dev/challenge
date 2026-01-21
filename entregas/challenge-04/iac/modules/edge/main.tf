variable "enable_edge" {
  type        = bool
  default     = false
  description = "Enable CloudFront + Route53 + ACM + optional WAF"
}

variable "enable_waf" {
  type        = bool
  default     = false
  description = "Attach a WAFv2 Web ACL to CloudFront"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Domain name (e.g., app.example.com)"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Route53 hosted zone ID for domain"
}

variable "origin_domain_name" {
  type        = string
  default     = ""
  description = "Origin DNS name (ALB/Ingress)"
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "Existing ACM cert ARN (us-east-1). If empty, a new one is requested."
}

variable "project" {
  type        = string
  description = "Project tag"
}

variable "environment" {
  type        = string
  description = "Environment tag"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra tags"
}

locals {
  enabled = var.enable_edge && var.domain_name != "" && var.hosted_zone_id != "" && var.origin_domain_name != ""
  tags    = merge(var.tags, { Project = var.project, Environment = var.environment })
}

# Certificate in us-east-1 for CloudFront
resource "aws_acm_certificate" "this" {
  provider                  = aws.us_east_1
  count                     = local.enabled && var.acm_certificate_arn == "" ? 1 : 0
  domain_name               = var.domain_name
  validation_method         = "DNS"
  subject_alternative_names = []
  tags                      = merge(local.tags, { Name = "${var.project}-${var.environment}-cert" })
}

resource "aws_route53_record" "cert_validation" {
  count   = local.enabled && var.acm_certificate_arn == "" ? length(aws_acm_certificate.this[0].domain_validation_options) : 0
  name    = aws_acm_certificate.this[0].domain_validation_options[count.index].resource_record_name
  type    = aws_acm_certificate.this[0].domain_validation_options[count.index].resource_record_type
  zone_id = var.hosted_zone_id
  records = [aws_acm_certificate.this[0].domain_validation_options[count.index].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "this" {
  provider        = aws.us_east_1
  count           = local.enabled && var.acm_certificate_arn == "" ? 1 : 0
  certificate_arn = aws_acm_certificate.this[0].arn
  validation_record_fqdns = [
    for r in aws_route53_record.cert_validation : r.fqdn
  ]
}

resource "aws_wafv2_web_acl" "this" {
  count       = local.enabled && var.enable_waf ? 1 : 0
  name        = "${var.project}-${var.environment}-waf"
  description = "Edge WAF"
  scope       = "CLOUDFRONT"
  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }
  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1
    override_action { none {} }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "common"
      sampled_requests_enabled   = true
    }
  }
  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-waf" })
}

resource "aws_cloudfront_distribution" "this" {
  count               = local.enabled ? 1 : 0
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.project}-${var.environment}-cf"
  default_root_object = ""

  origin {
    domain_name = var.origin_domain_name
    origin_id   = "origin-alb"
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = "origin-alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies { forward = "all" }
    }
    compress = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn != "" ? var.acm_certificate_arn : aws_acm_certificate.this[0].arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  web_acl_id = var.enable_waf ? aws_wafv2_web_acl.this[0].arn : null

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-cf" })

  depends_on = var.acm_certificate_arn != "" ? [] : [aws_acm_certificate_validation.this]
}

resource "aws_route53_record" "alias_cf" {
  count   = local.enabled ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.this[0].domain_name
    zone_id                = aws_cloudfront_distribution.this[0].hosted_zone_id
    evaluate_target_health = false
  }
}

output "cloudfront_domain_name" {
  value       = local.enabled ? aws_cloudfront_distribution.this[0].domain_name : null
  description = "CloudFront domain"
}

output "cloudfront_distribution_id" {
  value       = local.enabled ? aws_cloudfront_distribution.this[0].id : null
  description = "CloudFront distribution ID"
}

output "waf_arn" {
  value       = local.enabled && var.enable_waf ? aws_wafv2_web_acl.this[0].arn : null
  description = "WAFv2 Web ACL ARN"
}
