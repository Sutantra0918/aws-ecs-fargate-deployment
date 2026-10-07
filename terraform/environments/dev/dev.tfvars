aws_region  = "ap-south-1"
aws_project = "taskflow"
environment = "dev"

vpc_cidr = "10.20.0.0/16"

public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

app_subnet_cidrs = [
  "10.20.10.0/24",
  "10.20.11.0/24"
]

db_subnet_cidrs = [
  "10.20.20.0/24",
  "10.20.21.0/24"
]

ecs_port = 8080
db_port  = 5432

db_name              = "taskflow"
db_username          = "taskflow_usr"
db_instance_class    = "db.t4g.micro"
db_allocated_storage = 20

desired_count = 1