provider "aws" {
  region = var.region
}

# Edge services (CloudFront/ACM) require us-east-1
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
