variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "vpc-private-rds-bastion"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}


# ---------------------------------------------------------
# Networking
# ---------------------------------------------------------

variable "vpc_cidr" {
  description = "VPC CIDR block."
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Two availability zones."
  type        = list(string)

  default = [
    "eu-central-1a",
    "eu-central-1b"
  ]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs."

  type = list(string)

  default = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs."

  type = list(string)

  default = [
    "10.0.11.0/24",
    "10.0.12.0/24"
  ]
}


# ---------------------------------------------------------
# Bastion
# ---------------------------------------------------------

variable "admin_ip_cidr" {
  description = "Your public IP in /32 format, allowed to SSH to the bastion."
  type        = string
}

variable "bastion_key_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "bastion_instance_type" {
  description = "Bastion EC2 instance type."
  type        = string
  default     = "t3.micro"
}


# ---------------------------------------------------------
# RDS
# ---------------------------------------------------------

variable "db_name" {
  description = "Initial PostgreSQL database name."
  type        = string
  default     = "appdb"
}

variable "db_master_user" {
  description = "RDS master username."
  type        = string
  default     = "dbadmin"
}

variable "pg_engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"
}

variable "rds_instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "rds_allocated_storage" {
  description = "Initial RDS storage in GiB."
  type        = number
  default     = 20
}

variable "rds_max_allocated_storage" {
  description = "Maximum RDS autoscaling storage in GiB."
  type        = number
  default     = 100
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention in days."
  type        = number
  default     = 7
}
