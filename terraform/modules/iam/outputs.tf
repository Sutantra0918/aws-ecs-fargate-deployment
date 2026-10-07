output "execution_role_arn" {
  description = "IAM execution role ARN for ECS Fargate tasks"
  value       = aws_iam_role.ecs_execution.arn
}