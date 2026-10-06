variable "aws_region" {
  description = "AWS region."
  type = string
  default = "eu-central-1"
}

variable "project_name" {
  description = "Project name."
  type = string
  default = "serverless-rest-api"
}

variable "environment" {
  description = "Environment name"
  type = string
  default = "dev"
}

variable "lambda_runtime" {
  description = "Lambda runtime."
  type        = string
  default     = "python3.14"
}

variable "lambda_memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 256
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 60
}
