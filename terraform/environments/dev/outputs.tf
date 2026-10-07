output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "app_subnet_ids" {
  description = "Private application subnet IDs"
  value       = module.vpc.app_subnet_ids
}

output "db_subnet_ids" {
  description = "Private database subnet IDs"
  value       = module.vpc.db_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "availability_zones" {
  description = "Availability zones used by the infrastructure"
  value       = module.vpc.availability_zones
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = module.security-groups.alb_security_group_id
}

output "ecs_security_group_id" {
  description = "ECS security group ID"
  value       = module.security-groups.ecs_security_group_id
}

output "db_security_group_id" {
  description = "RDS security group ID"
  value       = module.security-groups.db_security_group_id
}

output "alb_dns_name" {
  description = "Public DNS name of the Application Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  description = "ARN of the ECS ALB target group"
  value       = module.alb.target_group_arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = module.ecs.cluster_name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = module.ecs.service_name
}

output "ecs_task_definition_arn" {
  description = "ECS task definition ARN"
  value       = module.ecs.task_definition_arn
}

output "ecs_log_group_name" {
  description = "CloudWatch log group used by ECS"
  value       = module.ecs.cloudwatch_log_group_name
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port"
  value       = module.rds.db_port
}

output "rds_master_secret_arn" {
  description = "Secrets Manager ARN containing RDS master credentials"
  value       = module.rds.master_secret_arn
}