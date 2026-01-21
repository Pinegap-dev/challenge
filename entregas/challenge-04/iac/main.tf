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
  source                = "./modules/eks"
  project               = var.project
  environment           = var.environment
  subnet_ids            = concat(module.network.private_app_subnets, module.network.public_subnets)
  node_subnet_ids       = module.network.private_app_subnets
  security_group_ids    = [module.network.eks_nodes_sg_id]
  tags                  = local.tags
}

module "batch_sfn" {
  source           = "./modules/batch_sfn"
  project          = var.project
  environment      = var.environment
  subnets          = module.network.private_app_subnets
  security_group   = module.network.eks_nodes_sg_id
  batch_job_image  = var.batch_job_image
  region           = var.region
}

module "edge" {
  source              = "./modules/edge"
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
