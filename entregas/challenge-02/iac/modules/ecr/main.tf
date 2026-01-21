variable "project" {
  type = string
}

variable "environment" {
  type = string
}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "frontend" {
  name                        = "${var.project}/frontend"
  image_scanning_configuration { scan_on_push = true }
  force_delete                = true
  tags                        = merge(local.tags, { Component = "frontend" })
}

resource "aws_ecr_repository" "api" {
  name                        = "${var.project}/api"
  image_scanning_configuration { scan_on_push = true }
  force_delete                = true
  tags                        = merge(local.tags, { Component = "api" })
}

resource "aws_ecr_repository" "batch" {
  name                        = "${var.project}/batch"
  image_scanning_configuration { scan_on_push = true }
  force_delete                = true
  tags                        = merge(local.tags, { Component = "batch" })
}

output "frontend_repo_url" {
  value = aws_ecr_repository.frontend.repository_url
}

output "api_repo_url" {
  value = aws_ecr_repository.api.repository_url
}

output "batch_repo_url" {
  value = aws_ecr_repository.batch.repository_url
}
