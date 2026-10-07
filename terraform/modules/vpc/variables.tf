variable "project_name" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment for the VPC"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "A list of CIDR blocks for the public subnets"
  type        = list(string)
}

variable "app_subnet_cidrs" {
  description = "A list of CIDR blocks for the application subnets"
  type        = list(string)
}

variable "db_subnet_cidrs" {
  description = "A list of CIDR blocks for the database subnets"
  type        = list(string)
}

