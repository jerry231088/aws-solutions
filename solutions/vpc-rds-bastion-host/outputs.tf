output "vpc_id" {
  description = "VPC ID."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = module.vpc.public_subnets_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs."
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_ids" {
  description = "NAT Gateway IDs."
  value       = module.vpc.nat_gw_id
}

output "bastion_instance_id" {
  description = "Bastion EC2 instance ID."
  value       = module.bastion.instance_id
}

output "bastion_public_ip" {
  description = "Bastion public IP."
  value       = module.bastion.public_ip
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port."
  value       = module.rds.db_port
}

output "rds_master_user_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = module.rds.master_user_secret_arn
}
