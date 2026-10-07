output "vpc_id" {
  value       = aws_vpc.my_vpc.id
  description = "VPC ID."
}

output "vpc_cidr" {
  value       = aws_vpc.my_vpc.cidr_block
  description = "VPC CIDR block."
}

output "public_subnets_ids" {
  value       = aws_subnet.public_subnet[*].id
  description = "Public subnet IDs."
}

output "private_subnet_ids" {
  value       = aws_subnet.private_subnet[*].id
  description = "Private subnet IDs."
}

output "igw_id" {
  value       = aws_internet_gateway.my_igw.id
  description = "IGW ID."
}

output "nat_gw_id" {
  value = aws_nat_gateway.my_natgw[*].id
  description = "NAT Gateway IDs."
}

output "nat_eip_addr" {
  value = aws_eip.nat[*].public_ip
  description = "Elastic IP addresses assigned to NAT Gateways."
}
