variable "project_name" {
  description = "Project Name"
  type        = string
}

variable "environment" {
  description = "Deployment environment"
  type        = string
}

variable "db_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group for DB"
  type        = string
}

variable "db_name" {
  description = "PostgreSQL DB Name"
  type        = string
}

variable "db_username" {
  description = "DB User name"
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