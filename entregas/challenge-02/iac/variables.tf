variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "challenge02"
  description = "Project prefix"
}

variable "environment" {
  type        = string
  default     = "hml"
  description = "Environment (hml/prod)"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "VPC CIDR"
}

variable "az_count" {
  type    = number
  default = 2
}

variable "db_username" {
  type    = string
  default = "dbadmin"
}

variable "db_password" {
  type      = string
  default   = "CHANGE_ME"
  sensitive = true
}

variable "batch_job_image" {
  type        = string
  default     = "public.ecr.aws/amazonlinux/amazonlinux:latest"
  description = "Container image for Batch jobs"
}

variable "allowed_egress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "enable_edge" {
  type        = bool
  default     = false
  description = "Enable CloudFront/Route53/ACM/WAF edge stack"
}

variable "enable_waf" {
  type        = bool
  default     = false
  description = "Attach WAF when edge is enabled"
}

variable "domain_name" {
  type        = string
  default     = ""
  description = "Public domain (e.g. app.example.com) for CloudFront/ALB"
}

variable "hosted_zone_id" {
  type        = string
  default     = ""
  description = "Route53 hosted zone ID"
}

variable "origin_domain_name" {
  type        = string
  default     = ""
  description = "Origin ALB/Ingress DNS (created by K8s ingress controller)"
}

variable "acm_certificate_arn" {
  type        = string
  default     = ""
  description = "Existing ACM cert in us-east-1 (optional)"
}

variable "alarm_email" {
  type        = string
  default     = ""
  description = "Email to subscribe SNS alerts (CloudWatch alarms/Backup)"
}

variable "rotation_app_version" {
  type        = string
  default     = "1.1.0"
  description = "Semantic version of the Secrets Manager RDS rotation application"
}
