variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "account_id" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

# Central log bucket for access logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-${var.environment}-logs-${var.account_id}"
  tags   = merge(local.tags, { Purpose = "logs" })
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket" "uploads" {
  bucket = "${var.project}-${var.environment}-uploads-${var.account_id}"
  tags   = merge(local.tags, { Purpose = "uploads" })
}

resource "aws_s3_bucket_public_access_block" "uploads" {
  bucket                  = aws_s3_bucket.uploads.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "uploads/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "uploads" {
  bucket = aws_s3_bucket.uploads.id
  rule {
    id     = "expire-365-days"
    status = "Enabled"
    expiration { days = 365 }
  }
}

resource "aws_s3_bucket" "results" {
  bucket = "${var.project}-${var.environment}-results-${var.account_id}"
  tags   = merge(local.tags, { Purpose = "results" })
}

resource "aws_s3_bucket_public_access_block" "results" {
  bucket                  = aws_s3_bucket.results.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_logging" "results" {
  bucket = aws_s3_bucket.results.id
  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "results/"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "results" {
  bucket = aws_s3_bucket.results.id
  rule {
    id     = "expire-5y"
    status = "Enabled"
    expiration { days = 1825 }
  }
}

output "uploads_bucket" {
  value = aws_s3_bucket.uploads.bucket
}

output "results_bucket" {
  value = aws_s3_bucket.results.bucket
}

output "logs_bucket" {
  value = aws_s3_bucket.logs.bucket
}
