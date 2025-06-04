provider "aws" {
  region = "us-east-1"
}

# VPC Configuration
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "devsecops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "production"
    Project     = "devsecops"
  }
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "csn-capstone"
  cluster_version = "1.27"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    general = {
      desired_size = 1
      min_size     = 1
      max_size     = 3

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"

      labels = {
        role = "general"
      }

      tags = {
        ExtraTag = "cloudsec-node"
      }
    }
  }

  # Enable OIDC provider
  enable_irsa = true

  # Enable AWS Secrets Manager integration
  cluster_addons = {
    secrets-store-csi-driver = {
      most_recent = true
    }
  }
}

# Security Group Rules
resource "aws_security_group_rule" "cluster_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.eks.cluster_security_group_id
}

# AWS Secrets Manager
resource "aws_secretsmanager_secret" "app_secrets" {
  name = "devsecops/app/credentials"
  
  tags = {
    Environment = "production"
    Project     = "devsecops"
  }
}

# IAM Role for EKS to access Secrets Manager
module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                      = "~> 5.0"
  create_role                  = true
  role_name                    = "eks-secrets-manager-role"
  provider_url                 = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns            = [aws_iam_policy.secrets_manager_access.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:default:jomacs-capstone-service-account"]
}

# IAM Policy for Secrets Manager access
resource "aws_iam_policy" "secrets_manager_access" {
  name        = "eks-secrets-manager-policy"
  description = "Policy for EKS to access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [aws_secretsmanager_secret.app_secrets.arn]
      }
    ]
  })
}

# CloudWatch Log Group for EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/csn-capstone/cluster"
  retention_in_days = 30

  tags = {
    Environment = "production"
    Project     = "devsecops"
  }
}

# AWS WAF for EKS
resource "aws_wafv2_web_acl" "eks_waf" {
  name        = "eks-waf"
  description = "WAF for EKS cluster"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "BlockSQLInjection"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "BlockSQLInjectionMetric"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "EKSWAFMetric"
    sampled_requests_enabled  = true
  }
}

# Outputs
output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
} 