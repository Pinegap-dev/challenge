output "vpc_id" {
  value = module.network.vpc_id
}

output "public_subnets" {
  value = module.network.public_subnets
}

output "private_app_subnets" {
  value = module.network.private_app_subnets
}

output "rds_endpoint" {
  value = module.rds.rds_endpoint
}

output "s3_uploads_bucket" {
  value = module.s3.uploads_bucket
}

output "s3_results_bucket" {
  value = module.s3.results_bucket
}

output "eks_cluster_name" {
  value = module.eks.cluster_name
}

output "batch_queue_arn" {
  value = module.batch_sfn.batch_queue_arn
}

output "state_machine_arn" {
  value = module.batch_sfn.state_machine_arn
}
