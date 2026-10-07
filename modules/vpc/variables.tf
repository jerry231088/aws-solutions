variable "name" {
  description = "Name prefix for VPC resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "Availability zones used by the VPC."
  type        = list(string)

  validation {
    condition = length(var.azs) == 2
    error_message = "Exactly 2 AZ must be provided."
  }
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets."
  type        = list(string)

  validation {
    condition = length(var.azs) == 2
    error_message = "Exactly 2 AZ must be provided."
  }
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets."
  type        = list(string)

  validation {
    condition = length(var.azs) == 2
    error_message = "Exactly 2 AZ must be provided."
  }
}

variable "tags" {
  description = "Tags applied to VPC resources."
  type        = map(string)
  default     = {}
}
