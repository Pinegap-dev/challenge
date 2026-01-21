variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "kms_key_arn" {
  type = string
}

variable "availability_zone_count" {
  type    = number
  default = 2
}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.project}-${var.environment}-rds-subnet"
  subnet_ids = var.subnet_ids
  tags       = merge(local.tags, { Name = "${var.project}-${var.environment}-rds-subnet" })
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "${var.project}-${var.environment}-aurora"
  engine                  = "aurora-postgresql"
  engine_mode             = "provisioned"
  master_username         = var.db_username
  master_password         = var.db_password
  backup_retention_period = 7
  db_subnet_group_name    = aws_db_subnet_group.rds.name
  vpc_security_group_ids  = var.security_group_ids
  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn
  deletion_protection     = false
  tags                    = merge(local.tags, { Name = "${var.project}-${var.environment}-aurora" })
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count              = var.availability_zone_count
  identifier         = "${var.project}-${var.environment}-aurora-${count.index}"
  cluster_identifier = aws_rds_cluster.aurora.id
  instance_class     = "db.r6g.large"
  engine             = aws_rds_cluster.aurora.engine
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.rds.name
  tags               = merge(local.tags, { Name = "${var.project}-${var.environment}-aurora-${count.index}" })
}

resource "aws_secretsmanager_secret" "db" {
  name = "${var.project}-${var.environment}-db-credentials"
  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-db-secret" })
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id     = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({ username = var.db_username, password = var.db_password, endpoint = aws_rds_cluster.aurora.endpoint, engine = aws_rds_cluster.aurora.engine })
}

output "rds_endpoint" {
  value = aws_rds_cluster.aurora.endpoint
}

output "rds_cluster_arn" {
  value = aws_rds_cluster.aurora.arn
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db.arn
}
