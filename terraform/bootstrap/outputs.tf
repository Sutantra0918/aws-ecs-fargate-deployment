output "terraform_state_bucket" {
  description = "S3 bucket used for Terraform remote state."
  value       = aws_s3_bucket.taskflow_bucket.bucket
}

output "aws_account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "terraform_apply_role_arn" {
  description = "GitHub Actions IAM role used for Terraform deployment."
  value       = aws_iam_role.github_terraform.arn
}

output "terraform_plan_role_arn" {
  description = "GitHub Actions IAM role used for Terraform plans."
  value       = aws_iam_role.github_terraform_plan.arn
}

output "prowler_role_arn" {
  description = "GitHub Actions IAM role used by Prowler for AWS security assessment."
  value       = aws_iam_role.github_prowler.arn
}