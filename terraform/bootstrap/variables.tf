variable "aws_region" {
  description = "AWS region used for the infrastructure."
  type        = string
  default     = "ap-south-1"
}

variable "aws_project" {
  description = "AWS project name."
  type        = string
  default     = "taskflow"
}

variable "github_oidc_subject" {
  description = "GitHub OIDC subject allowed to assume main-branch deployment roles."
  type        = string
}

variable "github_oidc_pr_subject" {
  description = "GitHub OIDC subject allowed to assume the Terraform plan role from pull requests."
  type        = string
}