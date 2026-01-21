variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project" {
  type        = string
  description = "Project name"
  default     = "challenge01"
}

variable "environment" {
  type        = string
  description = "Environment (hml/prod)"
  default     = "hml"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC CIDR"
}

variable "task_image" {
  type        = string
  description = "Container image for FastAPI (ECR URI)"
  default     = "000000000000.dkr.ecr.us-east-1.amazonaws.com/fastapi:latest"
}

variable "admin_user" {
  type        = string
  description = "Admin user for the API (stored in plain env here; prefer Secrets Manager)"
  default     = "admin"
}

variable "admin_pass" {
  type        = string
  description = "Admin password for the API (stored in plain env here; prefer Secrets Manager)"
  default     = "change-me"
  sensitive   = true
}

variable "desired_count" {
  type    = number
  default = 2
}
