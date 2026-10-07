variable "aws_region" {
  description = "AWS region used for deployment"
  type        = string
  default     = "ap-south-1"
}

variable "aws_project" {
  description = "AWS project name"
  type        = string
  default     = "CloudInfra"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "CIDR blocks for private application subnets"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "CIDR blocks for private database subnets"
  type        = list(string)
}

variable "ecs_port" {
  description = "Port exposed by the ECS container"
  type        = number
  default     = 8080
}

variable "db_port" {
  description = "PostgreSQL port"
  type        = number
  default     = 5432
}

variable "db_name" {
  description = "PostgreSQL database name"
  type        = string
}

variable "db_username" {
  description = "PostgreSQL master username"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_allocated_storage" {
  description = "Initial RDS storage in GB"
  type        = number
}

variable "desired_count" {
  description = "Number of ECS Fargate tasks"
  type        = number
  default     = 1
}