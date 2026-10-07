locals {
  common_tags = {
    Project = var.project_name
    Environment = var.environment
    ManagedBy = "Neeraj"
  }

  name_prefix = "${var.project_name}-${var.environment}"
}

# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------

module "vpc" {
  source = "../../modules/vpc"

  name                 = local.name_prefix
  vpc_cidr             = var.vpc_cidr
  azs                  = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  tags = local.common_tags
}

# ---------------------------------------------------------
# Bastion Host
# ---------------------------------------------------------

module "bastion" {
  source = "../../modules/bastion"

  name          = "${local.name_prefix}-bastion"
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnets_ids[0]
  admin_ip_cidr = var.admin_ip_cidr
  key_name      = var.bastion_key_name
  instance_type = var.bastion_instance_type

  tags = local.common_tags
}

# ---------------------------------------------------------
# RDS PostgreSQL
# ---------------------------------------------------------

module "rds" {
  source = "../../modules/rds"

  name                    = "${local.name_prefix}-rds-postgres"
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  bastion_sg_id           = module.bastion.security_group_id
  db_name                 = var.db_name
  master_user             = var.db_master_user
  engine_version          = var.pg_engine_version
  instance_class          = var.rds_instance_class
  allocated_storage       = var.rds_allocated_storage
  max_allocated_storage   = var.rds_max_allocated_storage
  backup_retention_period = var.rds_backup_retention_period

  tags = local.common_tags
}
