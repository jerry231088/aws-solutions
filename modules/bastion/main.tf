data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.name}-sg"
  description = "SG for bastion host."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "sg_ingress" {
  ip_protocol       = "tcp"
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4         = var.admin_ip_cidr
  from_port         = 22
  to_port           = 22
  description       = "SSH access from administrator IP."
}

resource "aws_vpc_security_group_egress_rule" "sg_egress" {
  ip_protocol       = "-1"
  security_group_id = aws_security_group.bastion_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  description = "Allow outbound IPv4 traffic."
}

resource "aws_instance" "bastion" {
  ami                         = data.aws_ssm_parameter.amazon_linux.value
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  key_name                    = var.key_name

  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  root_block_device {
    encrypted = true
  }

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}
