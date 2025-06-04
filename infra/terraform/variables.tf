variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "devsecops"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "csn-capstone"
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.27"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "node_groups" {
  description = "EKS node group configuration"
  type = map(object({
    desired_size    = number
    min_size        = number
    max_size        = number
    instance_types  = list(string)
    capacity_type   = string
    labels          = map(string)
    tags           = map(string)
  }))
  default = {
    general = {
      desired_size   = 1
      min_size      = 1
      max_size      = 3
      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      labels = {
        role = "general"
      }
      tags = {
        ExtraTag = "jomacsdevsecops-node"
      }
    }
  }
}

variable "enable_irsa" {
  description = "Enable IAM roles for service accounts"
  type        = bool
  default     = true
}

variable "enable_secrets_store_csi" {
  description = "Enable AWS Secrets Manager CSI driver"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "waf_rules" {
  description = "WAF rules configuration"
  type = list(object({
    name        = string
    priority    = number
    rule_group  = string
    vendor      = string
  }))
  default = [
    {
      name       = "BlockSQLInjection"
      priority   = 1
      rule_group = "AWSManagedRulesSQLiRuleSet"
      vendor     = "AWS"
    }
  ]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "production"
    Project     = "jomacsdevsecops"
    ManagedBy   = "terraform"
  }
} 