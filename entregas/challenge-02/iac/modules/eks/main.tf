variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "node_subnet_ids" {
  type = list(string)
}

variable "security_group_ids" {
  type = list(string)
}

variable "tags" {
  type = map(string)
}

locals {
  tags = var.tags
}

data "aws_iam_policy_document" "eks_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${var.project}-${var.environment}-eks-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

data "aws_iam_policy_document" "eks_nodes_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eks_nodes" {
  name               = "${var.project}-${var.environment}-eks-nodes-role"
  assume_role_policy = data.aws_iam_policy_document.eks_nodes_assume.json
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ecr_read" {
  role       = aws_iam_role.eks_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_eks_cluster" "this" {
  name     = "${var.project}-${var.environment}-eks"
  role_arn = aws_iam_role.eks_cluster.arn

  vpc_config {
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.security_group_ids
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-eks" })
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.project}-${var.environment}-ng"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = var.node_subnet_ids

  scaling_config {
    desired_size = 2
    max_size     = 4
    min_size     = 2
  }

  ami_type       = "AL2_x86_64"
  instance_types = ["t3.medium"]

  tags = merge(local.tags, { Name = "${var.project}-${var.environment}-ng" })
}

# OIDC provider for IRSA
data "tls_certificate" "oidc" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc.certificates[0].sha1_fingerprint]
}

# ALB Ingress Controller IRSA role
data "aws_iam_policy_document" "alb_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

data "aws_iam_policy_document" "alb_policy" {
  statement {
    actions   = ["iam:CreateServiceLinkedRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:AWSServiceName"
      values   = ["elasticloadbalancing.amazonaws.com"]
    }
  }
  statement {
    actions   = ["ec2:DescribeAccountAttributes", "ec2:DescribeAddresses", "ec2:DescribeAvailabilityZones", "ec2:DescribeInternetGateways", "ec2:DescribeVpcs", "ec2:DescribeVpcPeeringConnections", "ec2:DescribeSubnets", "ec2:DescribeSecurityGroups", "ec2:DescribeInstances", "ec2:DescribeNetworkInterfaces", "ec2:DescribeTags", "ec2:DescribeRouteTables"]
    resources = ["*"]
  }
  statement {
    actions   = ["ec2:CreateSecurityGroup", "ec2:CreateTags", "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress", "ec2:DeleteSecurityGroup"]
    resources = ["*"]
  }
  statement {
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }
  statement {
    actions   = ["iam:ListServerCertificates", "iam:GetServerCertificate"]
    resources = ["*"]
  }
  statement {
    actions   = ["cognito-idp:DescribeUserPoolClient", "acm:ListCertificates", "acm:DescribeCertificate"]
    resources = ["*"]
  }
  statement {
    actions   = ["waf-regional:GetWebACLForResource", "waf-regional:GetWebACL", "waf-regional:AssociateWebACL", "waf-regional:DisassociateWebACL", "wafv2:GetWebACL", "wafv2:GetWebACLForResource", "wafv2:AssociateWebACL", "wafv2:DisassociateWebACL", "shield:DescribeProtection", "shield:GetSubscriptionState", "shield:DeleteProtection", "shield:CreateProtection", "shield:DescribeSubscription"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "alb_irsa" {
  name               = "${var.project}-${var.environment}-alb-controller"
  assume_role_policy = data.aws_iam_policy_document.alb_irsa_assume.json
}

resource "aws_iam_policy" "alb_irsa" {
  name   = "${var.project}-${var.environment}-alb-controller"
  policy = data.aws_iam_policy_document.alb_policy.json
}

resource "aws_iam_role_policy_attachment" "alb_irsa_attach" {
  role       = aws_iam_role.alb_irsa.name
  policy_arn = aws_iam_policy.alb_irsa.arn
}

# Cluster Autoscaler IRSA role
data "aws_iam_policy_document" "ca_irsa_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
  }
}

resource "aws_iam_role" "cluster_autoscaler" {
  name               = "${var.project}-${var.environment}-cluster-autoscaler"
  assume_role_policy = data.aws_iam_policy_document.ca_irsa_assume.json
}

resource "aws_iam_role_policy_attachment" "ca_auto_scaling" {
  role       = aws_iam_role.cluster_autoscaler.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_role_arn" {
  value = aws_iam_role.eks_cluster.arn
}

output "node_role_arn" {
  value = aws_iam_role.eks_nodes.arn
}

output "oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.eks.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_irsa.arn
}

output "cluster_autoscaler_role_arn" {
  value = aws_iam_role.cluster_autoscaler.arn
}
