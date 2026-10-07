module "vpc" {
  source = "../../modules/vpc"

  project_name = var.aws_project
  environment  = var.environment

  vpc_cidr = var.vpc_cidr

  public_subnet_cidrs = var.public_subnet_cidrs
  app_subnet_cidrs    = var.app_subnet_cidrs
  db_subnet_cidrs     = var.db_subnet_cidrs
}


module "security-groups" {
  source = "../../modules/security-groups"

  project_name = var.aws_project
  environment  = var.environment

  vpc_id = module.vpc.vpc_id

  ecs_port = var.ecs_port
  db_port  = var.db_port
}


module "rds" {
  source = "../../modules/rds"

  project_name = var.aws_project
  environment  = var.environment

  db_subnet_ids = module.vpc.db_subnet_ids
  db_sg_id      = module.security-groups.db_security_group_id

  db_name              = var.db_name
  db_username          = var.db_username
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
}


module "iam" {
  source = "../../modules/iam"

  project_name = var.aws_project
  environment  = var.environment
}


module "alb" {
  source = "../../modules/alb"

  project_name = var.aws_project
  environment  = var.environment

  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.security-groups.alb_security_group_id
  ecs_port              = var.ecs_port
}


module "ecs" {
  source = "../../modules/ecs"

  project_name = var.aws_project
  environment  = var.environment
  aws_region   = var.aws_region

  app_subnet_ids = module.vpc.app_subnet_ids

  ecs_security_group_id = module.security-groups.ecs_security_group_id
  execution_role_arn    = module.iam.execution_role_arn
  target_group_arn      = module.alb.target_group_arn

  desired_count = var.desired_count
}


module "waf" {
  source = "../../modules/waf"

  project_name = var.aws_project
  environment  = var.environment

  alb_arn = module.alb.alb_arn
}