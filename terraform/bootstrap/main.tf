terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket       = "taskflow-451664151915-ap-south-1"
    key          = "bootstrap/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}


provider "aws" {
  region = var.aws_region
}


data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "taskflow_bucket" {
  bucket = "${var.aws_project}-${data.aws_caller_identity.current.account_id}-${var.aws_region}"

  tags = {
    Name        = "${var.aws_project}-terraform-state"
    Project     = var.aws_project
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}


resource "aws_s3_bucket_versioning" "taskflow_bucket_versioning" {
  bucket = aws_s3_bucket.taskflow_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_server_side_encryption_configuration" "taskflow_bucket_encryption" {
  bucket = aws_s3_bucket.taskflow_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.terraform_state.arn
    }

    bucket_key_enabled = true
  }
}


resource "aws_s3_bucket_public_access_block" "taskflow_bucket_public_access_block" {
  bucket = aws_s3_bucket.taskflow_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_kms_key" "terraform_state" {
  description             = "KMS key for Terraform state encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.aws_project}-terraform-state-kms"
    Project     = var.aws_project
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}

resource "aws_kms_alias" "terraform_state" {
  name          = "alias/${var.aws_project}-terraform-state"
  target_key_id = aws_kms_key.terraform_state.key_id
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name        = "${var.aws_project}-github-oidc"
    Project     = var.aws_project
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "github_terraform_assume_role" {
  statement {
    sid     = "GitHubActionsAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        var.github_oidc_subject
      ]
    }
  }
}


resource "aws_iam_role" "github_terraform" {
  name = "${var.aws_project}-github-terraform-role"

  assume_role_policy = data.aws_iam_policy_document.github_terraform_assume_role.json

  tags = {
    Name        = "${var.aws_project}-github-terraform-role"
    Project     = var.aws_project
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}


data "aws_iam_policy_document" "github_terraform_permissions" {

  statement {
    sid    = "ManageTaskFlowInfrastructure"
    effect = "Allow"

    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "ecs:*",
      "rds:*",
      "wafv2:*",
      "logs:*",
      "secretsmanager:*"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"

      values = [
        var.aws_region
      ]
    }
  }

  statement {
    sid    = "DescribeTaskFlowKMSKeys"
    effect = "Allow"

    actions = [
      "kms:DescribeKey"
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"

      values = [
        var.aws_region
      ]
    }
  }

  statement {
    sid    = "ManageTaskFlowIAMRoles"
    effect = "Allow"

    actions = [
      "iam:CreateRole",
      "iam:DeleteRole",
      "iam:GetRole",
      "iam:TagRole",
      "iam:UntagRole",
      "iam:UpdateAssumeRolePolicy",

      "iam:PutRolePolicy",
      "iam:GetRolePolicy",
      "iam:DeleteRolePolicy",

      "iam:AttachRolePolicy",
      "iam:DetachRolePolicy",

      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",

      "iam:PassRole"
    ]

    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.aws_project}-*"
    ]
  }

  statement {
    sid    = "ReadAWSManagedIAMPolicies"
    effect = "Allow"

    actions = [
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]

    resources = [
      "arn:aws:iam::aws:policy/*"
    ]
  }

  statement {
    sid    = "TerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.taskflow_bucket.arn
    ]
  }


  statement {
    sid    = "TerraformStateObjects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.taskflow_bucket.arn}/*"
    ]
  }
  statement {
    sid    = "TerraformStateKMS"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.terraform_state.arn
    ]
  }
}


resource "aws_iam_role_policy" "github_terraform_permissions" {
  name = "${var.aws_project}-github-terraform-policy"
  role = aws_iam_role.github_terraform.id

  policy = data.aws_iam_policy_document.github_terraform_permissions.json
}

data "aws_iam_policy_document" "github_terraform_plan_assume_role" {
  statement {
    sid     = "GitHubActionsPullRequestAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        var.github_oidc_pr_subject
      ]
    }
  }
}


resource "aws_iam_role" "github_terraform_plan" {
  name = "${var.aws_project}-github-terraform-plan-role"

  assume_role_policy = data.aws_iam_policy_document.github_terraform_plan_assume_role.json

  tags = {
    Name        = "${var.aws_project}-github-terraform-plan-role"
    Project     = var.aws_project
    Environment = "shared"
    ManagedBy   = "Terraform"
  }
}


data "aws_iam_policy_document" "github_terraform_plan_permissions" {


  statement {
    sid    = "ReadDevTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.taskflow_bucket.arn}/taskflow/dev/terraform.tfstate"
    ]
  }

  statement {
    sid    = "ManageDevTerraformLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "${aws_s3_bucket.taskflow_bucket.arn}/taskflow/dev/terraform.tfstate.tflock"
    ]
  }


  statement {
    sid    = "GetTerraformStateBucketLocation"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation"
    ]

    resources = [
      aws_s3_bucket.taskflow_bucket.arn
    ]
  }


  statement {
    sid    = "ListDevTerraformState"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.taskflow_bucket.arn
    ]

    condition {
      test     = "StringLike"
      variable = "s3:prefix"

      values = [
        "taskflow/dev/*"
      ]
    }
  }

  statement {
    sid    = "ReadTaskFlowInfrastructure"
    effect = "Allow"

    actions = [
      "ec2:Describe*",

      "elasticloadbalancing:Describe*",

      "ecs:Describe*",
      "ecs:List*",

      "rds:Describe*",
      "rds:ListTagsForResource",

      "wafv2:Get*",
      "wafv2:List*",

      "logs:Describe*",
      "logs:ListTagsForResource",

      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds",

      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetOpenIDConnectProvider",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoleTags",

      "kms:DescribeKey",

      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }
  statement {
    sid    = "TerraformStateKMS"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]

    resources = [
      aws_kms_key.terraform_state.arn
    ]
  }
}


resource "aws_iam_role_policy" "github_terraform_plan_permissions" {
  name = "${var.aws_project}-github-terraform-plan-policy"
  role = aws_iam_role.github_terraform_plan.id

  policy = data.aws_iam_policy_document.github_terraform_plan_permissions.json
}


data "aws_iam_policy_document" "github_prowler_assume_role" {
  statement {
    sid     = "GitHubActionsProwlerAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        var.github_oidc_subject
      ]
    }
  }
}


resource "aws_iam_role" "github_prowler" {
  name = "${var.aws_project}-github-prowler-role"

  assume_role_policy = data.aws_iam_policy_document.github_prowler_assume_role.json

  tags = {
    Name        = "${var.aws_project}-github-prowler-role"
    Project     = var.aws_project
    Environment = "shared"
    ManagedBy   = "Terraform"
    Purpose     = "ProwlerSecurityScan"
  }
}


resource "aws_iam_role_policy_attachment" "prowler_security_audit" {
  role = aws_iam_role.github_prowler.name

  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}


resource "aws_iam_role_policy_attachment" "prowler_view_only" {
  role = aws_iam_role.github_prowler.name

  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}