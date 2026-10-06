output "api_id" {
  value       = aws_apigatewayv2_api.api_gateway.id
  description = "API Gateway API ID."
}

output "api_endpoint" {
  description = "API Gateway endpoint."
  value       = aws_apigatewayv2_stage.api_gateway_stage.invoke_url
}

output "execution_arn" {
  value       = aws_apigatewayv2_api.api_gateway.execution_arn
  description = "API Gateway execution ARN."
}
