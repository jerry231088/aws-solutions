output "api_endpoint" {
  description = "API Gateway endpoint."
  value       = module.api_gateway.api_endpoint
}

output "dynamodb_table_name" {
  description = "DynamoDB table name."
  value       = module.dynamodb.table_name
}

output "lambda_function_name" {
  description = "Lambda function name."
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN."
  value       = module.lambda.function_arn
}