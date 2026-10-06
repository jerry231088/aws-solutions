output "function_name" {
  value       = aws_lambda_function.function.function_name
  description = "Lambda function name."
}

output "function_arn" {
  value       = aws_lambda_function.function.arn
  description = "lambda function ARN."
}

output "invoke_arn" {
  value       = aws_lambda_function.function.invoke_arn
  description = "Lambda invoke ARN."
}

output "role_arn" {
  value       = aws_iam_role.function_exec_role.arn
  description = "Lambda execution role ARN."
}