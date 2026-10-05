terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.region

  # plan_only = true lets `terraform plan` run without real AWS access
  # (used by CI and for reviewing the code locally with dummy credentials).
  skip_credentials_validation = var.plan_only
  skip_requesting_account_id  = var.plan_only
  skip_metadata_api_check     = var.plan_only

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}

locals {
  name    = "${var.project}-${var.environment}"
  db_port = 5432
}

module "network" {
  source = "../../modules/network"

  name                 = local.name
  vpc_cidr             = var.vpc_cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  container_port       = var.container_port
  db_port              = local.db_port
}

module "rds" {
  source = "../../modules/rds"

  name                  = local.name
  subnet_ids            = module.network.private_subnet_ids
  security_group_id     = module.network.rds_sg_id
  instance_class        = var.db_instance_class
  allocated_storage     = var.db_allocated_storage
  max_allocated_storage = var.db_max_allocated_storage
  multi_az              = var.db_multi_az
  backup_retention_days = var.db_backup_retention_days
  deletion_protection   = var.deletion_protection
  db_name               = var.db_name
  username              = var.db_username
}

module "ecs" {
  source = "../../modules/ecs"

  name               = local.name
  region             = var.region
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  private_subnet_ids = module.network.private_subnet_ids
  alb_sg_id          = module.network.alb_sg_id
  ecs_sg_id          = module.network.ecs_sg_id

  container_image     = var.container_image
  container_port      = var.container_port
  cpu                 = var.task_cpu
  memory              = var.task_memory
  desired_count       = var.desired_count
  deletion_protection = var.deletion_protection

  db_host       = module.rds.address
  db_port       = module.rds.port
  db_name       = module.rds.db_name
  db_secret_arn = module.rds.secret_arn
}
