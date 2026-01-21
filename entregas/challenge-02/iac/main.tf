data "aws_caller_identity" "current" {}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

module "network" {
  source              = "./modules/network"
  project             = var.project
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  az_count            = var.az_count
  allowed_egress_cidr = var.allowed_egress_cidr
}

module "kms" {
  source      = "./modules/kms"
  project     = var.project
  environment = var.environment
}

module "s3" {
  source      = "./modules/s3"
  project     = var.project
  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id
  kms_key_arn = module.kms.kms_s3_arn
}

module "ecr" {
  source      = "./modules/ecr"
  project     = var.project
  environment = var.environment
}

module "rds" {
  source                  = "./modules/rds"
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
  source             = "./modules/eks"
  project            = var.project
  environment        = var.environment
  subnet_ids         = concat(module.network.private_app_subnets, module.network.public_subnets)
  node_subnet_ids    = module.network.private_app_subnets
  security_group_ids = [module.network.eks_nodes_sg_id]
  tags               = local.tags
}

module "batch_sfn" {
  source          = "./modules/batch_sfn"
  project         = var.project
  environment     = var.environment
  subnets         = module.network.private_app_subnets
  security_group  = module.network.eks_nodes_sg_id
  batch_job_image = var.batch_job_image
  region          = var.region
  uploads_bucket  = module.s3.uploads_bucket
  results_bucket  = module.s3.results_bucket
}

module "edge" {
  source             = "./modules/edge"
  providers          = { aws = aws, aws.us_east_1 = aws.us_east_1 }
  project            = var.project
  environment        = var.environment
  tags               = local.tags
  enable_edge        = var.enable_edge
  enable_waf         = var.enable_waf
  domain_name        = var.domain_name
  hosted_zone_id     = var.hosted_zone_id
  origin_domain_name = var.origin_domain_name
  acm_certificate_arn = var.acm_certificate_arn
}

# Secrets Manager rotation for RDS using AWS SAR blueprint
resource "aws_serverlessapplicationrepository_cloudformation_stack" "rds_rotation" {
  name             = "${var.project}-${var.environment}-rds-rotation"
  application_id   = "arn:aws:serverlessrepo:us-east-1:297356227824:applications/SecretsManagerRDSPostgreSQLRotationSingleUser"
  semantic_version = var.rotation_app_version
  capabilities     = ["CAPABILITY_IAM", "CAPABILITY_NAMED_IAM", "CAPABILITY_AUTO_EXPAND"]

  parameters = {
    functionName        = "${var.project}-${var.environment}-rds-rotation"
    vpcSecurityGroupIds = module.network.rds_sg_id
    vpcSubnetIds        = join(",", module.network.private_data_subnets)
    dbName              = ""
    masterSecretArn     = module.rds.db_secret_arn
    excludeCharacters   = "\"@/\\' "
    kmsKeyArn           = ""
    endpoint            = ""
  }
}

# Wire rotation schedule to the secret (uses Lambda created by the SAR stack)
resource "aws_secretsmanager_secret_rotation" "rds" {
  secret_id = module.rds.db_secret_arn
  rotation_lambda_arn = one([
    for o in aws_serverlessapplicationrepository_cloudformation_stack.rds_rotation.outputs : o.value
    if o.name == "RotationLambdaARN"
  ])

  rotation_rules {
    automatically_after_days = 30
  }
}

# ALB Ingress Controller via Helm with IRSA role from EKS module
data "aws_eks_cluster" "this" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  create_namespace = false

  values = [yamlencode({
    clusterName = module.eks.cluster_name
    region      = var.region
    serviceAccount = {
      create = false
      name   = "aws-load-balancer-controller"
      annotations = {
        "eks.amazonaws.com/role-arn" = module.eks.alb_controller_role_arn
      }
    }
    vpcId = module.network.vpc_id
  })]

  depends_on = [module.eks]
}

# Alerts topic + optional email subscription
resource "aws_sns_topic" "alerts" {
  name = "${var.project}-${var.environment}-alerts"
  tags = local.tags
}

resource "aws_sns_topic_subscription" "alerts_email" {
  count = var.alarm_email != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# AWS Backup for Aurora
resource "aws_backup_vault" "main" {
  name = "${var.project}-${var.environment}-backup"
  tags = local.tags
}

resource "aws_iam_role" "backup" {
  name               = "${var.project}-${var.environment}-backup-role"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "backup.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "backup_restore" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

resource "aws_backup_plan" "main" {
  name = "${var.project}-${var.environment}-backup-plan"

  rule {
    rule_name         = "daily-rds"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 5 * * ? *)" # daily 02:00 BRT approx
    lifecycle {
      delete_after = 30
    }
  }
  tags = local.tags
}

resource "aws_backup_selection" "rds" {
  name         = "rds-selection"
  iam_role_arn = aws_iam_role.backup.arn
  plan_id      = aws_backup_plan.main.id
  resources    = [module.rds.rds_cluster_arn]
}

# Audit/log buckets for CloudTrail/Config
resource "aws_s3_bucket" "audit" {
  bucket = "${var.project}-${var.environment}-audit-${data.aws_caller_identity.current.account_id}"
  tags   = merge(local.tags, { Purpose = "audit" })
}

resource "aws_s3_bucket_public_access_block" "audit" {
  bucket                  = aws_s3_bucket.audit.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "audit" {
  bucket = aws_s3_bucket.audit.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "audit" {
  bucket = aws_s3_bucket.audit.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

data "aws_iam_policy_document" "audit_bucket" {
  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.audit.arn}/cloudtrail/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
  statement {
    sid    = "AWSConfigWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.audit.arn}/config/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
  statement {
    sid    = "AllowGetAcl"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com", "config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.audit.arn]
  }
}

resource "aws_s3_bucket_policy" "audit" {
  bucket = aws_s3_bucket.audit.id
  policy = data.aws_iam_policy_document.audit_bucket.json
}

resource "aws_cloudtrail" "main" {
  name                       = "${var.project}-${var.environment}-trail"
  s3_bucket_name             = aws_s3_bucket.audit.id
  s3_key_prefix              = "cloudtrail"
  include_global_service_events = true
  is_multi_region_trail      = true
  enable_log_file_validation = true
}

resource "aws_iam_role" "config" {
  name               = "${var.project}-${var.environment}-config-role"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "config.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}

resource "aws_iam_role_policy_attachment" "config_managed" {
  role       = aws_iam_role.config.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

resource "aws_config_configuration_recorder" "main" {
  name     = "config"
  role_arn = aws_iam_role.config.arn
}

resource "aws_config_delivery_channel" "main" {
  name           = "delivery-channel"
  s3_bucket_name = aws_s3_bucket.audit.id
}

resource "aws_config_configuration_recorder_status" "main" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.main]
}

# Simple alarm on RDS CPU
resource "aws_cloudwatch_metric_alarm" "rds_cpu" {
  alarm_name          = "${var.project}-${var.environment}-rds-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_actions       = [aws_sns_topic.alerts.arn]
  dimensions = {
    DBClusterIdentifier = element(split(":", module.rds.rds_cluster_arn), 6)
  }
  tags = local.tags
}
