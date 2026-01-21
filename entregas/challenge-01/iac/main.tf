module "network" {
  source              = "./modules/network"
  project             = var.project
  environment         = var.environment
  vpc_cidr            = var.vpc_cidr
  az_count            = 2
  allowed_egress_cidr = "0.0.0.0/0"
}

module "ecs_fastapi" {
  source          = "./modules/ecs_fastapi"
  project         = var.project
  environment     = var.environment
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnets
  private_subnets = module.network.private_app_subnets
  alb_sg_id       = module.network.alb_sg_id
  app_sg_id       = module.network.app_sg_id
  task_image      = var.task_image
  desired_count   = var.desired_count
  admin_user      = var.admin_user
  admin_pass      = var.admin_pass
}
