module "lambda_api" {
  source           = "./modules/lambda_api"
  project          = var.project
  environment      = var.environment
  lambda_image_uri = var.lambda_image_uri
  name_value       = var.name_value
}
