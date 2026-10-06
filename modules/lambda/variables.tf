variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "source_file" {
  description = "Path to Lambda source file."
  type        = string
}

variable "handler" {
  description = "Lambda handler"
  type        = string
  default     = "Handler.lambda_handler"
}

variable "runtime" {
  description = "Lambda runtime"
  type        = string
  default     = "python3.14"
}

variable "timeout" {
  description = "Lambda timeout in seconds."
  type        = number
  default     = 60
}

variable "memory_size" {
  description = "Lambda memory size in MB."
  type        = number
  default     = 256
}

variable "env_vars" {
  description = "Lambda environment variables"
  type        = map(string)
  default     = {}
}

variable "policy_json" {
  description = "IAM policy JSON attached to the Lambda execution role."
  type        = string
}

variable "log_retention_days" {
  description = "Cloudwatch log retention period."
  type        = number
  default     = 14
}

variable "tags" {
  description = "Tags applied to Lambda resources."
  type        = map(string)
  default     = {}
}