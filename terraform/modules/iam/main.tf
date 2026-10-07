locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type = "Service"

      identifiers = [
        "ecs-tasks.amazonaws.com"
      ]
    }
  }
}

resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-${var.environment}-ecs-execution-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-execution-role"
    }
  )
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role = aws_iam_role.ecs_execution.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}