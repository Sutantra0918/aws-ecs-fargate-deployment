output "db_instance_id" {
  description = "RDS database instance ID"
  value       = aws_db_instance.main.id
}

output "db_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "RDS PostgreSQL port"
  value       = aws_db_instance.main.port
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.main.db_name
}

output "master_secret_arn" {
  description = "Secrets Manager ARN containing RDS master credentials"
  value       = aws_db_instance.main.master_user_secret[0].secret_arn
}