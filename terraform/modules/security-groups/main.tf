locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}


resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for public Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"

  description = "Allow HTTP traffic from the internet"
}

resource "aws_vpc_security_group_egress_rule" "alb_to_ecs" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = var.ecs_port
  to_port                      = var.ecs_port
  ip_protocol                  = "tcp"

  description = "Allow ALB traffic to ECS tasks"
}

resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-ecs-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "ecs_from_alb" {
  security_group_id = aws_security_group.ecs.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.ecs_port
  to_port                      = var.ecs_port
  ip_protocol                  = "tcp"

  description = "Allow ECS traffic only from the ALB"
}

resource "aws_vpc_security_group_egress_rule" "ecs_https" {
  security_group_id = aws_security_group.ecs.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"

  description = "Allow HTTPS outbound through NAT Gateway"
}

resource "aws_vpc_security_group_egress_rule" "ecs_to_db" {
  security_group_id = aws_security_group.ecs.id

  referenced_security_group_id = aws_security_group.db.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"

  description = "Allow ECS tasks to communicate with PostgreSQL RDS"
}

resource "aws_security_group" "db" {
  name        = "${var.project_name}-${var.environment}-db-sg"
  description = "Security group for PostgreSQL RDS"
  vpc_id      = var.vpc_id

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-db-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "db_from_ecs" {
  security_group_id = aws_security_group.db.id

  referenced_security_group_id = aws_security_group.ecs.id
  from_port                    = var.db_port
  to_port                      = var.db_port
  ip_protocol                  = "tcp"

  description = "Allow PostgreSQL traffic only from ECS tasks"
}