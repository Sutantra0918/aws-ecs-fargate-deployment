locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_db_subnet_group" "main" {
  name = "${var.project_name}-${var.environment}-db_subnet_group"

  subnet_ids = var.db_subnet_ids
  tags = merge(

    local.common_tags,
    {
      name = "${var.project_name}-${var.environment}-db-subnet-group"
    }
  )
}

resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-${var.environment}-postgres"

  engine         = "postgres"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = 50
  storage_type          = "gp3"

  db_name  = var.db_name
  username = var.db_username

  manage_master_user_password = true

  db_subnet_group_name = aws_db_subnet_group.main.name

  vpc_security_group_ids = [
    var.db_sg_id
  ]

  publicly_accessible = false
  multi_az            = false

  storage_encrypted = true

  backup_retention_period = 1

  auto_minor_version_upgrade = true

  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]

  deletion_protection   = false
  skip_final_snapshot   = true
  copy_tags_to_snapshot = true

  tags = merge(
    local.common_tags,
    {
      name = "${var.project_name}-${var.environment}-postgres"
    }
  )

}