variable "name" {
  description = "RDS instance identifier."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the RDS subnet group."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for the RDS subnet group."
  }
}

variable "bastion_sg_id" {
  description = "Security group ID allowed to access PostgreSQL."
  type        = string
}

variable "db_name" {
  description = "Initial database name."
  type        = string
  default     = "appdb"
}

variable "master_user" {
  description = "RDS master username."
  type        = string
  default     = "dbadmin"
}

variable "engine_version" {
  description = "PostgreSQL engine version."
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class."
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Initial allocated storage in GiB."
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Maximum storage in GiB for autoscaling."
  type        = number
  default     = 100
}

variable "backup_retention_period" {
  description = "Number of days to retain automated backups."
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags applied to RDS resources."
  type        = map(string)
  default     = {}
}
