terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

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

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

module "network" {
  source      = "../modules/network"
  project     = var.project
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
  az_count    = var.az_count

  allowed_egress_cidr = var.allowed_egress_cidr
}

module "kms" {
  source      = "../modules/kms"
  project     = var.project
  environment = var.environment
}

module "s3" {
  source      = "../modules/s3"
  project     = var.project
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
  kms_key_arn = module.kms.kms_s3_arn
}

module "ecr" {
  source      = "../modules/ecr"
  project     = var.project
  environment = var.environment
}

module "rds" {
  source                  = "../modules/rds"
  project                 = var.project
  environment             = var.environment
  db_username             = var.db_username
  db_password             = var.db_password
  subnet_ids              = module.network.private_data_subnets
  security_group_ids      = [module.network.rds_sg_id]
  kms_key_arn             = module.kms.kms_s3_arn
  availability_zone_count = var.az_count
}

module "eks" {
  source                = "../modules/eks"
  project               = var.project
  environment           = var.environment
  cluster_role_arn      = null
  node_role_arn         = null
  subnet_ids            = concat(module.network.private_app_subnets, module.network.public_subnets)
  node_subnet_ids       = module.network.private_app_subnets
  security_group_ids    = [module.network.eks_nodes_sg_id]
  tags                  = local.tags
}

module "batch_sfn" {
  source           = "../modules/batch_sfn"
  project          = var.project
  environment      = var.environment
  subnets          = module.network.private_app_subnets
  security_group   = module.network.eks_nodes_sg_id
  batch_job_image  = var.batch_job_image
  region           = var.region
}

module "edge" {
  source              = "../modules/edge"
  providers           = { aws = aws, aws.us_east_1 = aws.us_east_1 }
  enable_edge         = var.enable_edge
  enable_waf          = var.enable_waf
  domain_name         = var.domain_name
  hosted_zone_id      = var.hosted_zone_id
  origin_domain_name  = var.origin_domain_name
  acm_certificate_arn = var.acm_certificate_arn
  tags                = local.tags
  project             = var.project
  environment         = var.environment
}

data "aws_caller_identity" "current" {}

# Outputs
output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "private_app_subnets" {
  value = module.network.private_app_subnets
}

output "private_data_subnets" {
  value = module.network.private_data_subnets
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "s3_uploads_bucket" {
  value = module.s3.uploads_bucket
}

output "s3_results_bucket" {
  value = module.s3.results_bucket
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "batch_queue_arn" {
  value = module.batch_sfn.batch_queue_arn
}

output "state_machine_arn" {
  value = module.batch_sfn.state_machine_arn
}
