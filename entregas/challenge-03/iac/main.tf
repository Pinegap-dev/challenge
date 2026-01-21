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
  default     = "challenge03"
}

variable "environment" {
  type        = string
  default     = "hml"
}

variable "lambda_image_uri" {
  type        = string
  description = "ECR image URI for the Flask Lambda"
  default     = "000000000000.dkr.ecr.us-east-1.amazonaws.com/challenge-03:latest"
}

variable "name_value" {
  type        = string
  default     = "World"
  description = "Value for env NAME"
}

module "lambda_api" {
  source          = "./modules/lambda_api"
  project         = var.project
  environment     = var.environment
  lambda_image_uri = var.lambda_image_uri
  name_value      = var.name_value
}

output "api_endpoint" {
  value = module.lambda_api.api_endpoint
}
