output "db_instance_id" {
  description = "RDS instance ID."
  value       = aws_db_instance.rds_db.id
}

output "db_endpoint" {
  description = "RDS endpoint hostname."
  value       = aws_db_instance.rds_db.address
}

output "db_port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.rds_db.port
}

output "security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.rds_sg.id
}

output "master_user_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = aws_db_instance.rds_db.master_user_secret[0].secret_arn
}
