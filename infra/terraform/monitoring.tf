# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application" {
  name              = "/aws/eks/${var.cluster_name}/application"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = "/aws/eks/${var.cluster_name}/audit"
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "pod_restart" {
  alarm_name          = "eks-pod-restart"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "pod_restart_count"
  namespace          = "ContainerInsights"
  period             = "300"
  statistic          = "Sum"
  threshold          = "5"
  alarm_description  = "This metric monitors pod restarts"
  alarm_actions      = []  # Add SNS topic ARN for notifications

  dimensions = {
    ClusterName = var.cluster_name
  }
}

resource "aws_cloudwatch_metric_alarm" "node_cpu" {
  alarm_name          = "eks-node-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name        = "node_cpu_utilization"
  namespace          = "ContainerInsights"
  period             = "300"
  statistic          = "Average"
  threshold          = "80"
  alarm_description  = "This metric monitors node CPU utilization"
  alarm_actions      = []  # Add SNS topic ARN for notifications

  dimensions = {
    ClusterName = var.cluster_name
  }
}

# GuardDuty Detector
resource "aws_guardduty_detector" "main" {
  enable = true

  datasources {
    kubernetes {
      audit_logs {
        enable = true
      }
    }
  }
}

# Security Hub
resource "aws_securityhub_account" "main" {
  enable_default_standards = true
}

resource "aws_securityhub_standards_subscription" "cis" {
  depends_on    = [aws_securityhub_account.main]
  standards_arn = "arn:aws:securityhub:${var.aws_region}::standards/cis-aws-foundations-benchmark/v/1.2.0"
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "eks" {
  dashboard_name = "EKS-${var.cluster_name}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ContainerInsights", "pod_cpu_utilization", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Pod CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ContainerInsights", "pod_memory_utilization", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Pod Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ContainerInsights", "pod_network_rx_bytes", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Pod Network RX"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          metrics = [
            ["ContainerInsights", "pod_network_tx_bytes", "ClusterName", var.cluster_name]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Pod Network TX"
        }
      }
    ]
  })
}

# AWS Config
resource "aws_config_configuration_recorder" "eks" {
  name     = "config-eks-${var.cluster_name}"
  role_arn = aws_iam_role.config_role.arn

  recording_group {
    all_supported = true
    include_global_resources = true
  }
}

resource "aws_iam_role" "config_role" {
  name = "config-role-${var.cluster_name}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# AWS Config Rules
resource "aws_config_config_rule" "eks_version" {
  name = "eks-version-${var.cluster_name}"

  source {
    owner             = "AWS"
    source_identifier = "EKS_CLUSTER_VERSION_CHECK"
  }

  scope {
    compliance_resource_types = ["AWS::EKS::Cluster"]
  }

  depends_on = [aws_config_configuration_recorder.eks]
}

resource "aws_config_config_rule" "eks_secrets_encrypted" {
  name = "eks-secrets-encrypted-${var.cluster_name}"

  source {
    owner             = "AWS"
    source_identifier = "EKS_SECRETS_ENCRYPTED"
  }

  scope {
    compliance_resource_types = ["AWS::EKS::Cluster"]
  }

  depends_on = [aws_config_configuration_recorder.eks]
} 