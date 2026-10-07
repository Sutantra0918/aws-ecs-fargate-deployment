locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_wafv2_web_acl" "main" {
  name  = "${var.project_name}-${var.environment}-web-acl"
  scope = "REGIONAL"

  default_action {
    allow {}
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  lifecycle {
    ignore_changes = [rule]
  }

  tags = merge(
    local.common_tags,
    {
      name = "${var.project_name}-${var.environment}-web-acl"
    }
  )
}

resource "aws_wafv2_web_acl_rule" "common_rules" {
  name        = "aws_common_rule"
  priority    = 10
  web_acl_arn = aws_wafv2_web_acl.main.arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesCommonRuleSet"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-common-rules"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "ip_reputation" {
  name        = "aws-ip-reputation"
  priority    = 20
  web_acl_arn = aws_wafv2_web_acl.main.arn

  override_action {
    none {}
  }

  statement {
    managed_rule_group_statement {
      name        = "AWSManagedRulesAmazonIpReputationList"
      vendor_name = "AWS"
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "aws-ip-reputation"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_rule" "rate_limit" {
  name        = "rate-limit"
  priority    = 30
  web_acl_arn = aws_wafv2_web_acl.main.arn

  action {
    block {}
  }

  statement {
    rate_based_statement {
      limit                 = 1000
      aggregate_key_type    = "IP"
      evaluation_window_sec = 300
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "rate-limit"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}