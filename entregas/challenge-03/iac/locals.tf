locals {
  name = "${var.project}-${var.environment}-api"
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}
