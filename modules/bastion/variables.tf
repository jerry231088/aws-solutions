variable "name" {
  description = "Name of the bastion host."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet ID where the bastion is deployed."
  type        = string
}

variable "admin_ip_cidr" {
  description = "Administrator public IPv4 CIDR allowed to SSH to the bastion. Use /32 for one IP."
  type        = string

  validation {
    condition     = can(cidrhost(var.admin_ip_cidr, 0)) && endswith(var.admin_ip_cidr, "/32")
    error_message = "admin_ip_cidr must be a valid IPv4 /32 CIDR, for example 203.0.113.10/32."
  }
}

variable "key_name" {
  description = "Existing EC2 key pair name."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for the bastion."
  type        = string
  default     = "t3.micro"
}

variable "tags" {
  description = "Tags applied to bastion resources."
  type        = map(string)
  default     = {}
}
