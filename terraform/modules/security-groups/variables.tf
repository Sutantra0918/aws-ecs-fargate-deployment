variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "ecs_port" {
  description = "Port exposed by the ECS container"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "PostgreSQL database port"
  type        = number
  default     = 5432
}