variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project" {
  description = "Project prefix"
  type        = string
  default     = "biotech-x"
}

variable "environment" {
  description = "Environment (hml/prod)"
  type        = string
  default     = "hml"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to use"
  type        = number
  default     = 2
}

variable "db_username" {
  description = "RDS master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "RDS master password"
  type        = string
  default     = "CHANGE_ME"
  sensitive   = true
}

variable "batch_job_image" {
  description = "Container image for Batch jobs"
  type        = string
  default     = "public.ecr.aws/amazonlinux/amazonlinux:latest"
}

variable "enable_edge" {
  description = "Enable CloudFront/Route53/ACM/WAF for ALB/Ingress"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Domain name to serve via CloudFront/ALB (e.g., app.example.com)"
  type        = string
  default     = ""
}

variable "hosted_zone_id" {
  description = "Route53 hosted zone ID for the domain"
  type        = string
  default     = ""
}

variable "origin_domain_name" {
  description = "Origin DNS name (ALB/Ingress) for CloudFront"
  type        = string
  default     = ""
}

variable "acm_certificate_arn" {
  description = "Existing ACM certificate ARN (us-east-1) for CloudFront. If empty, a new one is requested."
  type        = string
  default     = ""
}

variable "enable_waf" {
  description = "Enable a WAFv2 Web ACL on the CloudFront distribution"
  type        = bool
  default     = false
}

variable "allowed_egress_cidr" {
  description = "Default egress CIDR"
  type        = string
  default     = "0.0.0.0/0"
}
