variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  default     = "PAY_PER_REQUEST"
  type        = string
  description = "DynamoDB billing mode."

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode must be PAY_PER_REQUEST or PROVISIONED."
  }
}

variable "hash_key" {
  description = "DynamoDB partition key attribute name."
  type        = string
}

variable "hash_key_type" {
  description = "DynamoDB partition key attribute type."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "hash_key_type must be S, N, or B."
  }
}

variable "tags" {
  description = "Tags applied to the DynamoDB table."
  type        = map(string)
  default     = {}
}
