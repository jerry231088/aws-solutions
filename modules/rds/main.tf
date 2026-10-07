resource "aws_security_group" "rds_sg" {
  name        = "${var.name}-sg"
  description = "SG for RDS PostgreSQL."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "rds_sg_ingress" {
  ip_protocol                  = "tcp"
  security_group_id            = aws_security_group.rds_sg.id
  referenced_security_group_id = var.bastion_sg_id
  from_port                    = 5432
  to_port                      = 5432
  description                  = "RDS PostgreSQL access from bastion SG"
}

resource "aws_vpc_security_group_egress_rule" "rds_sg_egress" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.rds_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  description       = "Allow outbound IPv4 traffic."
}

resource "aws_db_subnet_group" "rds_db_subnet_group" {
  name = "${var.name}-rds-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-subnet-group"
    }
  )
}

resource "aws_db_instance" "rds_db" {
  identifier                  = var.name
  engine                      = "postgres"
  engine_version              = var.engine_version
  instance_class              = var.instance_class
  allocated_storage           = var.allocated_storage
  max_allocated_storage       = var.max_allocated_storage
  storage_type                = "gp3"
  storage_encrypted           = true
  db_name                     = var.db_name
  username                    = var.master_user
  manage_master_user_password = true
  port                        = 5432
  db_subnet_group_name        = aws_db_subnet_group.rds_db_subnet_group.name
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  publicly_accessible         = false
  multi_az                    = true
  backup_retention_period     = var.backup_retention_period
  deletion_protection         = false
  skip_final_snapshot         = true
  apply_immediately           = true
  auto_minor_version_upgrade  = true

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}