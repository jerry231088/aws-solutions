resource "aws_apigatewayv2_api" "api_gateway" {
  name          = var.api_name
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = var.allow_origins

    allow_methods = [
    "GET", "POST", "PUT", "DELETE", "OPTIONS"
    ]

    allow_headers = ["content-type"]
  }

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.api_gateway.id
  integration_type       = "AWS_PROXY"
  integration_uri        = var.lambda_invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "api_gateway_route" {
  for_each  = var.routes

  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = each.value
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  name        = "$default"
  auto_deploy = true
  tags        = var.tags
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api_gateway.execution_arn}/*/*"
}
