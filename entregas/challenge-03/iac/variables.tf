variable "region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region"
}

variable "project" {
  type        = string
  default     = "challenge03"
  description = "Project prefix"
}

variable "environment" {
  type        = string
  default     = "hml"
  description = "Environment (hml/prod)"
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
