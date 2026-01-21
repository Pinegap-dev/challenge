terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

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

module "network" {
  source          = "./modules/network"
  project         = var.project
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  az_count        = 2
  allowed_egress_cidr = "0.0.0.0/0"
}

module "ecs_fastapi" {
  source             = "./modules/ecs_fastapi"
  project            = var.project
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  public_subnets     = module.network.public_subnets
  private_subnets    = module.network.private_app_subnets
  alb_sg_id          = module.network.alb_sg_id
  app_sg_id          = module.network.app_sg_id
  task_image         = var.task_image
  desired_count      = var.desired_count
  admin_user         = var.admin_user
  admin_pass         = var.admin_pass
}

output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns" {
  value = module.ecs_fastapi.alb_dns
}

output "service_name" {
  value = module.ecs_fastapi.service_name
}
