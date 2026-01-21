variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "security_group" {
  type = string
}

variable "batch_job_image" {
  type = string
}

variable "region" {
  type = string
}

variable "uploads_bucket" {
  type        = string
  description = "S3 bucket for uploads"
}

variable "results_bucket" {
  type        = string
  description = "S3 bucket for results"
}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_cloudwatch_log_group" "batch" {
  name              = "/aws/batch/${var.project}/${var.environment}"
  retention_in_days = 14
  tags              = merge(local.tags, { Component = "batch" })
}

data "aws_iam_policy_document" "batch_service_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["batch.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_service" {
  name               = "${var.project}-${var.environment}-batch-service-role"
  assume_role_policy = data.aws_iam_policy_document.batch_service_assume.json
}

resource "aws_iam_role_policy_attachment" "batch_service_policy" {
  role       = aws_iam_role.batch_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBatchServiceRole"
}

data "aws_iam_policy_document" "batch_task_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "batch_task" {
  name               = "${var.project}-${var.environment}-batch-task-role"
  assume_role_policy = data.aws_iam_policy_document.batch_task_assume.json
}

resource "aws_iam_policy" "batch_task_s3" {
  name = "${var.project}-${var.environment}-batch-task-s3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::${var.uploads_bucket}",
          "arn:aws:s3:::${var.uploads_bucket}/*",
          "arn:aws:s3:::${var.results_bucket}",
          "arn:aws:s3:::${var.results_bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "batch_task_policy" {
  role       = aws_iam_role.batch_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "batch_task_s3_attach" {
  role       = aws_iam_role.batch_task.name
  policy_arn = aws_iam_policy.batch_task_s3.arn
}

resource "aws_batch_compute_environment" "fargate" {
  name          = "${var.project}-${var.environment}-batch-ce"
  service_role  = aws_iam_role.batch_service.arn
  type          = "MANAGED"

  compute_resources {
    max_vcpus = 32
    subnets   = var.subnets
    security_group_ids = [var.security_group]
    type = "FARGATE"
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-batch-ce" })
}

resource "aws_batch_job_queue" "default" {
  name     = "${var.project}-${var.environment}-batch-queue"
  priority = 1
  state    = "ENABLED"

  compute_environment_order {
    order                = 1
    compute_environment  = aws_batch_compute_environment.fargate.arn
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-batch-queue" })
}

resource "aws_batch_job_definition" "default" {
  name = "${var.project}-${var.environment}-batch-job"
  type = "container"

  platform_capabilities = ["FARGATE"]

  container_properties = jsonencode({
    image      = var.batch_job_image
    command    = ["python", "-c", "import os; print('process from', os.getenv('BUCKET_UPLOADS'), 'to', os.getenv('BUCKET_RESULTS'))"]
    vcpus      = 1
    memory     = 2048
    environment = [
      { name = "BUCKET_UPLOADS", value = var.uploads_bucket },
      { name = "BUCKET_RESULTS", value = var.results_bucket }
    ]
    networkConfiguration = {
      assignPublicIp = "ENABLED"
    }
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.batch.name
        awslogs-region        = var.region
        awslogs-stream-prefix = "batch"
      }
    }
  })

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-batch-job" })
}

data "aws_iam_policy_document" "sfn_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["states.${var.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "sfn" {
  name               = "${var.project}-${var.environment}-sfn-role"
  assume_role_policy = data.aws_iam_policy_document.sfn_assume.json
}

resource "aws_iam_role_policy" "sfn_batch_policy" {
  name = "${var.project}-${var.environment}-sfn-batch-policy"
  role = aws_iam_role.sfn.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["batch:SubmitJob", "batch:DescribeJobs", "batch:TerminateJob"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_sfn_state_machine" "batch_flow" {
  name     = "${var.project}-${var.environment}-batch-flow"
  role_arn = aws_iam_role.sfn.arn

  definition = jsonencode({
    Comment = "Trigger Batch job"
    StartAt = "SubmitJob"
    States = {
      SubmitJob = {
        Type    = "Task"
        Resource = "arn:aws:states:::batch:submitJob.sync"
        Parameters = {
          JobDefinition = aws_batch_job_definition.default.arn
          JobName       = "${var.project}-${var.environment}-job"
          JobQueue      = aws_batch_job_queue.default.arn
        }
        End = true
      }
    }
  })

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-sfn" })
}

output "batch_queue_arn" {
  value = aws_batch_job_queue.default.arn
}

output "state_machine_arn" {
  value = aws_sfn_state_machine.batch_flow.arn
}
