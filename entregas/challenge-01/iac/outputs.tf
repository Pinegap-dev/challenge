output "vpc_id" {
  value = module.network.vpc_id
}

output "alb_dns" {
  value = module.ecs_fastapi.alb_dns
}

output "service_name" {
  value = module.ecs_fastapi.service_name
}
