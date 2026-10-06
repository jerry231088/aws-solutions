variable "api_name" {
  description = "Name of the HTTP API."
  type        = string
}

variable "lambda_function_name" {
  description = "Lambda function name used by the API integration."
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda invoke ARN."
  type        = string
}

variable "routes" {
  description = "API Gateway HTTP API routes."
  type        = map(string)
}

variable "allow_origins" {
  description = "Allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Tags applied to API Gateway resources."
}
