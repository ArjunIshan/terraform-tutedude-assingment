terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
  }
}

variable "aws_region" {
  description = "AWS Region used to configure the provider."
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_iam_policy" "cloudwatch_read_only" {
  name        = "TerraformCloudWatchReadOnly-${data.aws_caller_identity.current.account_id}"
  description = "Read-only access to CloudWatch metrics, alarms, and dashboards."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchReadOnly"
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAnomalyDetectors",
          "cloudwatch:GetDashboard",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListDashboards",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name        = "Terraform CloudWatch Read-Only"
    AwsAccount  = data.aws_caller_identity.current.account_id
    AwsRegion   = data.aws_region.current.region
    Environment = "assignment"
  }
}

output "policy_arn" {
  description = "ARN of the custom CloudWatch read-only IAM policy."
  value       = aws_iam_policy.cloudwatch_read_only.arn
}
