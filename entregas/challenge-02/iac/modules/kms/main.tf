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

resource "aws_kms_key" "s3" {
  description             = "KMS key for S3 buckets"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = merge(local.tags, { Name = "${var.project}-${var.environment}-kms-s3" })
}

resource "aws_kms_alias" "s3" {
  name          = "alias/${var.project}-${var.environment}-s3"
  target_key_id = aws_kms_key.s3.key_id
}

output "kms_s3_arn" {
  value = aws_kms_key.s3.arn
}
