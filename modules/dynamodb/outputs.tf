output "table_name" {
  value       = aws_dynamodb_table.ddb.name
  description = "DynamoDB table name."
}

output "table_arn" {
  value       = aws_dynamodb_table.ddb.arn
  description = "DynamoDB table ARN."
}

output "table_id" {
  value       = aws_dynamodb_table.ddb.id
  description = "DynamoDB table ID."
}
