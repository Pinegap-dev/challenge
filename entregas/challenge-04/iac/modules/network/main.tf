variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "az_count" {
  type    = number
  default = 2
}

variable "allowed_egress_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

locals {
  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(local.tags, { Name = "${var.project}-${var.environment}-vpc" })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${var.project}-${var.environment}-igw" })
}

resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = "${var.project}-${var.environment}-public-${count.index}"
    Tier = "public"
  })
}

resource "aws_eip" "nat" {
  count = var.az_count
  vpc   = true
  tags  = merge(local.tags, { Name = "${var.project}-${var.environment}-nat-eip-${count.index}" })
}

resource "aws_nat_gateway" "nat" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(local.tags, { Name = "${var.project}-${var.environment}-nat-${count.index}" })
}

resource "aws_subnet" "private_app" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 10)
  availability_zone = local.azs[count.index]
  tags = merge(local.tags, {
    Name = "${var.project}-${var.environment}-private-app-${count.index}"
    Tier = "private-app"
  })
}

resource "aws_subnet" "private_data" {
  count             = var.az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 20)
  availability_zone = local.azs[count.index]
  tags = merge(local.tags, {
    Name = "${var.project}-${var.environment}-private-data-${count.index}"
    Tier = "private-data"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${var.project}-${var.environment}-rt-public" })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  tags   = merge(local.tags, { Name = "${var.project}-${var.environment}-rt-private-${count.index}" })
}

resource "aws_route" "private_nat" {
  count                  = var.az_count
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

resource "aws_route_table_association" "private_app_assoc" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_app[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "aws_route_table_association" "private_data_assoc" {
  count          = var.az_count
  subnet_id      = aws_subnet.private_data[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security groups
resource "aws_security_group" "alb" {
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "ALB ingress"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_egress_cidr]
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-alb-sg" })
}

resource "aws_security_group" "eks_nodes" {
  name        = "${var.project}-${var.environment}-eks-nodes-sg"
  description = "EKS nodes"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_egress_cidr]
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-eks-nodes-sg" })
}

resource "aws_security_group" "rds" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "RDS ingress from EKS"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_nodes.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.allowed_egress_cidr]
  }

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-rds-sg" })
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_app_subnets" {
  value = aws_subnet.private_app[*].id
}

output "private_data_subnets" {
  value = aws_subnet.private_data[*].id
}

output "alb_sg_id" {
  value = aws_security_group.alb.id
}

output "eks_nodes_sg_id" {
  value = aws_security_group.eks_nodes.id
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
