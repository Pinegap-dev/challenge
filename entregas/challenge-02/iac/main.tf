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

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

module "network" {
  source              = "../challenge-04/modules/network"
  project             = var.project
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  az_count            = var.az_count
  allowed_egress_cidr = var.allowed_egress_cidr
}

module "kms" {
  source      = "../challenge-04/modules/kms"
  project     = var.project
  environment = var.environment
}

module "s3" {
  source      = "../challenge-04/modules/s3"
  project     = var.project
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
  kms_key_arn = module.kms.kms_s3_arn
}

module "ecr" {
  source      = "../challenge-04/modules/ecr"
  project     = var.project
  environment = var.environment
}

module "rds" {
  source                  = "../challenge-04/modules/rds"
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
  source             = "../challenge-04/modules/eks"
  project            = var.project
  environment        = var.environment
  subnet_ids         = concat(module.network.private_app_subnets, module.network.public_subnets)
  node_subnet_ids    = module.network.private_app_subnets
  security_group_ids = [module.network.eks_nodes_sg_id]
  tags               = local.tags
}

module "batch_sfn" {
  source          = "../challenge-04/modules/batch_sfn"
  project         = var.project
  environment     = var.environment
  subnets         = module.network.private_app_subnets
  security_group  = module.network.eks_nodes_sg_id
  batch_job_image = var.batch_job_image
  region          = var.region
}

data "aws_caller_identity" "current" {}

output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "private_app_subnets" {
  value = module.network.private_app_subnets
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
